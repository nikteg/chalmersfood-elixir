defmodule Chalmersfood.Restaurants.Einstein do
  use Tesla
  alias Chalmersfood.Restaurants.Restaurant
  use Restaurant

  plug Tesla.Middleware.Timeout, timeout: 15_000
  # plug Tesla.Middleware.Retry, delay: 500, max_retries: 10

  @impl true
  def name(), do: "Einstein"

  @impl true
  def url(), do: "http://restaurang-einstein.se/"

  @impl true
  def fetch() do
    case get("http://restaurang-einstein.se/") do
      {:ok, %{body: body}} ->
        {:ok, body}

      {:error, _} = error ->
        error
    end
  end

  @impl true
  def parse(body) do
    body
    |> Floki.find("#column_gnxhsuatx .content-wrapper .column-content")
    |> Enum.with_index()
    |> Enum.filter(fn {_elem, index} -> rem(index, 2) == 1 end)
    |> Enum.map(fn {elem, _index} -> elem end)
    |> Enum.map(fn elem ->
      elem
      |> Floki.find("p")
      |> Enum.map(&(Floki.text(&1) |> String.trim()))
      |> Enum.filter(fn text -> String.trim(text) != "" end)
    end)
    |> Enum.take(5)
  end
end
