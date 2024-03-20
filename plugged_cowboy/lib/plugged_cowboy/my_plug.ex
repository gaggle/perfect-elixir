defmodule PluggedCowboy.MyPlug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _options) do
    conn
    # These functions are part of the `Plug.Conn` module,
    # they're available here because we `import`ed that module
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello, World!")
  end
end
