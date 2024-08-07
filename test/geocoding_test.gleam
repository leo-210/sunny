import glacier/should
import gleam/fetch
import gleam/http/request
import gleam/httpc
import gleam/javascript/promise
import gleam/list
import gleam/result
import sunny
import sunny/api/geocoding
import sunny/errors

pub fn ok_result_test() {
  let sunny = sunny.new()

  let req =
    sunny
    |> geocoding.get_request(geocoding.params("marseille"))

  use body <- send(req)

  geocoding.get_result(body)
  |> should.be_ok

  Nil
}

pub fn no_result_test() {
  let sunny = sunny.new()

  let req =
    sunny
    |> geocoding.get_request(geocoding.params("a"))

  use body <- send(req)
  let err_result = geocoding.get_result(body)

  err_result |> should.be_error

  {
    use err <- result.map_error(err_result)
    err
    |> should.equal(
      errors.ApiError(errors.NoResultsError("Geocoding search gave no results")),
    )
  }
  Nil
}

pub fn commercial_test() {
  // Any API key should work, because the API still returns results even if it
  // is incorrect.
  let sunny = sunny.new_commercial("api_key")

  let req =
    sunny
    |> geocoding.get_request(geocoding.params("marseille"))

  use body <- send(req)
  geocoding.get_result(body) |> should.be_ok

  Nil
}

pub fn first_location_test() {
  let sunny = sunny.new()

  let params = geocoding.params("marseille")

  let req =
    sunny
    |> geocoding.get_request(params)

  use body <- send(req)
  let assert Ok(locations) = geocoding.get_result(body)

  let req =
    sunny
    |> geocoding.get_request(params)

  use body <- send(req)
  let assert Ok(first_location) = geocoding.get_first_result(body)

  let assert [first_position2, ..] = locations

  first_position2
  |> should.equal(first_location)

  Nil
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
