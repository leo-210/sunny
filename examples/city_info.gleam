import sunny
import sunny/api/geocoding

pub fn main() {
  // Use `new_commercial("<your_api_key>")` if you have a commercial Open-meteo
  // API access 
  let sunny = sunny.new()

  let assert Ok(location) =
    geocoding.get_first_location(sunny, {
      geocoding.params("marseille")
      |> geocoding.set_language(geocoding.French)
    })

  io.println(
    location.name
    <> " is located at :\n"
    <> float.to_string(location.latitude)
    <> "\n"
    <> float.to_string(location.longitude),
  )
}
