import UIKit

class CustomCell: UICollectionViewCell {
  
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var weatherIcon: UIImageView!
  
  func configureCell(forecast: Forecast) {
    dayLabel.text = forecast.convertUnixToDate(unix: forecast.date)
    let iconName = forecast.condition[0].getWeatherIconName()
    weatherIcon.image = UIImage(named: iconName)
    let current = forecast.getTemp(temp: forecast.temperature)
    let min = forecast.getTemp(temp: forecast.minTemp)
    let max = forecast.getTemp(temp: forecast.maxTemp)
    let feels = forecast.getTemp(temp: forecast.feelsLike)
    tempLabel.text = "Current: \(String(format: "%.0f", current))º Min: \(String(format: "%.0f", min))º Max: \(String(format: "%.0f", max))º Fells like: \(String(format: "%.0f", feels))º"
  }
}
