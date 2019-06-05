defmodule ChalmersfoodWeb.Router do
  use ChalmersfoodWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  scope "/", ChalmersfoodWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/refetch", PageController, :refetch
  end
end
