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
    |> geocoding.get_first_location(
      geocoding.params("marseille")
      // Changing the language can impact the search results.
      |> geocoding.set_language(geocoding.French),
    )

  let assert option.Some(population) = location.population

  io.println(
    location.name
    <> ", "
    <> location.country_code
    <> " has a population of : "
    <> int.to_string(population),
  )
}
