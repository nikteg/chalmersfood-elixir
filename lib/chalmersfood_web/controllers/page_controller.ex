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
    render(conn, "index.html", %{day: rem(day, 5), restaurants: Restaurants.list()})
  end

  def purge(conn, _params) do
    Restaurants.purge_cache()

    conn
    |> put_flash(:info, "The cache has been purged and fresh data has been fetched!")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
