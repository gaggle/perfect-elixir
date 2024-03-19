defmodule MyApp.Query do
  import Ecto.Query

  alias MyApp.Repo

  def get_db_time do
    # This uses a fragment to inject raw SQL, the SELECT 1 is a dummy table to perform a query without a table
    query = from u in fragment("SELECT 1"), select: fragment("NOW()")
    query |> Repo.all() |> List.first()
  end
end
