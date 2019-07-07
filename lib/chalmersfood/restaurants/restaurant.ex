defmodule Chalmersfood.Restaurants.Restaurant do
  defmacro __using__(_) do
    quote do
      alias Chalmersfood.Restaurants.Restaurant

      require Logger

      @behaviour Restaurant

      def run() do
        case fetch() do
          {:ok, data} -> {:ok, parse(data)}
          {:error, _} = error -> error
        end
      end
    end
  end

  @callback name() :: String.t()
  @callback url() :: String.t()
  @callback fetch() :: {:ok, term} | {:error, String.t()}
  @callback parse(term) :: [[String.t()]]
end
