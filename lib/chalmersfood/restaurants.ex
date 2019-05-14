defmodule Chalmersfood.Restaurants do
  alias Chalmersfood.Restaurants.{Karresturangen, Express, Linsen, SMAK}
  alias Chalmersfood.Cache

  @restaurants [Karresturangen, Express, Linsen, SMAK]

  def fetch!() do
    if Cache.alive?() do
      Cache.get_value()
    else
      items =
        @restaurants
        |> Task.async_stream(& &1.run(), timeout: 10_000)
        |> Enum.map(fn {:ok, result} -> result end)

      IO.inspect(items)

      Cache.set_value(items)
    end
  end

  def purge_cache() do
    Cache.purge()
  end
end
