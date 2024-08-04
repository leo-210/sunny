//// The module for interacting with the Geocoding API.
//// Useful for getting the coordinates of a city to then get the weather 
//// forecast.
//// 
//// ### Example
//// ```gleam
//// import sunny
//// import sunny/api/geocoding
//// 
//// pub fn main() {
////   // Use `new_commercial("<your_api_key>")` if you have a commercial Open-meteo
////   // API access 
////   let sunny = sunny.new()
//// 
////   let assert Ok(location) =
////     geocoding.get_first_location(sunny, {
////       geocoding.params("marseille")
////       |> geocoding.set_language(geocoding.French)
////     })
//// 
////   io.println(
////     location.name
////     <> " is located at :\n"
////     <> float.to_string(location.latitude)
////     <> "\n"
////     <> float.to_string(location.longitude),
////   )
//// }
//// ```gleam

import gleam/dict
import gleam/dynamic.{dict, field, float, int, list, optional_field, string}
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import sunny/errors
import sunny/internal/client.{type Client, Client} as _
import sunny/internal/utils
import sunny/position

/// Enumeration of the available languages for the geocoding API.
/// Changing the language will impact the search results.
pub type Language {
  English
  German
  French
  Spanish
  Italian
  Portuguese
  Russian
  Turkish
  Hindi
}

/// Represents a location on good old earth. Can be obtained with the geocoding
/// API.
pub type Location {
  /// See https://open-meteo.com/en/docs/geocoding-api for more information
  /// on the fields.
  /// 
  /// If you want to use specific coordinates, use the `Coordinates` 
  /// constructor.
  Location(
    latitude: Float,
    longitude: Float,
    id: Int,
    name: String,
    elevation: Float,
    feature_code: String,
    country_code: String,
    country_id: Int,
    population: Int,
    post_codes: List(String),
    admin1: option.Option(String),
    admin2: option.Option(String),
    admin3: option.Option(String),
    admin4: option.Option(String),
    admin1_id: option.Option(Int),
    admin2_id: option.Option(Int),
    admin3_id: option.Option(Int),
    admin4_id: option.Option(Int),
  )
}

/// Converts a location to a position.
pub fn location_to_position(location: Location) -> position.Position {
  position.Position(location.latitude, location.longitude)
}

/// The different parameters needed to make a request to the geocoding API
pub type GeocodingParams {
  GeocodingParams(name: String, count: Int, language: Language)
}

/// Gets a list of locations that match the searched name (specified in `params`).
pub fn get_locations(
  client: Client,
  params: GeocodingParams,
) -> Result(List(Location), errors.SunnyError) {
  make_request(client, params)
}

/// Get the first search result given by `get_locations`.
/// Overrights the `count` parameter of `params`.
pub fn get_first_location(
  client: Client,
  params: GeocodingParams,
) -> Result(Location, errors.SunnyError) {
  use locations <- result.try(get_locations(client, set_count(params, 1)))
  case locations {
    [head, ..] -> Ok(head)
    // Shouldn't happen because an error would be returned by `get_locations`
    [] -> panic as "`get_locations` gave empty list instead of error."
  }
}

/// Creates a new GeocodingParams with the default parameters. Takes the name 
/// of the researched location (by name or by postal code). 
/// Defaults : 
///   - count : 10
///   - language : english
pub fn params(name: String) -> GeocodingParams {
  GeocodingParams(name, 10, English)
}

/// Creates a new GeocodingParams from the one specified, changing its count
/// field.
/// 
/// The count must be between 1 and 100. If it is out of bounds, the program
/// will panic.
pub fn set_count(params: GeocodingParams, count: Int) -> GeocodingParams {
  case count {
    count if count > 100 || count < 1 ->
      panic as "Geocoding parameter count must be between 1 and 100."
    _ -> GeocodingParams(..params, count: count)
  }
}

/// Creates a new GeocodingParams from the one specified, changing its language
/// field.
pub fn set_language(
  params: GeocodingParams,
  language: Language,
) -> GeocodingParams {
  GeocodingParams(..params, language: language)
}

fn make_request(
  client: Client,
  params: GeocodingParams,
) -> Result(List(Location), errors.SunnyError) {
  case
    utils.get_final_url(
      client.base_url,
      "geocoding",
      client.commercial,
      "/search",
      client.key,
      params |> geocoding_params_to_params_list,
    )
    |> utils.make_request
  {
    Ok(body) -> locations_from_json(body)
    Error(err) -> Error(errors.HttpError(err))
  }
}

fn geocoding_params_to_params_list(
  params: GeocodingParams,
) -> List(utils.RequestParameter) {
  [
    utils.RequestParameter("name", params.name),
    utils.RequestParameter("count", int.to_string(params.count)),
    utils.RequestParameter(
      "language",
      params.language |> language_to_country_code,
    ),
    utils.RequestParameter("format", "json"),
  ]
}

fn language_to_country_code(lang: Language) -> String {
  case lang {
    English -> "en"
    German -> "de"
    French -> "fr"
    Spanish -> "es"
    Italian -> "it"
    Portuguese -> "pt"
    Russian -> "ru"
    Turkish -> "tr"
    Hindi -> "hi"
  }
}

type LocationList {
  LocationList(results: option.Option(List(Location)))
}

fn locations_from_json(
  json_string: String,
) -> Result(List(Location), errors.SunnyError) {
  let geocoding_decoder =
    dynamic.decode1(
      LocationList,
      optional_field(
        "results",
        of: list(utils.decode18(
          Location,
          field("latitude", of: float),
          field("longitude", of: float),
          field("id", of: int),
          field("name", of: string),
          field("elevation", of: float),
          field("feature_code", of: string),
          field("country_code", of: string),
          field("country_id", of: int),
          field("population", of: int),
          field("postcodes", of: list(string)),
          optional_field("admin1", of: string),
          optional_field("admin2", of: string),
          optional_field("admin3", of: string),
          optional_field("admin4", of: string),
          optional_field("admin1_id", of: int),
          optional_field("admin2_id", of: int),
          optional_field("admin3_id", of: int),
          optional_field("admin4_id", of: int),
        )),
      ),
    )
  json.decode(from: json_string, using: geocoding_decoder)
  |> result.map_error(fn(x) { errors.DecodeError(x) })
  |> result.map(fn(locations_maybe) {
    case locations_maybe {
      LocationList(option.Some(locations)) -> Ok(locations)
      _ ->
        Error(
          errors.ApiError(errors.NoResultsError(
            "Geocoding search gave no results",
          )),
        )
    }
  })
  |> result.flatten
}

fn decoding_helper(
  d: dict.Dict(Int, a),
  n: Int,
  l: List(a),
  max: Int,
) -> List(a) {
  case n {
    n if n >= max -> l
    n -> {
      let l =
        list.append(l, [
          case dict.get(d, n) {
            Ok(v) -> v
            Error(_) -> panic as "This shouldn't happen."
          },
        ])
      decoding_helper(d, n + 1, l, max)
    }
  }
}
