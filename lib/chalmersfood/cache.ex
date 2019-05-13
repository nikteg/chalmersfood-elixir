defmodule Chalmersfood.Cache do
  use GenServer

  @lifetime 1_800_000

  def init(initial_value) do
    {:ok, %{value: initial_value, purge_ref: nil}}
  end

  def start_link(_default) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def handle_call({:set_value, value}, _from, %{purge_ref: nil}) do
    {:reply, :ok, %{value: value, purge_ref: set_purge_timer(@lifetime)}}
  end

  def handle_call({:set_value, value}, _from, %{purge_ref: purge_ref}) do
    Process.cancel_timer(purge_ref)
    {:reply, :ok, %{value: value, purge_ref: set_purge_timer(@lifetime)}}
  end

  def handle_call(:get_value, _from, %{value: value} = state) do
    {:reply, value, state}
  end

  def handle_info(:purge_cache, %{purge_ref: purge_ref}) do
    Process.cancel_timer(purge_ref)
    {:noreply, %{value: nil, purge_ref: set_purge_timer(@lifetime)}}
  end

  defp set_purge_timer(time) do
    Process.send_after(self(), :purge_cache, time)
  end

  def set_value(value) do
    GenServer.call(__MODULE__, {:set_value, value})

    value
  end

  def get_value() do
    GenServer.call(__MODULE__, :get_value)
  end

  def alive?() do
    GenServer.call(__MODULE__, :get_value) != nil
  end

  def purge() do
    set_value(nil)
  end
end
