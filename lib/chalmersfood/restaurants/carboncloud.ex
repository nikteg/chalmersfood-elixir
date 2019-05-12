defmodule Chalmersfood.Restaurants.CarbonCloud do
  defmacro __using__(_) do
    quote do
      use Tesla

      alias Chalmersfood.Restaurants.{Restaurant, CarbonCloud}

      plug Tesla.Middleware.Query, CarbonCloud.datespan()
      plug Tesla.Middleware.JSON

      @behaviour Restaurant
      @behaviour CarbonCloud

      def fetch() do
        case get("https://carbonateapiprod.azurewebsites.net/api/v1/mealprovidingunits/#{id()}/dishoccurrences") do
          {:ok, %{body: body}} ->
            items_with_dates =
              for %{
                    "dishType" => %{"dishTypeName" => type},
                    "displayNames" => display_names,
                    "startDate" => start_date
                  } <- body do
                %{type: type, name: CarbonCloud.get_display_name(display_names), date: start_date}
              end

            ordered_items =
              items_with_dates
              |> Enum.sort_by(&CarbonCloud.parse_date(Map.get(&1, :date)))
              |> Enum.sort_by(&CarbonCloud.type_sort_order(Map.get(&1, :type)))
              |> Enum.group_by(&Map.get(&1, :date), &Map.delete(&1, :date))
              |> Map.values()

            {:ok, ordered_items}

          {:error, _} = error ->
            error
        end
      end

      def parse(body) do
        [["foo"], ["bar"]]
      end
    end
  end

  @callback id() :: String.t()

  @sort_order [
    "Classic Vegan",
    "Classic Fisk",
    "Classic Kött",
    "Veckans Sallad",
    "Express"
  ]

  def type_sort_order(type), do: Enum.find_index(@sort_order, &(&1 == type))

  def datespan() do
    now = DateTime.utc_now()
    weekday = Date.day_of_week(DateTime.utc_now()) - 1
    monday = Date.add(now, -weekday)
    friday = Date.add(monday, 4)

    [startDate: Date.to_iso8601(monday), endDate: Date.to_iso8601(friday)]
  end

  def get_display_name(display_names), do: get_display_name(display_names, :swedish)

  def get_display_name(display_names, :swedish) do
    %{"dishDisplayName" => display_name} =
      Enum.find(display_names, &match?(%{"displayNameCategory" => %{"displayNameCategoryName" => "Swedish"}}, &1))

    display_name
  end

  def get_display_name(display_names, :english) do
    %{"dishDisplayName" => display_name} =
      Enum.find(display_names, &match?(%{"displayNameCategory" => %{"displayNameCategoryName" => "English"}}, &1))

    display_name
  end

  def parse_date(date_string) do
    [month, day, rest] = String.split(date_string, "/")
    year = String.slice(rest, 0, 4)
    Date.from_erl!({String.to_integer(year), String.to_integer(month), String.to_integer(day)})
  end
end

defmodule Chalmersfood.Restaurants.Karresturangen do
  alias Chalmersfood.Restaurants.{CarbonCloud}

  use CarbonCloud

  def name(), do: "Kårresturangen"
  def id(), do: "21f31565-5c2b-4b47-d2a1-08d558129279"
end
