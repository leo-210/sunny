//// The module for interactiong with the Forecast API. 
//// 
//// ## Example
//// 
//// Get the hourly forecast of a city
//// 
//// ```gleam
//// import birl
//// 
//// import gleam/float
//// import gleam/io
//// import gleam/list
//// 
//// import sunny
//// import sunny/api/forecast
//// import sunny/api/forecast/data
//// import sunny/api/forecast/instant
//// import sunny/position
//// import sunny/wmo_code
//// 
//// pub fn main() {
////   // Use `new_commercial("<your_api_key>")` if you have a commercial Open-meteo
////   // API access.
////   let sunny = sunny.new()
//// 
////   // You can get the coordinates of a place using the Geocoding API. See 
////   // `sunny/api/geocoding`, or the `city_info` example.
////   //
////   // Once you have a `Location`, use `geocoding.location_to_position()` to
////   // convert it to a position.
////   let position = position.Position(43.0, 5.0)
//// 
////   let assert Ok(forecast_result) =
////     sunny
////     |> forecast.get_forecast(
////       forecast.params(position)
////       // All available variables are listed in the `sunny/api/forecast/instant`
////       // module.
////       // Daily variables are in `sunny/api/forecast/daily`.
////       |> forecast.set_hourly([instant.WeatherCode])
////       |> forecast.set_forecast_days(1),
////     )
//// 
////   let assert Ok(hourly_weather) =
////     forecast_result.hourly
////     |> data.range_to_data_list(instant.WeatherCode)
//// 
////   hourly_weather
////   |> list.each(fn(timed_data) {
////     io.debug(
////       birl.to_time_string(timed_data.time)
////       <> " : "
////       // `wmo_code.to_string` translates the `Int` WMOCode to a human-readable
////       // `String`. 
////       <> wmo_code.to_string(float.round(timed_data.data.value)),
////     )
////   })
//// }
//// ```

import birl

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

/// The result of a request to the Forecast API.
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

