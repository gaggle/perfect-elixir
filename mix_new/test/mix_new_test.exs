defmodule MixNewTest do
  use ExUnit.Case
  doctest MixNew

  test "greets the world" do
    assert MixNew.hello() == :world
  end
end
