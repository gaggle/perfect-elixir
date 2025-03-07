defmodule Inventory do
  @callback all_products() :: [String.t()]
end

defmodule RealInventory do
  @behaviour Inventory
  @impl Inventory
  def all_products() do
    # pretend this does sophisticated querying and data-aggregations
    ["a"]
  end
end
