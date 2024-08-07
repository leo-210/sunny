# Get information on a city or town

This example uses the Geocoding API. For more information, check the 
`sunny/api/geocoding` module !

Here, the function `send` corresponds to a function that makes a HTTP request.
For that, you can use HTTP clients such as `gleam_httpc` or `gleam_fetch`.

```gleam
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
    |> geocoding.get_request(
      geocoding.params("marseille")
      // Changing the language can impact the search results.
      |> geocoding.set_language(geocoding.French),
    )
    // Make a HTTP request. 
    |> send
    // If the location your searching for isn't the first result, try 
    // `geocoding.get_result`
    |> geocoding.get_first_result

  // This field can be `option.None` for some places.
  let assert option.Some(population) = location.population

  io.println(
    location.name
    <> ", "
    <> location.country_code
    <> " has a population of : "
    <> int.to_string(population),
  )
}
```