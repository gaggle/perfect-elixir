defmodule UmbrellaForecaster3 do
  import InjectorTree, only: [provide: 1]

  def bring_umbrella?() do
    weather_service = provide(WeatherService)
    %{rain_chance: rain_chance} = weather_service.get_forecast()
    rain_chance > 0.5
  end
end
