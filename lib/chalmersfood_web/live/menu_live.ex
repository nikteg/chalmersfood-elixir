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
       menu_open: false,
       day: get_today(),
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

  def handle_event("toggle_menu", _event, socket) do
    {:noreply, assign(socket, menu_open: !socket.assigns.menu_open)}
  end

  def handle_info({:clear, key}, socket) do
    {:noreply, assign(socket, key, nil)}
  end

  def handle_params(%{"day" => day_string}, _uri, socket) do
    day = String.to_integer(day_string)

    {:noreply, assign(socket, :day, day)}
  end

  def handle_params(_params, _uri, socket) do
    day = get_today()
    {:noreply, assign(socket, :day, day)}
  end

  def get_today() do
    {:ok, now} = DateTime.now("Europe/Stockholm")

    weekday =
      if now.hour < 14 do
        Date.day_of_week(now) - 1
      else
        Date.day_of_week(now)
      end

    weekday |> max(0) |> min(4)
  end
end
