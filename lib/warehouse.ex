defmodule Warehouse do
  import InjectorTree, only: [provide: 1]

  def empty?(), do: provide(RealInventory).all_products() == []
end
