defmodule ChalmersfoodWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chalmersfood

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :chalmersfood,
    gzip: false,
    only: ~w(css fonts images js favicon.png robots.txt)

  socket "/live", Phoenix.LiveView.Socket, check_origin: ["//localhost", "//mat.sodapop.se", "//lunch.sodapop.se"]

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: Plug.Session.COOKIE,
    key: "chalmersfood",
    signing_salt: "anything"

  plug ChalmersfoodWeb.Router
end
