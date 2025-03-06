defmodule Math do
  def multiply(a, b), do: a * b
end

defmodule MathTest do
  use ExUnit.Case

  test "multiplying two numbers returns their product" do
    assert Math.multiply(2, 3) == 6
  end
end
