import sunny/internal/client.{type Client, Client}
import sunny/internal/defaults

/// Creates a new Open-meteo client with the default values (you probably won't
/// need anything more).
/// 
/// If you have a commercial Open-meteo API acess, check out `new_commercial`.
/// 
/// To change some client parameters (such as the base url), check out the
/// `sunny/client` module.
pub fn new() -> Client {
  Client(defaults.base_url, False, "")
}

/// Creates a new commercial Open-meteo client with the default values
/// Takes your Open-meteo api key as an argument.
pub fn new_commercial(key: String) -> Client {
  Client(defaults.base_url, True, key)
}
