defmodule WarehouseTest do
  use ExUnit.Case, async: false

  setup do
    defmodule InventoryStub do
      def all_products(), do: []
    end

    Application.put_env(:myapp, :inventory, InventoryStub)
  end

  test "warehouse is empty when inventory has no products" do
    assert Warehouse.empty?() == true
  end
end
