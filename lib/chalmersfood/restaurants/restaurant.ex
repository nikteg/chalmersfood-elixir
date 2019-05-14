defmodule Chalmersfood.Restaurants.Restaurant do
  defmacro __using__(_) do
    quote do
      alias Chalmersfood.Restaurants.Restaurant

      require Logger

      @behaviour Restaurant

      def run() do
        name = name()

        Logger.debug("[#{name}]: Fetching")

        case fetch() do
          {:ok, data} ->
            Logger.debug("[#{name}]: Parsing")

            %{name: name, items: parse(data), error: nil}

          {:error, error} ->
            Logger.error("[#{name}]: Error: #{inspect(error)}")

            %{name: name, items: [], error: error}
        end
      end
    end
  end

  @callback name() :: String.t()
  @callback fetch() :: {:ok, term} | {:error, String.t()}
  @callback parse(term) :: [[String.t()]]
end
