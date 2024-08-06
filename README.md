# 🌤️ Sunny

An [Open-meteo API](https://open-meteo.com/) client written in Gleam. 

Makes it easier to get weather forecasts, current and past weather data with different models anywhere you want ! 

[![Package Version](https://img.shields.io/hexpm/v/sunny)](https://hex.pm/packages/sunny)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/sunny/)

## Installation

Add this package to your gleam project (not online yet)

```sh
gleam add sunny
```

### Getting the current temperature in a city
<details open>
  <summary>Example code</summary>

```gleam
import gleam/dict
import gleam/io
import gleam/option

import sunny
import sunny/api/forecast
import sunny/api/forecast/instant
import sunny/api/geocoding
import sunny/measurement

pub fn main() {
  let sunny = sunny.new()

  let assert Ok(location) =
    sunny
    |> geocoding.get_first_location(
      geocoding.params("marseille")
      |> geocoding.set_language(geocoding.French),
    )

  let assert Ok(forecast_result) =
    sunny
    |> forecast.get_forecast(
      forecast.params(geocoding.location_to_position(location))
      |> forecast.set_current([instant.Temperature2m]),
    )

  let assert option.Some(current_data) = forecast_result.current

  let assert Ok(temperature) =
    current_data.data |> dict.get(instant.Temperature2m)

  io.println(
    location.name
    <> "'s current temperature is : "
    <> measurement.to_string(temperature),
  )
}
```
</details>

More examples in the `test/examples` directory

Further documentation can be found at <https://hexdocs.pm/sunny>.


## Contributing

Contributions are very welcome ! Make a fork, and once you made the changes you wanted, make a PR.

### Todo 
- Historical forecast API
- Air quality API
