defmodule UmbrellaForecaster1 do
  def bring_umbrella?(weather_service \\ WeatherService) do
    %{rain_chance: rain_chance} = weather_service.get_forecast()
    rain_chance > 0.5
  end
end

#defmodule UmbrellaForecaster1 do
#  def bring_umbrella?(opts \\ []) do
#    weather_service = Keyword.get(opts, :weather_service, WeatherService)
#    %{rain_chance: rain_chance} = weather_service.get_forecast()
#    rain_chance > 0.5
#  end
#end
