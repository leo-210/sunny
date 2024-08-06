import gleam/dict
import gleam/list
import gleam/option
import gleeunit/should
import sunny
import sunny/api/forecast
import sunny/api/forecast/daily
import sunny/api/forecast/instant
import sunny/position

const coords = position.Position(43.0, 5.0)

pub fn hourly_all_test() {
  let sunny = sunny.new()

  let assert Ok(forecast_result) =
    sunny
    |> forecast.get_forecast(
      forecast.params(coords)
      |> forecast.set_all_hourly([]),
    )

  use var <- list.each(instant.all)
  let l =
    forecast_result.hourly.data
    |> dict.get(var)
    |> should.be_ok

  list.length(l)
  |> should.equal(list.length(forecast_result.hourly.time))
}

pub fn daily_all_test() {
  let sunny = sunny.new()

  let assert Ok(forecast_result) =
    sunny
    |> forecast.get_forecast(
      forecast.params(coords)
      |> forecast.set_all_daily([]),
    )

  use var <- list.each(daily.all)
  let l =
    forecast_result.daily.data
    |> dict.get(var)
    |> should.be_ok

  list.length(l)
  |> should.equal(list.length(forecast_result.daily.time))
}

pub fn minutely_all_test() {
  let sunny = sunny.new()

  let assert Ok(forecast_result) =
    sunny
    |> forecast.get_forecast(
      forecast.params(coords) |> forecast.set_all_minutely([]),
    )

  use var <- list.each(instant.all)
  let l =
    forecast_result.minutely.data
    |> dict.get(var)
    |> should.be_ok

  list.length(l)
  |> should.equal(list.length(forecast_result.minutely.time))
}

pub fn current_all_test() {
  let sunny = sunny.new()

  let assert Ok(forecast_result) =
    sunny
    |> forecast.get_forecast(
      forecast.params(coords) |> forecast.set_all_current([]),
    )

  let assert option.Some(current) = forecast_result.current

  use var <- list.each(instant.all)
  current.data
  |> dict.get(var)
  |> should.be_ok
}

pub fn none_test() {
  let sunny = sunny.new()

  let assert Ok(forecast_result) =
    sunny
    |> forecast.get_forecast(forecast.params(coords))

  forecast_result.hourly.time
  |> list.is_empty
  |> should.be_true

  forecast_result.daily.time
  |> list.is_empty
  |> should.be_true

  forecast_result.minutely.time
  |> list.is_empty
  |> should.be_true

  forecast_result.current
  |> should.be_none

  {
    use var <- list.each(instant.all)
    forecast_result.hourly.data
    |> dict.get(var)
    |> should.be_error

    forecast_result.minutely.data
    |> dict.get(var)
    |> should.be_error
  }

  use var <- list.each(daily.all)
  forecast_result.daily.data
  |> dict.get(var)
  |> should.be_error
}
