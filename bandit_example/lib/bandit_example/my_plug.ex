defmodule BanditExample.MyPlug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _options) do
    {:ok, %Postgrex.Result{rows: [[current_time]]}} =
      Postgrex.query(:bandit_db, "SELECT NOW() as current_time", [])

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello, World! It's #{current_time}")
  end
end
