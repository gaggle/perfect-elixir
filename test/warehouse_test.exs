defmodule WarehouseTest do
  use ExUnit.Case, async: true
  import InjectorTree, only: [inject: 2]
  import Hammox

  test "warehouse is empty when inventory has no products" do
    mock =
      defmock(InventoryMock, for: Inventory)
      |> stub(:all_products, fn -> [] end)

    inject(RealInventory, mock)
    assert Warehouse.empty?() == true
  end
end
