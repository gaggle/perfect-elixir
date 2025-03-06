defmodule WarehouseTest do
  use ExUnit.Case, async: false
  import Mock

  test "warehouse is empty when inventory has no products" do
    with_mock Inventory, all_products: fn -> [] end do
      assert Warehouse.empty?() == true
    end
  end
end
