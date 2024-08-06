import birl
import gleam/dict
import gleam/dynamic.{dict, field, float, int, list, optional_field, string}
import gleam/float
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import sunny/api/forecast/daily
import sunny/api/forecast/data
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

pub fn raw_forecast_result_from_json(
  json_string: String,
) -> Result(RawForecastResult, errors.SunnyError) {
  let any_of_string_or_int_or_float =
    dynamic.any([
      string,
      fn(x) { result.map(float(x), fn(f) { float.to_string(f) }) },
      fn(x) { result.map(int(x), fn(n) { int.to_string(n) }) },
    ])

  let forecast_decoder =
    utils.decode14(
      RawForecastResult,
      field("latitude", float),
      field("longitude", float),
      field("elevation", float),
      field("utc_offset_seconds", int),
      field("timezone", string),
      field("timezone_abbreviation", string),
      optional_field(
        "hourly",
        dict(string, list(any_of_string_or_int_or_float)),
      ),
      optional_field("hourly_units", dict(string, string)),
      optional_field("daily", dict(string, list(any_of_string_or_int_or_float))),
      optional_field("daily_units", dict(string, string)),
      optional_field(
        "minutely_15",
        dict(string, list(any_of_string_or_int_or_float)),
      ),
      optional_field("minutely_15_units", dict(string, string)),
      optional_field("current", dict(string, any_of_string_or_int_or_float)),
      optional_field("current_units", dict(string, string)),
    )
  json.decode(from: json_string, using: forecast_decoder)
  |> result.map_error(fn(e) { errors.DecodeError(e) })
}

