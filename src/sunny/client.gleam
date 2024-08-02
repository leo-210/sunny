import sunny/internal/defaults

/// A record allowing to remember basing api settings (e.g. the base url)
pub opaque type Client {
  Client(base_url: String, commercial: Bool, key: String)
}

/// Creates a new Open-meteo client with the default values (that's usually 
/// what you want).
pub fn new() -> Client {
  Client(defaults.base_url, False, "")
}

/// Creates a new commercial Open-meteo client with the default values
/// Takes your open-meteo api key as an argument.
pub fn new_commercial(key: String) -> Client {
  Client(defaults.base_url, True, key)
}

/// Takes a Client and returns a new one with a custom base url.
pub fn set_base_url(client: Client, url: String) -> Client {
  Client(..client, base_url: url)
}

/// Whether the given Client is commercial or not
pub fn is_commercial(client: Client) -> Bool {
  client.commercial
}

/// Returns the base url of the given Client
pub fn get_base_url(client: Client) -> String {
  client.base_url
}
