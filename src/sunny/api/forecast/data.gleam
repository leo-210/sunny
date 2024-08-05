import birl
import gleam/dict
import gleam/result
import sunny/api/forecast/daily
import sunny/api/forecast/instant
import sunny/errors
import sunny/internal/api/forecast as int_forecast
import sunny/measurement

pub fn get_instant_var(
  from data: int_forecast.TimeRangedData,
  get var: instant.InstantVariable,
) -> Result(dict.Dict(birl.Time, measurement.Measurement), errors.DataError) {
  data.data
  |> dict.get(int_forecast.instant_to_string(var))
  |> result.map_error(fn(_) {
    errors.DataNotFoundError(
      "Could not find `" <> int_forecast.instant_to_string(var) <> "`.",
    )
  })
}

pub fn get_daily_var(
  from data: int_forecast.TimeRangedData,
  get var: daily.DailyVariable,
) -> Result(dict.Dict(birl.Time, measurement.Measurement), errors.DataError) {
  data.data
  |> dict.get(int_forecast.daily_to_string(var))
  |> result.map_error(fn(_) {
    errors.DataNotFoundError(
      "Could not find `"
      <> int_forecast.daily_to_string(var)
      <> "` variable in data.",
    )
  })
}
