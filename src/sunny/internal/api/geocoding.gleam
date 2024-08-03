import gleam/dict
import gleam/dynamic.{dict, field, float, int, list, optional_field, string}
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import sunny/api/geocoding
import sunny/client
import sunny/errors
import sunny/internal/client.{type Client, Client} as _
import sunny/internal/utils

pub fn make_request(
  client: Client,
  params: geocoding.GeocodingParams,
) -> Result(List(geocoding.Location), errors.OMApiError) {
  case
    utils.make_request(utils.get_final_url(
      client.get_base_url(client),
      "geocoding",
      client.is_commercial(client),
      "/search",
      client.get_api_key(client),
      geocoding_params_to_params_list(params),
    ))
  {
    Ok(body) -> locations_from_json(body)
    Error(err) -> Error(errors.HttpError(err))
  }
}

fn geocoding_params_to_params_list(
  params: geocoding.GeocodingParams,
) -> List(utils.RequestParameter) {
  [
    utils.RequestParameter("name", params.name),
    utils.RequestParameter("count", int.to_string(params.count)),
    utils.RequestParameter(
      "language",
      language_to_country_code(params.language),
    ),
    utils.RequestParameter("format", "json"),
  ]
}

fn language_to_country_code(lang: geocoding.Language) -> String {
  case lang {
    geocoding.English -> "en"
    geocoding.German -> "de"
    geocoding.French -> "fr"
    geocoding.Spanish -> "es"
    geocoding.Italian -> "it"
    geocoding.Portuguese -> "pt"
    geocoding.Russian -> "ru"
    geocoding.Turkish -> "tr"
    geocoding.Hindi -> "hi"
  }
}

type LocationList {
  LocationList(results: option.Option(List(geocoding.Location)))
}

fn locations_from_json(
  json_string: String,
) -> Result(List(geocoding.Location), errors.OMApiError) {
  let geocoding_decoder =
    dynamic.decode1(
      LocationList,
      optional_field(
        "results",
        of: list(utils.decode18(
          geocoding.Location,
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
      _ -> Error(errors.NoResults)
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
