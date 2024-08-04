import sunny/api/forecast/daily
import sunny/api/forecast/hourly

pub fn hourly_to_string(h: hourly.HourlyVariable) -> String {
  case h {
    hourly.Temperature2m -> "temperature_2m"
    hourly.Temperature80m -> "temperature_80m"
    hourly.Temperature120m -> "temperature_120m"
    hourly.Temperature180m -> "temperature_180m"
    hourly.RelativeHumidity2m -> "relative_humidity_2m"
    hourly.DewPoint2m -> "dew_point_2m"
    hourly.ApparentTemperature -> "apparent_temperature"
    hourly.PressureMsl -> "pressure_msl"
    hourly.SurfacePressure -> "surface_pressure"
    hourly.CloudCover -> "cloud_cover"
    hourly.CloudCoverLow -> "cloud_cover_low"
    hourly.CloudCoverMid -> "cloud_cover_mid"
    hourly.CloudCoverHigh -> "cloud_cover_high"
    hourly.WindSpeed10m -> "wind_speed_10m"
    hourly.WindSpeed80m -> "wind_speed_80m"
    hourly.WindSpeed120m -> "wind_speed_120m"
    hourly.WindSpeed180m -> "wind_speed_180m"
    hourly.WindDirection10m -> "wind_direction_10m"
    hourly.WindDirection80m -> "wind_direction_80m"
    hourly.WindDirection120m -> "wind_direction_120m"
    hourly.WindDirection180m -> "wind_direction_180m"
    hourly.WindGusts10m -> "wind_gusts_10m"
    hourly.Precipitation -> "precipitation"
    hourly.Snowfall -> "snowfall"
    hourly.PrecipitationProbability -> "precipitation_probability"
    hourly.Rain -> "rain"
    hourly.Showers -> "showers"
    hourly.WeatherCode -> "weather_code"
    hourly.SnowDepth -> "snow_depth"
    hourly.FreezingLevelHeight -> "freezing_level_height"
    hourly.Visibility -> "visibility"
    hourly.IsDay -> "is_day"
  }
}

pub fn daily_to_string(d: daily.DailyVariable) -> String {
  case d {
    daily.MaximumTemperature2m -> "temperature_2m_max"
    daily.MinimumTemperature2m -> "temperature_2m_min"
    daily.ApparentTemperatureMax -> "apparent_temperature_max"
    daily.ApparentTemperatureMin -> "apparent_temperature_min"
    daily.PrecipitationSum -> "precipitation_sum"
    daily.RainSum -> "rain_sum"
    daily.ShowersSum -> "showers_sum"
    daily.SnowfallSum -> "snowfall_sum"
    daily.PrecipitationHours -> "precipitation_hours"
    daily.PrecipitationProbabilityMax -> "precipitation_probability_max"
    daily.PrecipitationProbabilityMin -> "precipitation_probability_min"
    daily.PrecipitationProbabilityMean -> "precipitation_probability_mean"
    daily.WorstWeatherCode -> "weather_code"
    daily.Sunrise -> "sunrise"
    daily.Sunset -> "sunset"
    daily.SunshineSuration -> "sunlight_duration"
    daily.DaylightDuration -> "daylight_duration"
    daily.WindSpeed10mMax -> "wind_speed_10m_max"
    daily.WindGusts10mMax -> "wind_gusts_10m_max"
    daily.WindDirection10mDominant -> "wind_direction_10m_dominant"
  }
}
