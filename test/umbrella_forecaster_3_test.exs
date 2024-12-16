defmodule StubWeatherService3 do
  def get_forecast(), do: %{rain_chance: 0.8}
end

defmodule UmbrellaForecaster3Test do
  use ExUnit.Case, async: true

  import InjectorTree, only: [inject: 2]

  test "recommends an umbrella when precipitation chance is high" do
    inject(WeatherService, StubWeatherService3)
    assert true = UmbrellaForecaster3.bring_umbrella?()
  end
end
