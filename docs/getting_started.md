# Getting started

First, make sure you added the `sunny` package to your gleam project !
```
gleam add sunny
```

To start interacting with the diffent Open-meteo (OM) APIs, you need to create a new sunny client :
```gleam
import sunny

pub fn main() {
  let sunny = sunny.new()
}
```
<details>
  <summary>If you have a commercial access to Open-meteo</summary>
```gleam
  let sunny = sunny.new_commercial("<your_api_key>")
```
</details>

## Using the APIs

Now you can start using the other APIs :
- Forecast API : Get a lot a of diverse data on the current and future weather 
conditions anywhere you want.
- Geocoding API : Get information on a city or town. Useful for getting the coordinates of a place, to then get the forecast there.

More APIs will be supported in the future.

You can check the various [examples](examples.html) to get an idea of how to use the APIs.
