import birl
import gleam/dict
import gleam/dynamic.{dict, field, float, int, list, optional_field, string}
import gleam/json
import gleam/option
import gleam/result
import sunny/api/forecast/daily
import sunny/api/forecast/instant
import sunny/errors
import sunny/internal/utils
import sunny/measurement

pub type RawForecastResult {
  RawForecastResult(
    latitude: Float,
    longitude: Float,
    elevation: Float,
    utc_offset_seconds: Int,
    timezone: String,
    timezone_abbreviation: String,
    hourly: option.Option(dict.Dict(String, List(String))),
    hourly_units: option.Option(dict.Dict(String, String)),
    daily: option.Option(dict.Dict(String, List(String))),
    daily_units: option.Option(dict.Dict(String, String)),
    minutely: option.Option(dict.Dict(String, List(String))),
    minutely_units: option.Option(dict.Dict(String, String)),
    current: option.Option(dict.Dict(String, String)),
    current_units: option.Option(dict.Dict(String, String)),
  )
}

pub type TimeRangedData {
  TimeRangedData(
    data: dict.Dict(String, dict.Dict(birl.Time, measurement.Measurement)),
  )
}

pub type CurrentData {
  CurrentData(time: birl.Time, data: dict.Dict(String, measurement.Measurement))
}

pub fn raw_forecast_result_from_json(
  json_string: String,
) -> Result(RawForecastResult, errors.SunnyError) {
  let forecast_decoder =
    utils.decode14(
      RawForecastResult,
      field("latitude", float),
      field("longitude", float),
      field("elevation", float),
      field("utc_offset_seconds", int),
      field("timezone", string),
      field("timezone_abbreviation", string),
      optional_field("hourly", dict(string, list(string))),
      optional_field("hourly_units", dict(string, string)),
      optional_field("daily", dict(string, list(string))),
      optional_field("daily_units", dict(string, string)),
      optional_field("minutely_15", dict(string, list(string))),
      optional_field("minutely_15_units", dict(string, string)),
      optional_field("current", dict(string, string)),
      optional_field("current_15_units", dict(string, string)),
    )
  json.decode(from: json_string, using: forecast_decoder)
  |> result.map_error(fn(e) { errors.DecodeError(e) })
}

pub fn instant_to_string(h: instant.InstantVariable) -> String {
  case h {
    instant.Temperature2m -> "temperature_2m"
    instant.Temperature80m -> "temperature_80m"
    instant.Temperature120m -> "temperature_120m"
    instant.Temperature180m -> "temperature_180m"
    instant.RelativeHumidity2m -> "relative_humidity_2m"
    instant.DewPoint2m -> "dew_point_2m"
    instant.ApparentTemperature -> "apparent_temperature"
    instant.PressureMsl -> "pressure_msl"
    instant.SurfacePressure -> "surface_pressure"
    instant.CloudCover -> "cloud_cover"
    instant.CloudCoverLow -> "cloud_cover_low"
    instant.CloudCoverMid -> "cloud_cover_mid"
    instant.CloudCoverHigh -> "cloud_cover_high"
    instant.WindSpeed10m -> "wind_speed_10m"
    instant.WindSpeed80m -> "wind_speed_80m"
    instant.WindSpeed120m -> "wind_speed_120m"
    instant.WindSpeed180m -> "wind_speed_180m"
    instant.WindDirection10m -> "wind_direction_10m"
    instant.WindDirection80m -> "wind_direction_80m"
    instant.WindDirection120m -> "wind_direction_120m"
    instant.WindDirection180m -> "wind_direction_180m"
    instant.WindGusts10m -> "wind_gusts_10m"
    instant.Precipitation -> "precipitation"
    instant.Snowfall -> "snowfall"
    instant.PrecipitationProbability -> "precipitation_probability"
    instant.Rain -> "rain"
    instant.Showers -> "showers"
    instant.WeatherCode -> "weather_code"
    instant.SnowDepth -> "snow_depth"
    instant.FreezingLevelHeight -> "freezing_level_height"
    instant.Visibility -> "visibility"
    instant.IsDay -> "is_day"
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
