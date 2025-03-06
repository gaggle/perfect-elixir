defmodule Warehouse do
  def empty?(inventory), do: inventory.all_products() == []
end
