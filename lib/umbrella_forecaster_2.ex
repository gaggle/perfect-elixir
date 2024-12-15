defmodule UmbrellaForecaster2 do
  def bring_umbrella?() do
    weather_service = Application.get_env(:my_app, :weather_service, WeatherService)
    %{rain_chance: rain_chance} = weather_service.get_forecast()
    rain_chance > 0.5
  end
end
