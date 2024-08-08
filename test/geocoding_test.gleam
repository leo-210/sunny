import gleam/http/request
import gleam/httpc
import gleam/result
import gleeunit/should
import sunny
import sunny/api/geocoding
import sunny/errors

pub fn ok_result_test() {
  let sunny = sunny.new()

  sunny
  |> geocoding.get_request(geocoding.params("marseille"))
  |> send
  |> geocoding.get_result
  |> should.be_ok
}

pub fn no_result_test() {
  let sunny = sunny.new()

  let err_result =
    sunny
    // According to the docs, a one character search gives no results.
    |> geocoding.get_request(geocoding.params("a"))
    |> send
    |> geocoding.get_result

  err_result |> should.be_error

  use err <- result.map_error(err_result)
  err
  |> should.equal(
    errors.ApiError(errors.NoResultsError("Geocoding search gave no results")),
  )
}

pub fn commercial_test() {
  // Any API key should work, because the API still returns results even if it
  // is incorrect.
  let sunny = sunny.new_commercial("api_key")

  sunny
  |> geocoding.get_request(geocoding.params("marseille"))
  |> send
  |> geocoding.get_result
  |> should.be_ok
}

pub fn first_location_test() {
  let sunny = sunny.new()

  let params = geocoding.params("marseille")

  let assert Ok(locations) =
    sunny
    |> geocoding.get_request(params)
    |> send
    |> geocoding.get_result

  let assert Ok(first_location) =
    sunny
    |> geocoding.get_request(params)
    |> send
    |> geocoding.get_first_result

  let assert [first_position2, ..] = locations

  first_position2
  |> should.equal(first_location)
}

fn send(req: request.Request(String)) -> String {
  let assert Ok(res) = httpc.send(req)

  res.body
}
