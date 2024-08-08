import birl
import gleam/float
import gleam/http/request
import gleam/httpc
import gleam/io
import gleam/list
import sunny
import sunny/api/forecast
import sunny/api/forecast/data
import sunny/api/forecast/instant
import sunny/position
import sunny/wmo_code

pub fn hourly_forecast_test() {
  // Use `new_commercial("<your_api_key>")` if you have a commercial Open-meteo
  // API access.
  let sunny = sunny.new()

  // You can get the coordinates of a place using the Geocoding API. See 
  // `sunny/api/geocoding`, or the `city_info` example.
  //
  // Once you have a `Location`, use `geocoding.location_to_position()` to
  // convert it to a position.
  let position = position.Position(43.0, 5.0)

  let assert Ok(forecast_result) =
    sunny
    |> forecast.get_request(
      forecast.params(position)
      // All available variables are listed in the `sunny/api/forecast/instant`
      // module.
      // Daily variables are in `sunny/api/forecast/daily`.
      |> forecast.set_hourly([instant.WeatherCode])
      |> forecast.set_forecast_days(1),
    )
    |> send
    |> forecast.get_result

  let assert Ok(hourly_weather) =
    forecast_result.hourly
    |> data.range_to_data_list(instant.WeatherCode)

  hourly_weather
  |> list.each(fn(timed_data) {
    io.println(
      birl.to_time_string(timed_data.time)
      <> " : "
      // `wmo_code.to_string` translates the `Int` WMOCode to a human-readable
      // `String`. 
      <> wmo_code.to_string(float.round(timed_data.data.value)),
    )
  })
}

fn send(req: request.Request(String)) -> String {
  let assert Ok(res) = httpc.send(req)

  res.body
}
