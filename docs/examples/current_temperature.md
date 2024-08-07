# Get the current temperature at a position

This example uses the Forecast API. For more information, check the 
`sunny/api/forecast` module !

Here, the function `send` corresponds to a function that makes a HTTP request.
For that, you can use HTTP clients such as `gleam_httpc` or `gleam_fetch`.

```gleam
import gleam/dict
import gleam/io
import gleam/option

import sunny
import sunny/api/forecast
import sunny/api/forecast/data
import sunny/api/forecast/instant
import sunny/measurement
import sunny/position

pub fn current_temperature_test() {
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
      // All available variables are listed in the `sunny/api/forecast/instant` module.
      // Daily variables are in `sunny/api/forecast/daily`.
      |> forecast.set_current([instant.Temperature2m]),
    )
    // Make a HTTP request.
    |> send
    |> forecast.get_result

  let assert option.Some(data.CurrentData(data: data, ..)) =
    forecast_result.current

  let assert Ok(current_temperature) =
    data
    |> dict.get(instant.Temperature2m)

  io.println(
    "Current temperature : " <> measurement.to_string(current_temperature),
  )
}
```

