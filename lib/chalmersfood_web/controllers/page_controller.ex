defmodule ChalmersfoodWeb.PageController do
  use ChalmersfoodWeb, :controller

  alias Chalmersfood.Restaurants

  def index(conn, params) do
    now = DateTime.utc_now()

    weekday =
      if now.hour < 15 do
        Date.day_of_week(now) - 1
      else
        Date.day_of_week(now)
      end

    day = Map.get(params, "day", div(weekday, 4))

    restaurants =
      Restaurants.fetch!(day)
      |> IO.inspect()

    render(conn, "index.html", %{day: day, restaurants: restaurants})
  end
end
