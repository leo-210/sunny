import birl
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import sunny/api/forecast/current
import sunny/api/forecast/daily
import sunny/api/forecast/hourly
import sunny/api/forecast/minutely
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

pub type ForecastParams {
  ForecastParams(
    positions: List(position.Position),
    hourly: List(hourly.HourlyVariable),
    daily: List(daily.DailyVariable),
    minutely: List(minutely.MinutelyVariable),
    current: List(current.CurrentVariable),
    temperature_unit: TemperatureUnit,
    wind_speed_unit: WindSpeedUnit,
    precipitation_unit: PrecipitationUnit,
    /// Full list here : https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
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
pub fn params(positions: List(position.Position)) -> ForecastParams {
  ForecastParams(
    positions,
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
  h: List(hourly.HourlyVariable),
) -> ForecastParams {
  ForecastParams(..p, hourly: h)
}

/// Returns a new ForecastParams with the specified hourly list
pub fn set_daily(
  p: ForecastParams,
  d: List(daily.DailyVariable),
) -> ForecastParams {
  ForecastParams(..p, daily: d)
}

/// Returns a new ForecastParams with the specified hourly list
pub fn set_minutely(
  p: ForecastParams,
  m: List(minutely.MinutelyVariable),
) -> ForecastParams {
  ForecastParams(..p, minutely: m)
}

/// Returns a new ForecastParams with the specified hourly list
pub fn set_current(
  p: ForecastParams,
  c: List(current.CurrentVariable),
) -> ForecastParams {
  ForecastParams(..p, hourly: c)
}

pub fn get_forecast(
  client: client.Client,
  params: ForecastParams,
) -> Result(String, errors.SunnyError) {
  make_request(client, params)
}

// TODO: Parse json response into a record 
fn make_request(
  client: client.Client,
  params: ForecastParams,
) -> Result(String, errors.SunnyError) {
  utils.get_final_url(
    client.base_url,
    "",
    client.commercial,
    "/forecast",
    client.key,
    params |> forecast_params_to_params_list,
  )
  |> fn(x) {
    io.println(x)
    utils.make_request(x)
  }
  |> result.map_error(fn(x) { errors.HttpError(x) })
}

// That took so long :')
fn forecast_params_to_params_list(
  params: ForecastParams,
) -> List(utils.RequestParameter) {
  option_to_param_list(params.forecast_hours, "forecast_hours", int.to_string)
  |> list.append(list_to_param_list(
    params.hourly,
    "hourly",
    forecast.hourly_to_string,
  ))
  |> list.append(list_to_param_list(
    params.daily,
    "daily",
    forecast.daily_to_string,
  ))
  |> list.append(list_to_param_list(
    params.minutely,
    "minutely_15",
    forecast.hourly_to_string,
  ))
  |> list.append(list_to_param_list(
    params.current,
    "current",
    forecast.hourly_to_string,
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
      params.positions
        |> list.map(fn(p) { p.latitude })
        |> utils.param_list_to_string(float.to_string),
    ),
    utils.RequestParameter(
      "longitude",
      params.positions
        |> list.map(fn(p) { p.longitude })
        |> utils.param_list_to_string(float.to_string),
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
