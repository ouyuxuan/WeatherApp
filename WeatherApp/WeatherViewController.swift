import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import CoreData

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate  {
  
  //constants
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
  let APP_ID = "APP_ID"
  
  let locationManager = CLLocationManager()
  let weatherDataModel = WeatherDataModel()
  var refreshControl : UIRefreshControl!
  var scrollView : UIScrollView!
  
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
    
    scrollView = UIScrollView()
    scrollView.isUserInteractionEnabled = true
    scrollView.bounces  = true
    scrollView.isScrollEnabled = true
    scrollView.alwaysBounceVertical = true
    
    refreshControl = UIRefreshControl()
    
    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
    self.view.addSubview(scrollView)
    scrollView.addSubview(refreshControl)
  
    UserDefaults.standard.set(true, forKey: "isCelsius")
    NotificationCenter.default.addObserver(self, selector: #selector(self.unitsChangedReceived(notification:)), name: Notification.Name("UnitsChanged"), object: nil)
  }
  
  @objc func unitsChangedReceived(notification: Notification) {
      updateUIWithWeatherData()
  }

  @objc func refresh(_ : UIRefreshControl) {
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.attributedTitle = NSAttributedString(string:"Last updated on" + NSDate().description)
    locationManager.startUpdatingLocation()
    refreshControl.endRefreshing()
  }
  //MARK: - Networking
  /***************************************************************/
  
  //get data from server
  func getWeatherData(url: String, parameters: [String : String]){
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
      response in
      if (response.result.isSuccess) {
        let weatherJSON : JSON = JSON(response.result.value!)
        self.updateWeatherData(json: weatherJSON)
      }
      else{
        self.cityLabel.text = "No internet connection..."
      }
    }
  }
  
  //MARK: - JSON Parsing
  /***************************************************************/
  
  
  //parse json data received
  func updateWeatherData(json: JSON){
    if let tempResult = json["main"]["temp"].double {
      weatherDataModel.temperature = tempResult
      weatherDataModel.city = json["name"].stringValue
      weatherDataModel.condition = json["weather"][0]["id"].intValue
      weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
      weatherDataModel.minTemp = json["main"]["temp_min"].double!
      weatherDataModel.maxTemp = json["main"]["temp_max"].double!
      
      if let wind = json["wind"]["speed"].double {
        weatherDataModel.windSpeed = wind
        weatherDataModel.direction = json["wind"]["deg"].double!
        weatherDataModel.directionStr = weatherDataModel.convertDegreeToDirection(direction: weatherDataModel.direction)
      }
      updateUIWithWeatherData()
    }
    else {
      cityLabel.text = "Weather unavailable"
    }
  }
  
  
  //MARK: - UI Updates
  /***************************************************************/
  
  
  //update UI elements
  func updateUIWithWeatherData(){
    cityLabel.text = weatherDataModel.city
    temperatureLabel.text = "\(String(format: "%.0f", weatherDataModel.getTemp(temp: weatherDataModel.temperature)))°"
    weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    minTemp.text = "Min \(String(format: "%.0f", weatherDataModel.getTemp(temp: weatherDataModel.minTemp)))°"
    maxTemp.text = "Max \(String(format: "%.0f", weatherDataModel.getTemp(temp: weatherDataModel.maxTemp)))°"
    let windUnits = UserDefaults.standard.bool(forKey: "isCelsius") ? " m/s" : " mph"
    let windSpeed = weatherDataModel.getSpeed(speed: weatherDataModel.windSpeed)
    windSpeedLbl.text = "Windspeed: \(String(format: "%.2f", windSpeed))" + windUnits
    directionLbl.text = "Direction: " + weatherDataModel.directionStr
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
