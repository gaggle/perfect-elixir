defmodule WarehouseTest do
  use ExUnit.Case, async: true
  import InjectorTree, only: [inject: 2]

  setup do
    defmodule InventoryStub do
      def all_products(), do: []
    end

    inject(Inventory, InventoryStub)
  end

  test "warehouse is empty when inventory has no products" do
    assert Warehouse.empty?() == true
  end
end
