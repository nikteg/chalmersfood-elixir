defmodule Chalmersfood.Restaurants.Wijkanders do
  use Tesla
  alias Chalmersfood.Restaurants.Restaurant
  use Restaurant

  plug Tesla.Middleware.Timeout, timeout: 15_000
  # plug Tesla.Middleware.Retry, delay: 500, max_retries: 10

  @impl true
  def name(), do: "Wijkanders"

  @impl true
  def url(), do: "https://wijkanders.se"

  @impl true
  def fetch() do
    case get("https://wijkanders.se/restaurangen/", opts: [adapter: [:insecure]]) do
      {:ok, %{body: body}} ->
        {:ok, body}

      {:error, _} = error ->
        error
    end
  end

  @impl true
  def parse(body) do
    now = DateTime.utc_now()
    weekday = Date.day_of_week(now) - 1
    monday = Date.add(now, -weekday)
    friday = Date.add(monday, 4)

    body
    |> Floki.find(".post .post-content p")
    |> Enum.flat_map(fn elem -> Floki.text(elem) |> String.split("\n") end)
    |> Enum.map(&String.trim(&1))
    # Remove english names (items surrounded by paranthesis)
    # NOTE: Sometimes they forget the ending paranthesis
    |> Enum.filter(fn text -> not String.match?(text, ~r/^\(.+\)*$/) end)
    # Remove empty items
    |> Enum.filter(&(&1 != ""))
    |> Enum.reduce_while({nil, %{}}, fn text, {date_cursor, items} = acc ->
      case Regex.run(~r/(\d+)\/(\d+)$/, text, capture: :all_but_first) do
        # Awesome, we found a date
        [day, month] ->
          current_date = date_cursor || monday

          found_date = new_date(String.to_integer(month), String.to_integer(day), current_date)

          {:cont, {found_date, items}}

        # Item is not a date
        nil ->
          # Item looks like food
          if date_cursor && String.match?(text, ~r/^(Vegetarisk|Fisk|Kött)+/i) do
            [type, name] = String.split(text, ~r/\s*:\s*/) |> Enum.map(&String.trim(&1))

            item = %{type: type, name: name}
            items = Map.update(items, date_cursor, [item], &[item | &1])

            {:cont, {date_cursor, items}}
          else
            # Rubbish, continue
            {:cont, acc}
          end
      end
    end)
    |> get_week_items(Date.range(monday, friday))
  end

  defp get_week_items({_day, items}, week_dates) do
    Enum.map(week_dates, &Map.get(items, &1))
  end

  defp new_date(month, day, current_date) do
    year =
      if month + 6 <= current_date.month do
        current_date.year + 1
      else
        current_date.year
      end

    {:ok, date} = Date.new(year, month, day)

    date
  end
end
