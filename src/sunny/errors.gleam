import efetch
import gleam/json

/// A type describing any error that could occur while using this library
pub type OMApiError {
  HttpError(efetch.HttpError)
  DecodeError(json.DecodeError)
  NoResults
}
