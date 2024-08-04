//// A module with the errors you could get using Sunny.

import efetch
import gleam/json

pub type SunnyError {
  HttpError(err: efetch.HttpError)
  DecodeError(err: json.DecodeError)
  ApiError(err: ApiError)
}

pub type ApiError {
  NoResults
}