pub fn instant_to_string(var: instant.InstantVariable) -> String {
  case var {
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

pub fn string_to_instant(
  s: String,
) -> Result(instant.InstantVariable, errors.InternalError) {
  case s {
    "temperature_2m" -> instant.Temperature2m |> Ok()
    "temperature_80m" -> instant.Temperature80m |> Ok()
    "temperature_120m" -> instant.Temperature120m |> Ok()
    "temperature_180m" -> instant.Temperature180m |> Ok()
    "relative_humidity_2m" -> instant.RelativeHumidity2m |> Ok()
    "dew_point_2m" -> instant.DewPoint2m |> Ok()
    "apparent_temperature" -> instant.ApparentTemperature |> Ok()
    "pressure_msl" -> instant.PressureMsl |> Ok()
    "surface_pressure" -> instant.SurfacePressure |> Ok()
    "cloud_cover" -> instant.CloudCover |> Ok()
    "cloud_cover_low" -> instant.CloudCoverLow |> Ok()
    "cloud_cover_mid" -> instant.CloudCoverMid |> Ok()
    "cloud_cover_high" -> instant.CloudCoverHigh |> Ok()
    "wind_speed_10m" -> instant.WindSpeed10m |> Ok()
    "wind_speed_80m" -> instant.WindSpeed80m |> Ok()
    "wind_speed_120m" -> instant.WindSpeed120m |> Ok()
    "wind_speed_180m" -> instant.WindSpeed180m |> Ok()
    "wind_direction_10m" -> instant.WindDirection10m |> Ok()
    "wind_direction_80m" -> instant.WindDirection80m |> Ok()
    "wind_direction_120m" -> instant.WindDirection120m |> Ok()
    "wind_direction_180m" -> instant.WindDirection180m |> Ok()
    "wind_gusts_10m" -> instant.WindGusts10m |> Ok()
    "precipitation" -> instant.Precipitation |> Ok()
    "snowfall" -> instant.Snowfall |> Ok()
    "precipitation_probability" -> instant.PrecipitationProbability |> Ok()
    "rain" -> instant.Rain |> Ok()
    "showers" -> instant.Showers |> Ok()
    "weather_code" -> instant.WeatherCode |> Ok()
    "snow_depth" -> instant.SnowDepth |> Ok()
    "freezing_level_height" -> instant.FreezingLevelHeight |> Ok()
    "visibility" -> instant.Visibility |> Ok()
    "is_day" -> instant.IsDay |> Ok()
    _ ->
      Error(errors.InternalError(
        "Unexpected error : string_to_instant(\"" <> s <> "\")",
      ))
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
    //daily.Sunrise -> "sunrise"
    //daily.Sunset -> "sunset"
    daily.SunshineSuration -> "sunshine_duration"
    daily.DaylightDuration -> "daylight_duration"
    daily.WindSpeed10mMax -> "wind_speed_10m_max"
    daily.WindGusts10mMax -> "wind_gusts_10m_max"
    daily.WindDirection10mDominant -> "wind_direction_10m_dominant"
  }
}

pub fn string_to_daily(
  s: String,
) -> Result(daily.DailyVariable, errors.InternalError) {
  case s {
    "temperature_2m_max" -> daily.MaximumTemperature2m |> Ok()
    "temperature_2m_min" -> daily.MinimumTemperature2m |> Ok()
    "apparent_temperature_max" -> daily.ApparentTemperatureMax |> Ok()
    "apparent_temperature_min" -> daily.ApparentTemperatureMin |> Ok()
    "precipitation_sum" -> daily.PrecipitationSum |> Ok()
    "rain_sum" -> daily.RainSum |> Ok()
    "showers_sum" -> daily.ShowersSum |> Ok()
    "snowfall_sum" -> daily.SnowfallSum |> Ok()
    "precipitation_hours" -> daily.PrecipitationHours |> Ok()
    "precipitation_probability_max" -> daily.PrecipitationProbabilityMax |> Ok()
    "precipitation_probability_min" -> daily.PrecipitationProbabilityMin |> Ok()
    "precipitation_probability_mean" ->
      daily.PrecipitationProbabilityMean |> Ok()
    "weather_code" -> daily.WorstWeatherCode |> Ok()
    //"sunrise" -> daily.Sunrise |> Ok()
    //"sunset" -> daily.Sunset |> Ok()
    "sunshine_duration" -> daily.SunshineSuration |> Ok()
    "daylight_duration" -> daily.DaylightDuration |> Ok()
    "wind_speed_10m_max" -> daily.WindSpeed10mMax |> Ok()
    "wind_gusts_10m_max" -> daily.WindGusts10mMax |> Ok()
    "wind_direction_10m_dominant" -> daily.WindDirection10mDominant |> Ok()
    _ ->
      Error(errors.InternalError(
        "Unexpected error : string_to_instant(\"" <> s <> "\")",
      ))
  }
}

pub fn refine_raw_time_ranged_data(
  data_opt: option.Option(dict.Dict(String, List(String))),
  data_units_opt: option.Option(dict.Dict(String, String)),
  from_string_fn: fn(String) -> Result(a, errors.InternalError),
) -> Result(data.TimeRangedData(a), errors.InternalError) {
  case data_opt, data_units_opt {
    option.Some(data), option.Some(data_units) -> {
      use time <- result.try(
        dict.get(data, "time")
        // Convert the time strings to `birl.Time`
        |> result.map(fn(l) { list.map(l, birl.from_naive) |> result.all })
        |> result.flatten
        |> result.map_error(fn(_) {
          errors.InternalError(
            "Unexpected error : `time` field should be present.",
          )
        }),
      )
      let data =
        data
        |> dict.drop(["time"])
      // Check that :
      // - all keys correspond to an `instant.InstantVariable`
      // - all values are `Float`
      // - all keys have a corresponding unit
      // Every condition should be ok if everything works as intended
      case
        list.all(dict.to_list(data), fn(tuple) {
          let #(k, v) = tuple

          case from_string_fn(k) {
            Ok(_) -> True
            Error(_) -> False
          }
          && list.all(v, fn(value) {
            case utils.parse_float_or_int(value) {
              Ok(_) -> True
              Error(_) -> False
            }
          })
          && case dict.get(data_units, k) {
            Ok(_) -> True
            Error(_) -> False
          }
        })
      {
        True ->
          data
          |> dict.fold(
            data.TimeRangedData(time: time, data: dict.new()),
            fn(d, k, v) {
              // It's Ok because it has been checked earlier
              let assert Ok(var) = from_string_fn(k)
              let assert Ok(unit) = dict.get(data_units, k)

              let data_list =
                v
                |> list.map(fn(s) {
                  let res = utils.parse_float_or_int(s)
                  case res {
                    Ok(f) -> measurement.Measurement(f, unit)
                    // Will not happen because checked earlier
                    Error(_) -> panic as "This should not happen"
                  }
                })
              data.TimeRangedData(
                ..d,
                data: d.data |> dict.insert(var, data_list),
              )
            },
          )
          |> Ok
        False ->
          Error(errors.InternalError(
            "Unexpected error : data should contain keys corresponding to `a` and float values",
          ))
      }
    }
    // Return empty data is not present.
    _, _ -> Ok(data.TimeRangedData([], dict.new()))
  }
}

pub fn refine_raw_current_data(
  data_opt: option.Option(dict.Dict(String, String)),
  data_units_opt: option.Option(dict.Dict(String, String)),
  from_string_fn: fn(String) -> Result(a, errors.InternalError),
) -> Result(option.Option(data.CurrentData(a)), errors.InternalError) {
  case data_opt, data_units_opt {
    option.Some(data), option.Some(data_units) -> {
      use time <- result.try(
        dict.get(data, "time")
        |> result.map(birl.from_naive)
        |> result.flatten
        |> result.map_error(fn(_) {
          errors.InternalError(
            "Unexpected error : `time` field should be present.",
          )
        }),
      )
      let data = data |> dict.drop(["time", "interval"])
      case
        list.all(dict.to_list(data), fn(tuple) {
          let #(k, v) = tuple

          case from_string_fn(k) {
            Ok(_) -> True
            Error(_) -> False
          }
          && case utils.parse_float_or_int(v) {
            Ok(_) -> True
            Error(_) -> False
          }
          && case dict.get(data_units, k) {
            Ok(_) -> True
            Error(_) -> False
          }
        })
      {
        True ->
          data
          |> dict.fold(
            data.CurrentData(time: time, data: dict.new()),
            fn(d, k, v) {
              // It's Ok because it has been checked earlier
              let assert Ok(var) = from_string_fn(k)
              let assert Ok(unit) = dict.get(data_units, k)
              let assert Ok(value) = utils.parse_float_or_int(v)
              data.CurrentData(
                ..d,
                data: d.data
                  |> dict.insert(var, measurement.Measurement(value, unit)),
              )
            },
          )
          |> option.Some
          |> Ok
        False ->
          Error(errors.InternalError(
            "Unexpected error : data should contain keys corresponding to `a` and float values",
          ))
      }
    }
    _, _ -> Ok(option.None)
  }
}
