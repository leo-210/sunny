import glacier/should
import gleam/dict
import gleam/fetch
import gleam/http/request
import gleam/httpc
import gleam/javascript/promise
import gleam/list
import gleam/option
import sunny
import sunny/api/forecast
import sunny/api/forecast/daily
import sunny/api/forecast/instant
import sunny/position

const coords = position.Position(43.0, 5.0)

pub fn hourly_all_test() {
  let sunny = sunny.new()

  let req =
    sunny
    |> forecast.get_request(
      forecast.params(coords)
      |> forecast.set_all_hourly([]),
    )

  use body <- send(req)
  let assert Ok(forecast_result) = forecast.get_result(body)

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

  let req =
    sunny
    |> forecast.get_request(
      forecast.params(coords)
      |> forecast.set_all_daily([]),
    )

  use body <- send(req)
  let assert Ok(forecast_result) = forecast.get_result(body)

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

  let req =
    sunny
    |> forecast.get_request(
      forecast.params(coords) |> forecast.set_all_minutely([]),
    )

  use body <- send(req)
  let assert Ok(forecast_result) = forecast.get_result(body)

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

  let req =
    sunny
    |> forecast.get_request(
      forecast.params(coords) |> forecast.set_all_current([]),
    )

  use body <- send(req)
  let assert Ok(forecast_result) = forecast.get_result(body)

  let assert option.Some(current) = forecast_result.current

  use var <- list.each(instant.all)
  current.data
  |> dict.get(var)
  |> should.be_ok
}

pub fn none_test() {
  let sunny = sunny.new()

  let req =
    sunny
    |> forecast.get_request(forecast.params(coords))

  use body <- send(req)
  let assert Ok(forecast_result) = forecast.get_result(body)

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
