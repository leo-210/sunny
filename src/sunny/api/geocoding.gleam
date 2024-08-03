import gleam/option

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

/// Represents a place. Can be obtained with the geocoding API.
pub type Location {
  /// See https://open-meteo.com/en/docs/geocoding-api for more information on the fields
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
  /// The coordinates of a location. Can be used to get the weather forecast in
  /// a specific place.
  Coordinates(latitude: Float, longitude: Float)
}

/// The different parameters needed to make a request to the geocoding API
pub type GeocodingParams {
  GeocodingParams(name: String, count: Int, language: Language)
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
