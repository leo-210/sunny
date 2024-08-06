/// Variables that can be obtained at for a specific day (for the `daily` field)
/// 
/// See https://open-meteo.com/en/docs
pub type DailyVariable {
  MaximumTemperature2m
  MinimumTemperature2m
  ApparentTemperatureMax
  ApparentTemperatureMin
  PrecipitationSum
  RainSum
  ShowersSum
  SnowfallSum
  PrecipitationHours
  PrecipitationProbabilityMax
  PrecipitationProbabilityMin
  PrecipitationProbabilityMean
  WorstWeatherCode
  // TODO: Implemeny `Sunrise` and `Sunset` variables (they're problematic because they're not integers nor floats, but dates.) 
  // Sunrise
  // Sunset
  SunshineSuration
  DaylightDuration
  WindSpeed10mMax
  WindGusts10mMax
  WindDirection10mDominant
}

pub const all = [
  MaximumTemperature2m, MinimumTemperature2m, ApparentTemperatureMax,
  ApparentTemperatureMin, PrecipitationSum, RainSum, ShowersSum, SnowfallSum,
  PrecipitationHours, PrecipitationProbabilityMax, PrecipitationProbabilityMin,
  PrecipitationProbabilityMean, WorstWeatherCode, SunshineSuration,
  DaylightDuration, WindSpeed10mMax, WindGusts10mMax, WindDirection10mDominant,
]
