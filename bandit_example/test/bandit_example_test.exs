defmodule BanditExampleTest do
  use ExUnit.Case
  doctest BanditExample

  test "greets the world" do
    assert BanditExample.hello() == :world
  end
end
