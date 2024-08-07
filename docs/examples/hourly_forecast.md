# Get the hourly forecast for the current day at a position

This example uses the Forecast API. For more information, check the 
`sunny/api/forecast` module !

Here, the function `send` corresponds to a function that makes a HTTP request.
For that, you can use HTTP clients such as `gleam_httpc` or `gleam_fetch`.

```gleam
import birl

import gleam/float
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

  // You can get the coordinates of a place using the Geocoding API. See the
  // `sunny/api/geocoding` module, or the `city_info` example.
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
    // Make a HTTP request.
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
```