/// The different parameters available on the Forecast API.
/// 
/// See <https://open-meteo.com/en/docs> for further reference.
pub type ForecastParams {
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
    /// Will be clamped between 0 and 92.
    past_days: Int,
    /// Will be clamped between 0 and 16.
    forecast_days: Int,
    /// If `forecast_hours` is negative or null, it will be set to `option.None`.
    forecast_hours: option.Option(Int),
    /// If `forecast_minutely_15` is negative or null, it will be set to `option.None`.
    forecast_minutely_15: option.Option(Int),
    /// If `past_hours` is negative or null, it will be set to `option.None`.
    past_hours: option.Option(Int),
    /// If `past_minutely_15` is negative or null, it will be set to `option.None`.
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

/// Returns a new ForecastParams with the specified temperature unit.
pub fn set_temperature_unit(
  params: ForecastParams,
  unit: TemperatureUnit,
) -> ForecastParams {
  ForecastParams(..params, temperature_unit: unit)
}

/// Returns a new ForecastParams with the specified temperature unit.
pub fn set_wind_speed_unit(
  params: ForecastParams,
  unit: WindSpeedUnit,
) -> ForecastParams {
  ForecastParams(..params, wind_speed_unit: unit)
}

/// Returns a new ForecastParams with the specified temperature unit.
pub fn set_precipitation_unit(
  params: ForecastParams,
  unit: PrecipitationUnit,
) -> ForecastParams {
  ForecastParams(..params, precipitation_unit: unit)
}

/// Returns a new ForecastParams with the specified cell selection.
pub fn set_cell_selection(
  params: ForecastParams,
  cell_selection: CellSelection,
) -> ForecastParams {
  ForecastParams(..params, cell_selection: cell_selection)
}

/// Returns a new ForecastParams with the specified timezone.
pub fn set_timezone(params: ForecastParams, timezone: String) -> ForecastParams {
  ForecastParams(..params, timezone: timezone)
}

/// Returns a new ForecastParams with the specified forecast days.
/// 
/// `forecast_days` will be clamped between 0 and 16.
pub fn set_forecast_days(
  params: ForecastParams,
  forecast_days: Int,
) -> ForecastParams {
  ForecastParams(..params, forecast_days: int.clamp(forecast_days, 0, 16))
}

/// Returns a new ForecastParams with the specified past days.
/// 
/// `past_days` will be clamped between 0 and 92.
pub fn set_past_days(params: ForecastParams, past_days: Int) -> ForecastParams {
  ForecastParams(..params, past_days: int.clamp(past_days, 0, 95))
}

/// Returns a new ForecastParams with the specified forecast hours.
/// 
/// If `forecast_hours` is negative or null, it will be set to `option.None`.
pub fn set_forecast_hours(
  params: ForecastParams,
  forecast_hours: Int,
) -> ForecastParams {
  case forecast_hours {
    _ if forecast_hours <= 0 ->
      ForecastParams(..params, forecast_hours: option.None)
    _ -> ForecastParams(..params, forecast_hours: option.Some(forecast_hours))
  }
}

/// Returns a new ForecastParams with the specified forecast minutely 15.
/// 
/// If `forecast_minutely_15` is negative or null, it will be set to `option.None`.
pub fn set_forecast_minutely_15(
  params: ForecastParams,
  forecast_minutely_15: Int,
) -> ForecastParams {
  case forecast_minutely_15 {
    _ if forecast_minutely_15 <= 0 ->
      ForecastParams(..params, forecast_minutely_15: option.None)
    _ ->
      ForecastParams(
        ..params,
        forecast_minutely_15: option.Some(forecast_minutely_15),
      )
  }
}

/// Returns a new ForecastParams with the specified past hours.
/// 
/// If `past_hours` is negative or null, it will be set to `option.None`.
pub fn set_past_hours(params: ForecastParams, past_hours: Int) -> ForecastParams {
  case past_hours {
    _ if past_hours <= 0 -> ForecastParams(..params, past_hours: option.None)
    _ -> ForecastParams(..params, past_hours: option.Some(past_hours))
  }
}

/// Returns a new ForecastParams with the specified past minutely 15.
/// 
/// If `past_minutely_15` is negative or null, it will be set to `option.None`.
pub fn set_past_minutely_15(
  params: ForecastParams,
  past_minutely_15: Int,
) -> ForecastParams {
  case past_minutely_15 {
    _ if past_minutely_15 <= 0 ->
      ForecastParams(..params, past_minutely_15: option.None)
    _ ->
      ForecastParams(..params, past_minutely_15: option.Some(past_minutely_15))
  }
}

/// Returns a new ForecastParams with the specified start date.
pub fn set_start_date(
  params: ForecastParams,
  start_date: birl.Time,
) -> ForecastParams {
  ForecastParams(..params, start_date: option.Some(start_date))
}

/// Returns a new ForecastParams with the specified end date.
pub fn set_end_date(
  params: ForecastParams,
  end_date: birl.Time,
) -> ForecastParams {
  ForecastParams(..params, end_date: option.Some(end_date))
}

/// Returns a new ForecastParams with the specified start hour.
pub fn set_start_hour(
  params: ForecastParams,
  start_hour: birl.Time,
) -> ForecastParams {
  ForecastParams(..params, start_hour: option.Some(start_hour))
}

/// Returns a new ForecastParams with the specified end hour.
pub fn set_end_hour(
  params: ForecastParams,
  end_hour: birl.Time,
) -> ForecastParams {
  ForecastParams(..params, end_hour: option.Some(end_hour))
}

/// Returns a new ForecastParams with the specified start minutely 15.
pub fn set_start_minutely_15(
  params: ForecastParams,
  start_minutely_15: birl.Time,
) -> ForecastParams {
  ForecastParams(..params, start_minutely_15: option.Some(start_minutely_15))
}

/// Returns a new ForecastParams with the specified end minutely 15.
pub fn set_end_minutely_15(
  params: ForecastParams,
  end_minutely_15: birl.Time,
) -> ForecastParams {
  ForecastParams(..params, end_minutely_15: option.Some(end_minutely_15))
}

/// Returns a new ForecastParams with the specified hourly list.
pub fn set_hourly(
  params: ForecastParams,
  hourly_list: List(instant.InstantVariable),
) -> ForecastParams {
  ForecastParams(..params, hourly: hourly_list)
}

/// Returns a new `ForecastParams` with all the hourly variables except the
/// ones in the `except` argument.
pub fn set_all_hourly(
  params: ForecastParams,
  except: List(instant.InstantVariable),
) -> ForecastParams {
  set_all(params, except, instant.all, set_hourly)
}

/// Returns a new ForecastParams with the specified daily list
pub fn set_daily(
  params: ForecastParams,
  daily_list: List(daily.DailyVariable),
) -> ForecastParams {
  ForecastParams(..params, daily: daily_list)
}

/// Returns a new `ForecastParams` with all the daily variables except the 
/// ones in the `except` argument
pub fn set_all_daily(
  params: ForecastParams,
  except: List(daily.DailyVariable),
) -> ForecastParams {
  set_all(params, except, daily.all, set_daily)
}

/// Returns a new ForecastParams with the specified 15-minutely list
pub fn set_minutely(
  params: ForecastParams,
  minutely_list: List(instant.InstantVariable),
) -> ForecastParams {
  ForecastParams(..params, minutely: minutely_list)
}

/// Returns a new `ForecastParams` with all the minutely variables except the
/// ones in the `except` argument.
pub fn set_all_minutely(
  params: ForecastParams,
  except: List(instant.InstantVariable),
) -> ForecastParams {
  set_all(params, except, instant.all, set_minutely)
}

/// Returns a new ForecastParams with the specified hourly list
pub fn set_current(
  params: ForecastParams,
  current_list: List(instant.InstantVariable),
) -> ForecastParams {
  ForecastParams(..params, current: current_list)
}

/// Returns a new `ForecastParams` with all the current variables except the
/// ones in the `except` argument.
pub fn set_all_current(
  params: ForecastParams,
  except: List(instant.InstantVariable),
) -> ForecastParams {
  set_all(params, except, instant.all, set_current)
}

fn set_all(
  params: ForecastParams,
  except: List(a),
  all: List(a),
  set_fn: fn(ForecastParams, List(a)) -> ForecastParams,
) -> ForecastParams {
  case except {
    [] -> params |> set_fn(all)
    [_, ..] ->
      params
      |> set_fn(list.filter(all, fn(x) { list.contains(except, x) }))
  }
}

/// Get a `ForecastResult` according to the specified `ForecastParams`.
pub fn get_forecast(
  client: client.Client,
  params: ForecastParams,
) -> Result(ForecastResult, errors.SunnyError) {
  make_request(client, params)
}

fn make_request(
  client: client.Client,
  params: ForecastParams,
) -> Result(ForecastResult, errors.SunnyError) {
  let params = verify_params(params)

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

fn verify_params(params: ForecastParams) -> ForecastParams {
  ForecastParams(
    ..params,
    hourly: list.unique(params.hourly),
    daily: list.unique(params.daily),
    minutely: list.unique(params.minutely),
    current: list.unique(params.current),
  )
  |> set_past_days(params.past_days)
  |> set_forecast_days(params.forecast_days)
  |> set_if_some(params.forecast_hours, set_forecast_hours)
  |> set_if_some(params.forecast_minutely_15, set_forecast_minutely_15)
  |> set_if_some(params.past_hours, set_past_hours)
  |> set_if_some(params.past_minutely_15, set_past_minutely_15)
}

fn set_if_some(
  params: ForecastParams,
  opt: option.Option(a),
  func: fn(ForecastParams, a) -> ForecastParams,
) -> ForecastParams {
  case opt {
    option.Some(x) -> func(params, x)
    option.None -> params
  }
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
