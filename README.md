# Sunny

An Open-meteo API client written in Gleam

[![Package Version](https://img.shields.io/hexpm/v/sunny)](https://hex.pm/packages/sunny)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/sunny/)

```sh
gleam add sunny@1
```
```gleam
import sunny

pub fn main() {
  // Use `new_commercial("<your_api_key>")` if you have a commercial Open-meteo
  // API access 
  let sunny = client.new()

  let assert Ok(location) =
    get_first_location(sunny, {
      geocoding.params("marseille")
      |> geocoding.set_language(geocoding.French)
    })

  io.println(
    "Marseille is located at :"
    <> float.to_string(location.latitude)
    <> "\n"
    <> float.to_string(location.longitude),
  )
}
```

Further documentation can be found at <https://hexdocs.pm/sunny>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
