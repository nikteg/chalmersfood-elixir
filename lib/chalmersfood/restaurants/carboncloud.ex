defmodule Chalmersfood.Restaurants.CarbonCloud do
  defmacro __using__(_) do
    quote do
      use Tesla
      alias Chalmersfood.Restaurants.{Restaurant, CarbonCloud}
      use Restaurant

      plug Tesla.Middleware.Query, CarbonCloud.datespan()
      plug Tesla.Middleware.JSON
      plug Tesla.Middleware.Timeout, timeout: 10_000
      # plug Tesla.Middleware.Retry, delay: 500, max_retries: 10

      @behaviour CarbonCloud

      @impl true
      def fetch() do
        case get("https://carbonateapiprod.azurewebsites.net/api/v1/mealprovidingunits/#{id()}/dishoccurrences") do
          {:ok, %{body: body, status: status}} when status == 200 ->
            {:ok, body}

          {:ok, _} ->
            {:error, "Invalid ID"}

          {:error, _} = error ->
            error
        end
      end

      @impl true
      def parse(body) do
        body
        |> CarbonCloud.map_items_from_result()
        |> Enum.sort_by(&CarbonCloud.parse_date(Map.get(&1, :date)))
        |> Enum.sort_by(&type_sort_order(Map.get(&1, :type)))
        |> Enum.group_by(&Map.get(&1, :date), &Map.delete(&1, :date))
        |> Map.values()
      end
    end
  end

  @callback id() :: String.t()
  @callback type_sort_order(type :: term) :: term

  def datespan() do
    now = DateTime.utc_now()
    weekday = Date.day_of_week(DateTime.utc_now()) - 1
    monday = Date.add(now, -weekday)
    friday = Date.add(monday, 4)

    [startDate: Date.to_iso8601(monday), endDate: Date.to_iso8601(friday)]
  end

  def map_items_from_result(result) do
    for %{
          "dishType" => %{"dishTypeName" => type},
          "displayNames" => display_names,
          "startDate" => start_date
        } <- result do
      %{type: type, name: get_display_name(display_names), date: start_date}
    end
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

  @sort_order [
    "Classic Vegan",
    "Classic Fisk",
    "Classic Kött",
    "Veckans Sallad",
    "Express"
  ]

  def name(), do: "Kårresturangen"

  @impl true
  def id(), do: "21f31565-5c2b-4b47-d2a1-08d558129279"

  @impl true
  def type_sort_order(type), do: Enum.find_index(@sort_order, &(&1 == type))
end

defmodule Chalmersfood.Restaurants.Express do
  alias Chalmersfood.Restaurants.{CarbonCloud}

  use CarbonCloud

  @sort_order [
    "Express",
    "Express - Vegan"
  ]

  def name(), do: "Express"

  @impl true
  def id(), do: "3d519481-1667-4cad-d2a3-08d558129279"

  @impl true
  def type_sort_order(type), do: Enum.find_index(@sort_order, &(&1 == type))
end

defmodule Chalmersfood.Restaurants.Linsen do
  alias Chalmersfood.Restaurants.{CarbonCloud}

  use CarbonCloud

  def name(), do: "Linsen"

  @impl true
  def id(), do: "b672efaf-032a-4bb8-d2a5-08d558129279"

  @impl true
  def type_sort_order(type), do: type
end

defmodule Chalmersfood.Restaurants.SMAK do
  alias Chalmersfood.Restaurants.{CarbonCloud}

  use CarbonCloud

  @sort_order [
    "Dagens",
    "Veckans"
  ]

  def name(), do: "S.M.A.K."

  @impl true
  def id(), do: "3ac68e11-bcee-425e-d2a8-08d558129279"

  @impl true
  def type_sort_order(type), do: Enum.find_index(@sort_order, &(&1 == type))
end
