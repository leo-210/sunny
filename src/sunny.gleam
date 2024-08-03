import gleam/float
import gleam/io
import sunny/api/geocoding
import sunny/internal/client.{type Client, Client}
import sunny/internal/defaults

/// Creates a new Open-meteo client with the default values (you probably won't
/// need anything more).
/// 
/// If you have a commercial Open-meteo API acess, check out `new_commercial`.
/// 
/// To change some client parameters (such as the base url), check out the
/// `sunny/client` module.
pub fn new() -> Client {
  Client(defaults.base_url, False, "")
}

/// Creates a new commercial Open-meteo client with the default values
/// Takes your Open-meteo api key as an argument.
pub fn new_commercial(key: String) -> Client {
  Client(defaults.base_url, True, key)
}

pub fn main() {
  // Use `new_commercial("<your_api_key>")` if you have a commercial Open-meteo
  // API access 
  let sunny = new_commercial("lol")

  let assert Ok(location) =
    geocoding.get_first_location(sunny, {
      geocoding.params("marseille")
      |> geocoding.set_language(geocoding.French)
    })

  io.println(
    "Marseille is located at :\n"
    <> float.to_string(location.latitude)
    <> "\n"
    <> float.to_string(location.longitude),
  )
}
