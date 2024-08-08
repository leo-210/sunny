import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/option
import sunny
import sunny/api/geocoding

pub fn city_info_test() {
  // Use `new_commercial("<your_api_key>")` if you have a commercial Open-meteo
  // API access.
  let sunny = sunny.new()

  let assert Ok(location) =
    sunny
    // If the location your searching for isn't the first result, try 
    // `geocoding.get_locations`
    |> geocoding.get_request(
      geocoding.params("marseille")
      // Changing the language can impact the search results.
      |> geocoding.set_language(geocoding.French),
    )
    |> send
    |> geocoding.get_first_result

  let assert option.Some(population) = location.population

  io.println(
    location.name
    <> ", "
    <> location.country_code
    <> " has a population of : "
    <> int.to_string(population),
  )
}

fn send(req: request.Request(String)) -> String {
  let assert Ok(res) = httpc.send(req)

  res.body
}
