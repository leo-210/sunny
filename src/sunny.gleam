import gleam/result.{try}
import sunny/api/geocoding
import sunny/errors.{type OMApiError}
import sunny/internal/api/geocoding as internal_geo
import sunny/internal/client.{type Client, Client}
import sunny/internal/defaults

// Client functions

/// Creates a new Open-meteo client with the default values (that's usually 
/// what you want).
/// Use `client.new_commercial("<your_api_key")` if you have a commercial 
/// Open-meteo API access 
pub fn new() -> Client {
  Client(defaults.base_url, False, "")
}

/// Creates a new commercial Open-meteo client with the default values
/// Takes your open-meteo api key as an argument.
pub fn new_commercial(key: String) -> Client {
  Client(defaults.base_url, True, key)
}

//    Geocoding  API

/// Gets a list of locations that match the searched name (specified in `params`).
pub fn get_locations(
  client: client.Client,
  params: geocoding.GeocodingParams,
) -> Result(List(geocoding.Location), OMApiError) {
  internal_geo.make_request(client, params)
}

/// Get the first search result given by `get_locations`.
/// Overrights the `count` parameter.
pub fn get_first_location(
  client: client.Client,
  params: geocoding.GeocodingParams,
) -> Result(geocoding.Location, OMApiError) {
  use locations <- try(get_locations(client, geocoding.set_count(params, 1)))
  case locations {
    [head, ..] -> Ok(head)
    // Shouldn't happen because an error would be returned by `get_locations`
    [] -> panic as "`get_locations` gave empty list instead of error."
  }
}
