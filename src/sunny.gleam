import sunny/internal/client.{type Client, Client}
import sunny/internal/defaults

/// Creates a new Open-meteo client with the default values (you probably won't
/// need anything more).
/// 
/// If you have a commercial Open-meteo API acess, check out `new_commercial`.
pub fn new() -> Client {
  Client(defaults.base_url, False, "")
}

/// Creates a new commercial Open-meteo client with the default values
/// Takes your Open-meteo api key as an argument.
pub fn new_commercial(key: String) -> Client {
  Client(defaults.base_url, True, key)
}

/// Takes a Client and returns a new one with a custom base url.
pub fn set_base_url(client: Client, url: String) -> Client {
  Client(..client, base_url: url)
}
