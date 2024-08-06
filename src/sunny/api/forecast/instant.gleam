/// Variables that can be obtained at a specific time (for `hourly`, `minutely`
/// and `current` fields)
/// 
/// See https://open-meteo.com/en/docs
pub type InstantVariable {
  Temperature2m
  Temperature80m
  Temperature120m
  Temperature180m
  RelativeHumidity2m
  DewPoint2m
  ApparentTemperature
  PressureMsl
  SurfacePressure
  CloudCover
  CloudCoverLow
  CloudCoverMid
  CloudCoverHigh
  WindSpeed10m
  WindSpeed80m
  WindSpeed120m
  WindSpeed180m
  WindDirection10m
  WindDirection80m
  WindDirection120m
  WindDirection180m
  WindGusts10m
  Precipitation
  Snowfall
  PrecipitationProbability
  Rain
  Showers
  WeatherCode
  SnowDepth
  FreezingLevelHeight
  Visibility
  IsDay
}

pub const all = [
  Temperature2m, Temperature80m, Temperature120m, Temperature180m,
  RelativeHumidity2m, DewPoint2m, ApparentTemperature, PressureMsl,
  SurfacePressure, CloudCover, CloudCoverLow, CloudCoverMid, CloudCoverHigh,
  WindSpeed10m, WindSpeed80m, WindSpeed120m, WindSpeed180m, WindDirection10m,
  WindDirection80m, WindDirection120m, WindDirection180m, WindGusts10m,
  Precipitation, Snowfall, PrecipitationProbability, Rain, Showers, WeatherCode,
  SnowDepth, FreezingLevelHeight, Visibility, IsDay,
]
