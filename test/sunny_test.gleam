import gleam/dict
import gleam/fetch
import gleam/http/request
import gleam/httpc
import gleam/javascript/promise
import gleeunit
import gleeunit/should
import sunny
import sunny/api/forecast
import sunny/api/forecast/instant
import sunny/api/geocoding

pub fn main() {
  gleeunit.main()
}

pub fn geocoding_and_forecast_test() {
  let sunny = sunny.new()

  let req =
    sunny
    |> geocoding.get_request(geocoding.params("marseille"))

  use body <- send(req)

  let position =
    geocoding.get_first_result(body)
    |> should.be_ok
    |> geocoding.location_to_position

  let req =
    sunny
    |> forecast.get_request(
      forecast.params(position)
      |> forecast.set_current([instant.Temperature2m]),
    )

  use body <- send(req)

  let forecast_result =
    forecast.get_result(body)
    |> should.be_ok

  let current =
    forecast_result.current
    |> should.be_some

  current.data
  |> dict.get(instant.Temperature2m)
  |> should.be_ok

  current.data
  |> dict.get(instant.ApparentTemperature)
  |> should.be_error
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
