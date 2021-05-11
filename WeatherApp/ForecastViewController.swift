import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire
import AlamofireObjectMapper

class ForecastViewController : UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
  let locationManager = CLLocationManager()
  let refreshControl = UIRefreshControl()
  var forecastArray : [Forecast]?
  
  //constants
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/onecall"
  let APP_ID = "APP_ID"
      
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  @objc func refresh(refrshcontrol: UIRefreshControl){
    print("refreshed")
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, YYYY hh:mm:ss"
    dateFormatter.timeZone = .current
    refreshControl.attributedTitle = NSAttributedString(string:"Last updated on " + dateFormatter.string(from: date), attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    refreshControl.endRefreshing()
    getWeatherData(location: "Waterloo, ON")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    searchBar.delegate = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(tableView)
    NSLayoutConstraint.activate([
        self.searchBar.bottomAnchor.constraint(equalTo: tableView.topAnchor),
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
        self.view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
        self.view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        ])
    self.refreshControl.tintColor = UIColor.white;
    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    
    if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
      textfield.textColor = UIColor.white
      let imageV = textfield.leftView as! UIImageView
      imageV.image = imageV.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
      imageV.tintColor = UIColor.gray
    }
    
    tableView.addSubview(refreshControl)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    if let cityName = searchBar.text, !cityName.isEmpty {
        getWeatherData(location: cityName)
    }
  }
  
  func getCoordinate( addressString : String,
                      completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(addressString) { (placemarks, error) in
      if error == nil {
        if let placemark = placemarks?[0] {
          let location = placemark.location!
          
          completionHandler(location.coordinate, nil)
          return
        }
      }
      completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
    }
  }
  
  func getWeatherData(location: String){
    getCoordinate(addressString: location, completionHandler: {coord,error in
      let lon = String(coord.longitude)
      let lat = String(coord.latitude)
      let params : [String:String] = ["lat": lat, "lon": lon, "cnt": "7", "appid": self.APP_ID, "exclude": "current,minutely,hourly,alerts"]
      
      Alamofire.request(self.WEATHER_URL, method: .get, parameters: params).responseArray(keyPath: "daily"){ (response: DataResponse<[Forecast]>) in
        if let forecastArray = response.result.value{
          self.forecastArray = forecastArray
          self.tableView.reloadData()
        } else{
          let alert = UIAlertController(title: "Error", message: "Could not fetch forecast data", preferredStyle: UIAlertController.Style.alert)
          alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
          print(error ?? "Could not fetch forecast data")
        }
      }
    })
  }
  
  func fillForecastData(json: JSON) {
    
    self.tableView.reloadData()
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    let weatherObject = forecastArray?[indexPath.section]
    
    //cell.textLabel?.text = weatherObject.description
    cell.textLabel?.text = "\(String(describing: weatherObject?.temperature ?? 0))°"
    //cell.imageView?.image = UIImage(named: weatherObject.icon)
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.forecastArray?.count ?? 0
  }
}
