//// A module containing useful functions to handle API results.

import birl
import gleam/dict
import gleam/list
import gleam/result
import sunny/errors
import sunny/measurement

/// Data over a time range.
pub type TimeRangedData(data_type) {
  TimeRangedData(
    /// A list of `birl.Time`, with each index corresponding to the index of
    /// the `data` argument.
    /// 
    /// For example, `list.first(time)` is the time when the first measurement
    /// was taken
    time: List(birl.Time),
    data: dict.Dict(data_type, List(measurement.Measurement)),
  )
}

/// Data at a specific time.
pub type CurrentData(data_type) {
  CurrentData(
    time: birl.Time,
    data: dict.Dict(data_type, measurement.Measurement),
  )
}

/// A measurement at a specific time.
/// 
/// Similar to `CurrentData` but with only one `Measurement`.
pub type Data {
  Data(time: birl.Time, data: measurement.Measurement)
}

pub fn get_range_var(
  from data: TimeRangedData(a),
  get var: a,
) -> Result(List(measurement.Measurement), errors.DataError) {
  data.data
  |> dict.get(var)
  |> result.map_error(fn(_) {
    errors.DataNotFoundError("Could not find variable in data.")
  })
}

pub fn range_to_current(
  from data: TimeRangedData(a),
  at time: birl.Time,
) -> Result(CurrentData(a), errors.SunnyError) {
  case data.time {
    [] ->
      Error(
        errors.DataError(errors.DataNotFoundError(
          "Invalid time for provided data.",
        )),
      )
    [head, ..tail] ->
      case head == time {
        False -> {
          let new_data =
            data.data
            |> dict.map_values(fn(_, v) {
              // Should be ok, because the `time` length is the same as `v`
              // length.
              let assert [_, ..new] = v
              new
            })
          range_to_current(TimeRangedData(time: tail, data: new_data), time)
        }
        True ->
          Ok(CurrentData(
            time: time,
            data: dict.fold(data.data, dict.new(), fn(d, k, v) {
              dict.insert(d, k, {
                let assert [head, ..] = v
                head
              })
            }),
          ))
      }
  }
}

pub fn range_to_data_list(
  from data: TimeRangedData(a),
  get var: a,
) -> Result(List(Data), errors.SunnyError) {
  use l <- result.try(
    get_range_var(data, var) |> result.map_error(fn(e) { errors.DataError(e) }),
  )
  do_range_to_data_list(data.time, l, [])
  |> result.map_error(fn(e) { errors.SunnyInternalError(e) })
}

fn do_range_to_data_list(
  time: List(birl.Time),
  l: List(measurement.Measurement),
  result: List(Data),
) -> Result(List(Data), errors.InternalError) {
  case time, l {
    [], [] -> Ok(result)
    [t, ..t_tail], [m, ..m_tail] ->
      result
      // This could, maybe, be optimized, by appending in the other way.
      |> list.append([Data(t, m)])
      |> do_range_to_data_list(t_tail, m_tail, _)
    _, _ ->
      // Should not happen because the two lists should have the same length.
      Error(errors.InternalError(
        "Please open an issue on Github if you encountered this error.",
      ))
  }
}
