import gleam/dict
import gleam/float
import gleam/io
import gleam/option
import sunny
import sunny/api/forecast
import sunny/api/forecast/instant
import sunny/position
import sunny/wmo_code

const coords = position.Position(43.0, 5.0)

pub fn forecast_test() {
  let sunny = sunny.new()

  let assert Ok(forecast_result) =
    sunny
    |> forecast.get_forecast(
      forecast.params(coords) |> forecast.set_current([instant.WeatherCode]),
    )

  let assert option.Some(current_data) = forecast_result.current
  let assert Ok(weather_code) = dict.get(current_data.data, instant.WeatherCode)

  io.println(wmo_code.to_string(float.round(weather_code.value)))
}
