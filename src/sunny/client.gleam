import sunny/internal/client.{type Client, Client}

/// Takes a Client and returns a new one with a custom base url.
pub fn set_base_url(client: Client, url: String) -> Client {
  Client(..client, base_url: url)
}

/// Whether the given Client is commercial or not.
pub fn is_commercial(client: Client) -> Bool {
  client.commercial
}

/// Returns the base url of the given Client.
pub fn get_base_url(client: Client) -> String {
  client.base_url
}

/// Gets the api_key of the given client.
///
/// If the client is not commercial, returns an empty string.
pub fn get_api_key(client: Client) -> String {
  client.key
}
