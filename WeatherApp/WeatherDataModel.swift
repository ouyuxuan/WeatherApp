import Foundation

class WeatherDataModel {
  
  var temperature : Double = 0
  var condition : Int = 0
  var city : String = ""
  var weatherIconName : String = ""
  var maxTemp : Double = 0
  var minTemp : Double = 0
  var windSpeed : Double = 0
  var direction : Double = 0
  var directionStr : String = ""
  
  //This method turns a condition code into the name of the weather condition image
  func updateWeatherIcon(condition: Int) -> String {
    switch (condition) {
    case 0...300 :
        return "tstorm1"
    case 301...500 :
        return "light_rain"
    case 501...600 :
        return "shower3"
    case 601...700 :
        return "snow4"
    case 701...771 :
        return "fog"
    case 772...799 :
        return "tstorm3"
    case 800 :
        return "sunny"
    case 801...804 :
        return "cloudy2"
    case 900...903, 905...1000  :
        return "tstorm3"
    case 903 :
        return "snow5"
    case 904 :
        return "sunny"
    default :
        return "dunno"
    }
  }
  
  func convertDegreeToDirection(direction: Double) -> String {
    switch (direction) {
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
