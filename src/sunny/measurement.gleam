import gleam/float

/// Represents a physical measurement with a unit 
pub type Measurement {
  Measurement(value: Float, unit: String)
}

/// Converts a measurement to a string, displaying its unit.
pub fn to_string(m: Measurement) -> String {
  float.to_string(m.value)
  <> case m.unit {
    "" -> ""
    _ -> " " <> m.unit
  }
}
