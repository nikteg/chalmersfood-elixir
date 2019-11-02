defmodule ChalmersfoodWeb.PageController do
  use ChalmersfoodWeb, :controller

  alias Chalmersfood.Restaurants

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def refetch(conn, _params) do
    Restaurants.purge_cache()

    put_status(conn, :ok)
  end

  def fetch(conn, _params) do
    json(conn, Restaurants.list())
  end
end
