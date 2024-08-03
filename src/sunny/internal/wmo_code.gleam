pub type WMOCode {
  WMOCode(code: Int)
}

// See https://open-meteo.com/en/docs (at the bottom of the page).
pub fn to_string(code: WMOCode) {
  case code.code {
    0 -> "Clear sky"

    1 -> "Mainly clear"
    2 -> "Partly cloudy"
    3 -> "Overcast"

    45 -> "Fog"
    48 -> "Depositing rime fog"

    51 -> "Light drizzle"
    53 -> "Moderate drizzle"
    55 -> "Dense drizzle"

    56 -> "Light freezing drizzle"
    57 -> "Dense freezing drizzle"

    61 -> "Slight rain"
    63 -> "Moderate rain"
    65 -> "Heavy rain"

    66 -> "Light freezing rain"
    67 -> "Heavy freezing rain"

    71 -> "Slight snow"
    73 -> "Moderate snow"
    75 -> "Heavy snow"

    77 -> "Snow grains"

    80 -> "Slight rain shower"
    81 -> "Moderate rain shower"
    82 -> "Violent rain shower"

    85 -> "Slight snow shower"
    86 -> "Heavy snow shower"

    95 -> "Slight or moderate thunderstorm"
    96 -> "Thunderstorm with slight hail"
    99 -> "Thunderstorm with heavy hail"

    _ -> "Unknown WMO code"
  }
}
