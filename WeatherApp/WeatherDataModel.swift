import Foundation
import ObjectMapper

class WeatherDataModel : Mappable{
  var temperature : Double = 0
  var condition : [Condition] = []
  var city : String = ""
  var weatherIconName : String = ""
  var maxTemp : Double = 0
  var minTemp : Double = 0
  var windSpeed : Double = 0
  var direction : Double = 0
  var directionStr : String = ""
  var latitude : Double = 0
  var longitude : Double = 0
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    temperature <- map["main.temp"]
    condition <- map["weather"]
    city <- map["name"]
    minTemp <- map["main.temp_min"]
    maxTemp <- map["main.temp_max"]
    windSpeed <- map["wind.speed"]
    direction <- map["wind.deg"]
    latitude <- map["coord.lat"]
    longitude <- map["coord.lon"]
  }
  
  func convertDegreeToDirection() -> String {
    switch (self.direction) {
    case 348.75...360, 0...11.25:
        return "N"
    case 11.26...33.75:
        return "NNE"
    case 33.76...56.25:
        return "NE"
    case 56.26...78.75:
        return "ENE"
    case 78.26...101.25:
        return "E"
    case 101.26...123.75:
        return "ESE"
    case 123.76...146.25:
        return "SE"
    case 146.26...168.75:
        return "SSE"
    case 168.76...191.25:
        return "S"
    case 191.25...213.75:
        return "SSW"
    case 213.76...236.25:
        return "SW"
    case 236.26...258.75:
        return "WSW"
    case 258.76...281.75:
        return "W"
    case 281.76...303.75:
        return "WNW"
    case 303.76...326.25:
        return "NW"
    case 326.26...348.75:
        return "NNW"
    default:
        return " "
    }
  }
  
  func getTemp(temp: Double) -> Double {
    let t = temp - 273.15
    if UserDefaults.standard.bool(forKey: "isCelsius") {
      return t
    } else {
      return t * (1.8) + 32
    }
  }
  
  func getSpeed(speed: Double) -> Double {
    if UserDefaults.standard.bool(forKey: "isCelsius") {
      return speed
    } else {
      return speed * 2.237
    }
  }
}
