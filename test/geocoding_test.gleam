import gleam/list
import gleam/result
import gleeunit/should
import sunny
import sunny/api/geocoding
import sunny/errors

// gleeunit test functions end in `_test`
pub fn ok_result_test() {
  let sunny = sunny.new()

  let ok_result =
    sunny |> geocoding.get_locations(geocoding.params("marseille"))
  ok_result |> should.be_ok
}

pub fn no_result_test() {
  let sunny = sunny.new()

  let err_result = sunny |> geocoding.get_locations(geocoding.params("a"))

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

  let ok_result =
    sunny |> geocoding.get_locations(geocoding.params("marseille"))
  ok_result |> should.be_ok
}

pub fn first_location_test() {
  let sunny = sunny.new()

  let params = geocoding.params("marseille")

  let assert Ok(locations) = sunny |> geocoding.get_locations(params)

  let assert Ok(first_location) = sunny |> geocoding.get_first_location(params)

  use first_location2 <- result.map(list.first(locations))
  first_location
  |> should.equal(first_location2)
  |> Ok
}
