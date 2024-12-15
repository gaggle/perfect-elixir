defmodule StubWeatherService2 do
  def get_forecast(), do: %{rain_chance: 0.8}
end

defmodule UmbrellaForecaster2Test do
  use ExUnit.Case

  setup do: Application.put_env(:my_app, :weather_service, StubWeatherService2)

  test "recommends an umbrella when precipitation chance is high" do
    assert true = UmbrellaForecaster2.bring_umbrella?()
  end
end
