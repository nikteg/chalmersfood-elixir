defmodule Chalmersfood.Restaurants do
  alias Chalmersfood.Restaurants.{Karresturangen, Express, Linsen, SMAK}
  alias Chalmersfood.Cache

  @restaurants [Karresturangen, Express, Linsen, SMAK]

  def fetch!() do
    if Cache.alive?() do
      Cache.get_value()
    else
      items =
        for restaurant <- @restaurants do
          case restaurant.fetch() do
            {:ok, items} -> %{name: restaurant.name(), items: items, error: nil}
            {:error, error} -> %{name: restaurant.name(), items: [], error: error}
          end
        end

      IO.inspect(items)

      Cache.set_value(items)
    end
  end

  def purge_cache() do
    Cache.purge()
  end
end
