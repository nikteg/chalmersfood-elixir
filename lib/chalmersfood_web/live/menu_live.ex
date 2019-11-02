defmodule ChalmersfoodWeb.MenuLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(ChalmersfoodWeb.MenuView, "menu.html", assigns)
  end

  def mount(_session, socket) do
    restaurants =
      if connected?(socket) do
        Chalmersfood.Restaurants.list()
      else
        []
      end

    {:ok,
     assign(socket,
       day: 0,
       info: nil,
       error: nil,
       restaurants: restaurants
     )}
  end

  def handle_event("refetch", _event, socket) do
    Chalmersfood.Restaurants.purge_cache()

    restaurants = Chalmersfood.Restaurants.list()

    Process.send_after(self(), {:clear, :info}, 5000)

    {:noreply,
     assign(socket,
       restaurants: restaurants,
       info: "Lunchmenyerna har hämtats på nytt!"
     )}
  end

  def handle_info({:clear, key}, socket) do
    {:noreply, assign(socket, key, nil)}
  end

  def handle_params(%{"day" => day_string}, _uri, socket) do
    day = String.to_integer(day_string)

    {:noreply, assign(socket, :day, day)}
  end

  def handle_params(_params, _uri, socket) do
    day = 0
    {:noreply, assign(socket, :day, day)}
  end
end
