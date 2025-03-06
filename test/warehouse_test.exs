defmodule WarehouseTest do
  use ExUnit.Case, async: true
  import InjectorTree, only: [inject: 2]

  setup do: inject(RealInventory, FakeInventory)

  test "warehouse is empty when inventory has no products" do
    assert Warehouse.empty?() == true
  end
end
