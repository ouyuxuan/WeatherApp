import Foundation
import ObjectMapper

class Forecast: Mappable {
  var temperature : Double
  var maxTemp : Double
  var minTemp : Double
  var feelsLike : Double
  var date : String
  
  required init?(map: Map) {
    temperature = 0
    maxTemp = 0
    minTemp = 0
    feelsLike = 0
    date = ""
  }
  
  func mapping(map: Map) {
    temperature <- map["temp.day"]
    maxTemp <- map["temp.max"]
    minTemp <- map["temp.min"]
    feelsLike <- map["feels_like.day"]
    date <- map["dt"]
  }
  
  func convertUnixToDate(unix: Double) -> String {
    let date = Date(timeIntervalSince1970: unix)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E, MMM d"
    dateFormatter.timeZone = .current
    return dateFormatter.string(from: date)
  }
}
