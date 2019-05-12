defmodule Chalmersfood.Restaurants do
  alias Chalmersfood.Restaurants.{Karresturangen}

  @restaurants [Karresturangen]

  def fetch!(day \\ 0) do
    for restaurant <- @restaurants do
      case restaurant.fetch() do
        {:ok, items} -> %{name: restaurant.name(), items: Enum.at(items, day)}
        {:error, error} -> %{name: restaurant.name(), error: error}
      end
    end
  end
end
