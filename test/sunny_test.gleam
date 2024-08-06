import glacier
import glacier/should
import gleam/dict
import sunny
import sunny/api/forecast
import sunny/api/forecast/instant
import sunny/api/geocoding
import sunny/measurement

pub fn main() {
  glacier.main()
}

pub fn geocoding_and_forecast_test() {
  let sunny = sunny.new()

  let position =
    sunny
    |> geocoding.get_first_location(geocoding.params("marseille"))
    |> should.be_ok
    |> geocoding.location_to_position

  let forecast_result =
    sunny
    |> forecast.get_forecast(
      forecast.params(position)
      |> forecast.set_current([instant.Temperature2m]),
    )
    |> should.be_ok

  let current =
    forecast_result.current
    |> should.be_some

  let temperature =
    current.data
    |> dict.get(instant.Temperature2m)
    |> should.be_ok

  current.data
  |> dict.get(instant.ApparentTemperature)
  |> should.be_error
}
