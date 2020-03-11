defmodule Chalmersfood.Restaurants do
  alias Chalmersfood.Restaurants.{Karresturangen, Express, Linsen, SMAK, Einstein, Wijkanders, LsKitchen, KokBoken}

  @restaurants [Karresturangen, Express, Linsen, SMAK, Einstein, LsKitchen, KokBoken]
  @lifetime 1_800_000

  use GenServer

  @impl true
  def init(restaurants) do
    {:ok, %{restaurants: restaurants, purge_ref: nil}}
  end

  def start(_default) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def start_link(_default) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def handle_call(:get_restaurants, _from, %{restaurants: []}) do
    restaurants = fetch()
    {:reply, restaurants, %{restaurants: restaurants, purge_ref: get_purge_timer()}}
  end

  @impl true
  def handle_call(:get_restaurants, _from, %{restaurants: restaurants} = state) do
    {:reply, restaurants, state}
  end

  @impl true
  def handle_call(:purge_cache, _from, %{restaurants: []} = state) do
    {:reply, :no_cache_to_purge, state}
  end

  @impl true
  def handle_call(:purge_cache, _from, %{purge_ref: purge_ref}) do
    Process.cancel_timer(purge_ref)
    {:reply, :ok, %{restaurants: [], purge_ref: get_purge_timer()}}
  end

  @impl true
  def handle_info(:purge_cache, %{purge_ref: purge_ref}) do
    Process.cancel_timer(purge_ref)
    {:noreply, %{restaurants: [], purge_ref: get_purge_timer()}}
  end

  defp get_purge_timer() do
    Process.send_after(self(), :purge_cache, @lifetime)
  end

  def list() do
    GenServer.call(__MODULE__, :get_restaurants, 35000)
  end

  def purge_cache() do
    GenServer.call(__MODULE__, :purge_cache, 10000)
  end

  defp fetch() do
    @restaurants
    |> Task.async_stream(& &1.run(), timeout: 40000, on_timeout: :kill_task)
    |> Enum.zip(@restaurants)
    |> Enum.map(fn
      {{:exit, :timeout}, restaurant} ->

      {{:ok, result}, restaurant} ->
        case result do
          {:ok, items} -> %{name: restaurant.name(), url: restaurant.url(), items: items, error: nil}
          {:error, error} -> %{name: restaurant.name(), url: restaurant.url(), items: [], error: error}
        end
    end)
  end
end
