defmodule Warehouse do
  import InjectorTree, only: [provide: 1]

  def empty?(), do: provide(Inventory).all_products() == []
end
