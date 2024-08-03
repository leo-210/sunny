# 🌤️ Sunny (WIP)

An [Open-meteo API](https://open-meteo.com/) client written in Gleam. 

Makes it easier to get weather forecasts, current and past weather data with different models anywhere you want ! 

[![Package Version](https://img.shields.io/hexpm/v/sunny)](https://hex.pm/packages/sunny)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/sunny/)

## Installation

Add this package to your gleam project (not online yet)

```sh
gleam add sunny@1
```

### Getting the coordinates of a city
```gleam
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
    "Marseille is located at :\n"
    <> float.to_string(location.latitude)
    <> "\n"
    <> float.to_string(location.longitude),
  )
}
```

Further documentation can be found at <https://hexdocs.pm/sunny>.


## Contributing

The project is open for contributions ! Make a fork, and once you made the changes you wanted, make a PR.

### Todo 
- Weather forecast API
- Historical forecast API
- Air quality API
- Make tests to make sure nothing is breaking
