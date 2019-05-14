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
        |> Task.async_stream(& &1.run(), timeout: 20000, on_timeout: :kill_task)
        |> Enum.zip(@restaurants)
        |> Enum.map(fn
          {{:exit, :timeout}, restaurant} ->
            %{name: restaurant.name(), items: [], error: :timeout}

          {{:ok, result}, restaurant} ->
            case result do
              {:ok, items} -> %{name: restaurant.name(), items: items, error: nil}
              {:error, error} -> %{name: restaurant.name(), items: [], error: error}
            end
        end)

      Cache.set_value(items)
    end
  end

  def purge_cache() do
    Cache.purge()
  end
end
