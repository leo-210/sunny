import birl
import gleam/set

import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result

import sunny/api/forecast/daily
import sunny/api/forecast/data
import sunny/api/forecast/instant
import sunny/errors
import sunny/internal/api/forecast
import sunny/internal/client
import sunny/internal/utils
import sunny/position

pub type TemperatureUnit {
  Celsius
  Fahrenheit
}

fn temp_unit_to_string(u: TemperatureUnit) -> String {
  case u {
    Celsius -> "celsius"
    Fahrenheit -> "fahrenheit"
  }
}

pub type WindSpeedUnit {
  KilometersPerHour
  MetersPerSecond
  MilesPerHour
  Knots
}

fn wind_unit_to_string(u: WindSpeedUnit) -> String {
  case u {
    KilometersPerHour -> "kmh"
    MetersPerSecond -> "ms"
    MilesPerHour -> "mph"
    Knots -> "kn"
  }
}

pub type PrecipitationUnit {
  Millimeters
  Inches
}

fn precipitation_unit_to_string(u: PrecipitationUnit) -> String {
  case u {
    Millimeters -> "mm"
    Inches -> "inch"
  }
}

pub type CellSelection {
  Land
  Sea
  Nearest
}

fn cell_select_to_string(c: CellSelection) -> String {
  case c {
    Land -> "land"
    Sea -> "sea"
    Nearest -> "nearest"
  }
}

pub type ForecastResult {
  ForecastResult(
    position: position.Position,
    elevation: Float,
    utc_offset_seconds: Int,
    timezone: String,
    timezone_abbreviation: String,
    hourly: data.TimeRangedData(instant.InstantVariable),
    daily: data.TimeRangedData(daily.DailyVariable),
    minutely: data.TimeRangedData(instant.InstantVariable),
    current: option.Option(data.CurrentData(instant.InstantVariable)),
  )
}

pub type ForecastParams {
  /// The different parameters available on the Forecast API
  /// 
  /// See <https://open-meteo.com/en/docs>
  ForecastParams(
    // TODO: Support multiple positions in one call
    position: position.Position,
    hourly: List(instant.InstantVariable),
    daily: List(daily.DailyVariable),
    /// Get data every 15 minutes. Some data can't be optained every 15
    /// minutes, so it will be interpolated over the hour (or more if needed)
    minutely: List(instant.InstantVariable),
    current: List(instant.InstantVariable),
    temperature_unit: TemperatureUnit,
    wind_speed_unit: WindSpeedUnit,
    precipitation_unit: PrecipitationUnit,
    /// Full list here : <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List>
    /// 
    /// You can set `timezone` to `auto`, and the API will deduce the local 
    /// timezone from the coordinates.
    ///  
    /// For abbreviations, in my experience only three letter ones work 
    /// (e.g. `CEST` returns an error).
    timezone: String,
    past_days: Int,
    forecast_days: Int,
    forecast_hours: option.Option(Int),
    forecast_minutely_15: option.Option(Int),
    past_hours: option.Option(Int),
    past_minutely_15: option.Option(Int),
    start_date: option.Option(birl.Time),
    end_date: option.Option(birl.Time),
    start_hour: option.Option(birl.Time),
    end_hour: option.Option(birl.Time),
    start_minutely_15: option.Option(birl.Time),
    end_minutely_15: option.Option(birl.Time),
    // TODO: support multiple models
    cell_selection: CellSelection,
  )
}

/// Creates a new ForecastParams with the default values
pub fn params(position: position.Position) -> ForecastParams {
  ForecastParams(
    position,
    [],
    [],
    [],
    [],
    Celsius,
    KilometersPerHour,
    Millimeters,
    "GMT",
    0,
    7,
    option.None,
    option.None,
    option.None,
    option.None,
    option.None,
    option.None,
    option.None,
    option.None,
    option.None,
    option.None,
    Land,
  )
}

/// Returns a new ForecastParams with the specified hourly list
pub fn set_hourly(
  p: ForecastParams,
  h: List(instant.InstantVariable),
) -> ForecastParams {
  ForecastParams(..p, hourly: h)
}

/// Returns a new ForecastParams with the specified daily list
pub fn set_daily(
  p: ForecastParams,
  d: List(daily.DailyVariable),
) -> ForecastParams {
  ForecastParams(..p, daily: d)
}

/// Returns a new ForecastParams with the specified 15-minutely list
pub fn set_minutely(
  p: ForecastParams,
  m: List(instant.InstantVariable),
) -> ForecastParams {
  ForecastParams(..p, minutely: m)
}

/// Returns a new ForecastParams with the specified hourly list
pub fn set_current(
  p: ForecastParams,
  c: List(instant.InstantVariable),
) -> ForecastParams {
  ForecastParams(..p, current: c)
}

pub fn get_forecast(
  client: client.Client,
  params: ForecastParams,
) -> Result(ForecastResult, errors.SunnyError) {
  make_request(client, params)
}

