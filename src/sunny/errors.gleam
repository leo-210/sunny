//// A module with the errors you could get using Sunny.

import gleam/json

pub type SunnyError {
  /// Something went wrong with decoding the json obtained with the request.
  DecodeError(err: json.DecodeError)
  /// An API-related error (e.g. wrong arguments)
  ApiError(err: ApiError)
  /// Something went wrong while handling data.
  DataError(err: DataError)
  /// Something went wrong internally. If you get this error, please create an
  /// issue on Github.
  SunnyInternalError(err: InternalError)
}

pub type ApiError {
  NoResultsError(msg: String)
  InvalidArgumentError(msg: String)
}

pub type DataError {
  DataNotFoundError(msg: String)
}

pub type InternalError {
  InternalError(msg: String)
}
