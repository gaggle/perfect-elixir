defmodule MixNewSupTest do
  use ExUnit.Case
  doctest MixNewSup

  test "greets the world" do
    assert MixNewSup.hello() == :world
  end
end