// TODO: Parse json response into a record 
fn make_request(
  client: client.Client,
  params: ForecastParams,
) -> Result(ForecastResult, errors.SunnyError) {
  let params = unify_params(params)

  use json_string <- result.try(
    utils.get_final_url(
      client.base_url,
      "",
      client.commercial,
      "/forecast",
      client.key,
      params |> forecast_params_to_params_list,
    )
    |> utils.make_request
    |> result.map_error(fn(x) { errors.HttpError(x) }),
  )
  use raw_result <- result.try(forecast.raw_forecast_result_from_json(
    json_string,
  ))
  raw_result
  |> refine_raw_result()
  |> result.map_error(fn(e) { errors.SunnyInternalError(e) })
}

fn unify_params(params: ForecastParams) -> ForecastParams {
  ForecastParams(
    ..params,
    hourly: set.to_list(set.from_list(params.hourly)),
    daily: set.to_list(set.from_list(params.daily)),
    minutely: set.to_list(set.from_list(params.minutely)),
    current: set.to_list(set.from_list(params.current)),
  )
}

fn forecast_params_to_params_list(
  params: ForecastParams,
) -> List(utils.RequestParameter) {
  option_to_param_list(params.forecast_hours, "forecast_hours", int.to_string)
  |> list.append(list_to_param_list(
    params.hourly,
    "hourly",
    forecast.instant_to_string,
  ))
  |> list.append(list_to_param_list(
    params.daily,
    "daily",
    forecast.daily_to_string,
  ))
  |> list.append(list_to_param_list(
    params.minutely,
    "minutely_15",
    forecast.instant_to_string,
  ))
  |> list.append(list_to_param_list(
    params.current,
    "current",
    forecast.instant_to_string,
  ))
  |> list.append(option_to_param_list(
    params.forecast_minutely_15,
    "forecast_minutely_15",
    int.to_string,
  ))
  |> list.append(option_to_param_list(
    params.past_hours,
    "past_hours",
    int.to_string,
  ))
  |> list.append(option_to_param_list(
    params.past_minutely_15,
    "past_minutely_15",
    int.to_string,
  ))
  |> list.append(option_to_param_list(
    params.start_date,
    "start_date",
    birl.to_naive_date_string,
  ))
  |> list.append(option_to_param_list(
    params.end_date,
    "end_date",
    birl.to_naive_date_string,
  ))
  |> list.append(option_to_param_list(
    params.start_hour,
    "start_hour",
    birl.to_naive_time_string,
  ))
  |> list.append(option_to_param_list(
    params.end_hour,
    "end_hour",
    birl.to_naive_date_string,
  ))
  |> list.append(option_to_param_list(
    params.start_minutely_15,
    "start_minutely_15",
    birl.to_naive_date_string,
  ))
  |> list.append(option_to_param_list(
    params.end_minutely_15,
    "end_minutely_15",
    birl.to_naive_date_string,
  ))
  |> list.append([
    utils.RequestParameter(
      "latitude",
      params.position.latitude |> float.to_string,
    ),
    utils.RequestParameter(
      "longitude",
      params.position.longitude |> float.to_string,
    ),
    utils.RequestParameter(
      "temperature_unit",
      params.temperature_unit |> temp_unit_to_string,
    ),
    utils.RequestParameter(
      "wind_speed_unit",
      params.wind_speed_unit |> wind_unit_to_string,
    ),
    utils.RequestParameter(
      "precipitation_unit",
      params.precipitation_unit |> precipitation_unit_to_string,
    ),
    utils.RequestParameter("timezone", params.timezone),
    utils.RequestParameter("past_days", params.past_days |> int.to_string),
    utils.RequestParameter(
      "forecast_days",
      params.forecast_days |> int.to_string,
    ),
    utils.RequestParameter(
      "cell_selection",
      params.cell_selection |> cell_select_to_string,
    ),
  ])
}

fn option_to_param_list(
  opt: option.Option(a),
  opt_string: String,
  to_string_fn: fn(a) -> String,
) -> List(utils.RequestParameter) {
  case opt {
    option.Some(x) -> [utils.RequestParameter(opt_string, x |> to_string_fn)]
    option.None -> []
  }
}

fn list_to_param_list(
  l: List(a),
  l_string: String,
  to_string_fn: fn(a) -> String,
) -> List(utils.RequestParameter) {
  case l {
    [_, ..] -> [
      l
      |> utils.param_list_to_string(to_string_fn)
      |> utils.RequestParameter(l_string, _),
    ]
    [] -> []
  }
}

fn refine_raw_result(
  raw: forecast.RawForecastResult,
) -> Result(ForecastResult, errors.InternalError) {
  use hourly <- result.try(forecast.refine_raw_time_ranged_data(
    raw.hourly,
    raw.hourly_units,
    forecast.string_to_instant,
  ))
  use daily <- result.try(forecast.refine_raw_time_ranged_data(
    raw.daily,
    raw.daily_units,
    forecast.string_to_daily,
  ))
  use minutely <- result.try(forecast.refine_raw_time_ranged_data(
    raw.minutely,
    raw.minutely_units,
    forecast.string_to_instant,
  ))
  use current <- result.try(forecast.refine_raw_current_data(
    raw.current,
    raw.current_units,
    forecast.string_to_instant,
  ))
  Ok(ForecastResult(
    position.Position(raw.latitude, raw.longitude),
    raw.elevation,
    raw.utc_offset_seconds,
    raw.timezone,
    raw.timezone_abbreviation,
    hourly,
    daily,
    minutely,
    current,
  ))
}
