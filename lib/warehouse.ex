defmodule Warehouse do
  def empty?(), do: inventory_impl().all_products() == []
  defp inventory_impl(), do: Application.get_env(:myapp, :inventory, Inventory)
end
