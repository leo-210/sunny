import gleam/dict
import gleam/fetch
import gleam/http/request
import gleam/httpc
import gleam/io
import gleam/javascript/promise
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

  // You can get the coordinates of a place using the Geocoding API. See 
  // `sunny/api/geocoding`, or the `city_info` example.
  //
  // Once you have a `Location`, use `geocoding.location_to_position()` to
  // convert it to a position.
  let position = position.Position(43.0, 5.0)

  let req =
    sunny
    |> forecast.get_request(
      forecast.params(position)
      // All available variables are listed in the `sunny/api/forecast/instant` module.
      // Daily variables are in `sunny/api/forecast/daily`.
      |> forecast.set_current([instant.Temperature2m]),
    )

  use body <- send(req)
  let assert Ok(forecast_result) = forecast.get_result(body)

  let assert option.Some(data.CurrentData(data: data, ..)) =
    forecast_result.current

  let assert Ok(current_temperature) =
    data
    |> dict.get(instant.Temperature2m)

  io.println(
    "Current temperature : " <> measurement.to_string(current_temperature),
  )
}

@target(erlang)
fn send(req: request.Request(String), callback: fn(String) -> Nil) -> Nil {
  let assert Ok(res) = httpc.send(req)

  callback(res.body)
}

@target(javascript)
fn send(req: request.Request(String), callback: fn(String) -> Nil) -> Nil {
  {
    use resp <- promise.try_await(fetch.send(req))
    use resp <- promise.try_await(fetch.read_text_body(resp))

    callback(resp.body)
    promise.resolve(Ok(Nil))
  }
  Nil
}
