defmodule ChalmersfoodWeb.PageController do
  use ChalmersfoodWeb, :controller

  alias Chalmersfood.Restaurants

  def index(conn, %{"day" => day} = params) do
    weekday = day |> String.to_integer()
    index(conn, params, weekday)
  end

  def index(conn, params) do
    {:ok, now} = DateTime.now("Europe/Stockholm")

    weekday =
      if now.hour < 14 do
        Date.day_of_week(now) - 1
      else
        Date.day_of_week(now)
      end

    index(conn, params, weekday)
  end

  defp index(conn, _params, day) do
    day = day |> max(0) |> min(4)
    render(conn, "index.html", %{day: day, restaurants: Restaurants.list()})
  end

  def refetch(conn, _params) do
    Restaurants.purge_cache()

    conn
    |> put_flash(:info, "Lunchmenyerna har hämtats på nytt!")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
