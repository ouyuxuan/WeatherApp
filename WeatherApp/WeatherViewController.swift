import UIKit
import CoreLocation
import Alamofire
import AlamofireObjectMapper

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate  {

  //constants
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
  let APP_ID = "APP_ID"
  
  var weatherData = WeatherDataModel()
  let locationManager = CLLocationManager()
  let refreshControl = UIRefreshControl()
  @IBOutlet weak var scrollView: UIScrollView!

  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var minTemp: UILabel!
  @IBOutlet weak var maxTemp: UILabel!

  @IBOutlet weak var windSpeedLbl: UILabel!
  @IBOutlet weak var toolBar: UIToolbar!
  @IBOutlet weak var directionLbl: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    scrollView.isUserInteractionEnabled = true
    scrollView.bounces  = true
    scrollView.isScrollEnabled = true
    scrollView.alwaysBounceVertical = true
    refreshControl.tintColor = UIColor.white;
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
    view.addSubview(scrollView)
    scrollView.addSubview(refreshControl)

    UserDefaults.standard.set(true, forKey: "isCelsius")
    NotificationCenter.default.addObserver(self, selector: #selector(self.unitsChangedReceived(notification:)), name: Notification.Name("UnitsChanged"), object: nil)
  }

  @objc func unitsChangedReceived(notification: Notification) {
      updateUIWithWeatherData()
  }

  @objc func refresh(_ : UIRefreshControl) {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, YYYY hh:mm:ss"
    dateFormatter.timeZone = .current
    refreshControl.attributedTitle = NSAttributedString(string:"Last updated on " + dateFormatter.string(from: date), attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    let latitude = UserDefaults.standard.string(forKey: "latitude") ?? ""
    let longitude = UserDefaults.standard.string(forKey: "longitude") ?? ""
    let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
    getWeatherData(url: WEATHER_URL, parameters: params)
    refreshControl.endRefreshing()
  }
  //MARK: - Networking
  /***************************************************************/

  //get data from server
  func getWeatherData(url: String, parameters: [String : String]){
    Alamofire.request(url, method: .get, parameters: parameters).responseObject() { (response: DataResponse<WeatherDataModel>) in
      if let data = response.result.value {
        self.weatherData = data
        self.setDefaults()
        self.updateUIWithWeatherData()
      } else {
        self.cityLabel.text = "No internet connection..."
      }
    }
  }

  func setDefaults() {
    UserDefaults.standard.set(self.weatherData.latitude, forKey: "latitude")
    UserDefaults.standard.set(self.weatherData.longitude, forKey: "longitude")
  }

  //MARK: - UI Updates
  /***************************************************************/

  //update UI elements
  func updateUIWithWeatherData(){
    cityLabel.text = weatherData.city
    weatherData.weatherIconName = weatherData.condition[0].getWeatherIconName()
    weatherData.directionStr = weatherData.convertDegreeToDirection()
    temperatureLabel.text = "\(String(format: "%.0f", weatherData.getTemp(temp: weatherData.temperature)))°"
    weatherIcon.image = UIImage(named: weatherData.weatherIconName)
    minTemp.text = "Min: \(String(format: "%.0f", weatherData.getTemp(temp: weatherData.minTemp)))°"
    maxTemp.text = "Max: \(String(format: "%.0f", weatherData.getTemp(temp: weatherData.maxTemp)))°"
    let windUnits = UserDefaults.standard.bool(forKey: "isCelsius") ? " m/s" : " mph"
    let windSpeed = weatherData.getSpeed(speed: weatherData.windSpeed)
    windSpeedLbl.text = "Windspeed: \(String(format: "%.2f", windSpeed))" + windUnits
    directionLbl.text = "Direction: " + weatherData.directionStr
  }

  //MARK: - Location Manager Delegate Methods
  /***************************************************************/

  //get location information of GPS
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[locations.count - 1]
    if (location.horizontalAccuracy > 0){
      locationManager.stopUpdatingLocation()
      let latitude = String(location.coordinate.latitude)
      let longitude = String(location.coordinate.longitude)
      let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
      getWeatherData(url: WEATHER_URL, parameters: params)
    }
  }

  //error when getting location
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    cityLabel.text = "Location Unavailable"
  }


  //MARK: - Change City Delegate methods
  /***************************************************************/

  //Write the userEnteredANewCityName Delegate method here:
  func userEnteredNewCityName(city: String) {
    let params : [String : String] = ["q" : city, "appid" : APP_ID]
    getWeatherData(url: WEATHER_URL, parameters: params)
  }

  //Write the PrepareForSegue Method here
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "changeCityName" {
      let destinationVC = segue.destination as! ChangeCityViewController
      destinationVC.delegate = self
    }
  }
}
