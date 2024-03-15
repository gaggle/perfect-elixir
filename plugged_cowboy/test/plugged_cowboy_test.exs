defmodule PluggedCowboyTest do
  use ExUnit.Case
  doctest PluggedCowboy

  test "greets the world" do
    assert PluggedCowboy.hello() == :world
  end
end
