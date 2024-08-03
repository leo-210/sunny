import gleam/hackney
import gleam/json

/// A type describing any error that could occur while using this library
pub type OMApiError {
  HttpError(hackney.Error)
  DecodeError(json.DecodeError)
  NoResults
}
