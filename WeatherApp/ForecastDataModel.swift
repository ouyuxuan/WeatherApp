import Foundation
import ObjectMapper

class Forecast: Mappable {
  var condition : [Condition]
  var temperature : Double
  var maxTemp : Double
  var minTemp : Double
  var feelsLike : Double
  var date : Int

  required init?(map: Map) {
    condition = []
    temperature = 0
    maxTemp = 0
    minTemp = 0
    feelsLike = 0
    date = 0
  }
  
  func mapping(map: Map) {
    condition <- map["weather"]
    temperature <- map["temp.day"]
    maxTemp <- map["temp.max"]
    minTemp <- map["temp.min"]
    feelsLike <- map["feels_like.day"]
    date <- map["dt"]
  }
  
  func convertUnixToDate(unix: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(unix))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E, MMM d"
    dateFormatter.timeZone = .current
    return dateFormatter.string(from: date)
  }
  
  func getTemp(temp: Double) -> Double {
    let t = temp - 273.15
    if UserDefaults.standard.bool(forKey: "isCelsius") {
      return t
    } else {
      return t * (1.8) + 32
    }
  }
}
