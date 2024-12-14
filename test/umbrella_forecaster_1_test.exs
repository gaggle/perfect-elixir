defmodule StubWeatherService1 do
  def get_forecast(), do: %{rain_chance: 0.8}
end

defmodule UmbrellaForecaster1Test do
  use ExUnit.Case, async: true

  test "recommends an umbrella when precipitation chance is high" do
    assert true = UmbrellaForecaster1.bring_umbrella?(StubWeatherService1)
  end
end
