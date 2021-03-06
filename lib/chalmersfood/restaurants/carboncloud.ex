defmodule Chalmersfood.Restaurants.CarbonCloud do
  defmacro __using__(_) do
    quote do
      use Tesla
      alias Chalmersfood.Restaurants.{Restaurant, CarbonCloud}
      use Restaurant

      plug Tesla.Middleware.Query, CarbonCloud.datespan()
      plug Tesla.Middleware.JSON
      plug Tesla.Middleware.Timeout, timeout: 30_000
      plug Tesla.Middleware.Logger

      # plug Tesla.Middleware.Retry, delay: 500, max_retries: 10

      @behaviour CarbonCloud

      @impl true
      def fetch() do
        case get("https://carbonateapiprod.azurewebsites.net/api/v1/mealprovidingunits/#{id()}/dishoccurrences",
               opts: [adapter: [recv_timeout: 30_000]]
             ) do
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
        |> Enum.sort_by(&type_sort_order(Map.get(&1, :type)))
        |> Enum.group_by(&Map.get(&1, :date), &Map.delete(&1, :date))
        |> Enum.to_list()
        |> Enum.sort_by(fn {date, _items} -> Date.to_erl(date) end)
        |> Keyword.values()
        |> Enum.map(fn items -> items ++ extras() end)
      end

      @impl true
      def extras(), do: []

      defoverridable extras: 0
    end
  end

  @callback id() :: String.t()
  @callback type_sort_order(type :: term) :: term
  @callback extras() :: [%{name: String.t(), type: String.t()}]

  def datespan() do
    now = DateTime.utc_now()
    weekday = Date.day_of_week(now) - 1
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
      %{type: type, name: get_display_name(display_names), date: parse_date(start_date)}
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

  @impl true
  def name(), do: "Kårresturangen"

  @impl true
  def url(), do: "https://chalmerskonferens.se/en/restauranger/johanneberg/karrestaurangen/"

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

  @impl true
  def name(), do: "Express"

  @impl true
  def url(), do: "https://chalmerskonferens.se/en/restauranger/johanneberg/express/"

  @impl true
  def id(), do: "3d519481-1667-4cad-d2a3-08d558129279"

  @impl true
  def type_sort_order(type), do: Enum.find_index(@sort_order, &(&1 == type))
end

defmodule Chalmersfood.Restaurants.Linsen do
  alias Chalmersfood.Restaurants.{CarbonCloud}

  use CarbonCloud

  @impl true
  def name(), do: "Linsen"

  @impl true
  def url(), do: "https://chalmerskonferens.se/en/restauranger/johanneberg/restaurangcafe-linsen/"

  @impl true
  def id(), do: "b672efaf-032a-4bb8-d2a5-08d558129279"

  @impl true
  def type_sort_order(type), do: type

  @impl true
  def extras(),
    do: [
      %{type: "Stående", name: "Wokade nudlar med kyckling/tofu och grönsaker
smaksatt med ingefära och chili"},
      %{type: "Stående", name: "Caesarsallad med kyckling, bacon, romansallad,
grana padana och krutonger samt dressing"}
    ]
end

defmodule Chalmersfood.Restaurants.SMAK do
  alias Chalmersfood.Restaurants.{CarbonCloud}

  use CarbonCloud

  @sort_order [
    "Dagens",
    "Veckans"
  ]

  @impl true
  def name(), do: "S.M.A.K."

  @impl true
  def url(), do: "https://chalmerskonferens.se/en/restauranger/johanneberg/smak/"

  @impl true
  def id(), do: "3ac68e11-bcee-425e-d2a8-08d558129279"

  @impl true
  def type_sort_order(type), do: Enum.find_index(@sort_order, &(&1 == type))
end

defmodule Chalmersfood.Restaurants.LsKitchen do
  alias Chalmersfood.Restaurants.{CarbonCloud}

  use CarbonCloud

  @sort_order [
    "Kött",
    "Fisk",
    "Sallad",
    "Vegan"
  ]

  @impl true
  def name(), do: "L's Kitchen"

  @impl true
  def url(), do: "https://chalmerskonferens.se/en/restauranger/lindholmen/ls-kitchen/"

  @impl true
  def id(), do: "c74da2cf-aa1a-4d3a-9ba6-08d5569587a1"

  @impl true
  def type_sort_order(type), do: Enum.find_index(@sort_order, &(&1 == type))
end

defmodule Chalmersfood.Restaurants.KokBoken do
  alias Chalmersfood.Restaurants.{CarbonCloud}

  use CarbonCloud

  @sort_order [
    "Express",
    "Vegan"
  ]

  @impl true
  def name(), do: "Kokboken"

  @impl true
  def url(), do: "https://chalmerskonferens.se/en/restauranger/lindholmen/kokboken/"

  @impl true
  def id(), do: "4dce0df9-c6e7-46cf-d2a7-08d558129279"

  @impl true
  def type_sort_order(type), do: Enum.find_index(@sort_order, &(&1 == type))
end
