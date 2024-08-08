import gleam/dict
import gleam/http/request
import gleam/httpc
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

  let position =
    sunny
    |> geocoding.get_request(geocoding.params("marseille"))
    |> send
    |> geocoding.get_first_result
    |> should.be_ok
    |> geocoding.location_to_position

  let forecast_result =
    sunny
    |> forecast.get_request(
      forecast.params(position)
      |> forecast.set_current([instant.Temperature2m]),
    )
    |> send
    |> forecast.get_result
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

fn send(req: request.Request(String)) -> String {
  let assert Ok(res) = httpc.send(req)

  res.body
}
