import gleam/result.{try}
import sunny/api/geocoding
import sunny/client
import sunny/errors.{type OMApiError}
import sunny/internal/api/geocoding as internal_geo

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
