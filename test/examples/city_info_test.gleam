import gleam/fetch
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/javascript/promise
import gleam/option
import sunny
import sunny/api/geocoding

pub fn city_info_test() {
  // Use `new_commercial("<your_api_key>")` if you have a commercial Open-meteo
  // API access.
  let sunny = sunny.new()

  let req =
    sunny
    // If the location your searching for isn't the first result, try 
    // `geocoding.get_locations`
    |> geocoding.get_request(
      geocoding.params("marseille")
      // Changing the language can impact the search results.
      |> geocoding.set_language(geocoding.French),
    )

  use body <- send(req)
  let assert Ok(location) = geocoding.get_first_result(body)

  let assert option.Some(population) = location.population

  io.println(
    location.name
    <> ", "
    <> location.country_code
    <> " has a population of : "
    <> int.to_string(population),
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
