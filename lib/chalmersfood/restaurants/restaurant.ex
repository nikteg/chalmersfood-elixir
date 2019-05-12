defmodule Chalmersfood.Restaurants.Restaurant do
  @callback name() :: String.t
  @callback fetch() :: {:ok, term} | {:error, String.t}
  @callback parse(term) :: [[String.t]]

  def run!(impl) do
    case impl.fetch() do
      {:ok, data} -> impl.parse(data)
      {:error, error} -> raise error
    end
  end
end
