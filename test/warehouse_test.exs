defmodule WarehouseTest do
  use ExUnit.Case, async: true
  import InjectorTree, only: [inject: 2]
  import Double

  test "warehouse is empty when inventory has no products" do
    stub = Inventory |> stub(:all_products, fn -> [] end)
    inject(Inventory, stub)
    assert Warehouse.empty?() == true
  end
end
