defmodule MyAppWeb.PageController do
  use MyAppWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    db_time = MyApp.Query.get_db_time()
    render(conn, :home, layout: false, db_time: db_time)
  end
end
