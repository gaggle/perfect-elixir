defmodule WarehouseTest do
  use ExUnit.Case, async: true

  test "warehouse is empty when inventory has no products" do
    defmodule InventoryStub do
      def all_products(), do: []
    end

    assert Warehouse.empty?(InventoryStub) == true
  end
end
