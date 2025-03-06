defmodule Warehouse do
  def empty?(), do: Inventory.all_products() == []
end
