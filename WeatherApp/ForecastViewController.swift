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
      
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
        view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
        view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
        view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        ])
    refreshControl.tintColor = UIColor.white;
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    tableView.addSubview(refreshControl)
    getWeatherData()
  }
  
  @objc func refresh(refrshcontrol: UIRefreshControl){
    print("refreshed")
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, YYYY hh:mm:ss"
    dateFormatter.timeZone = .current
    refreshControl.attributedTitle = NSAttributedString(string:"Last updated on " + dateFormatter.string(from: date), attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    refreshControl.endRefreshing()
    getWeatherData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func getWeatherData(){
    let lon = UserDefaults.standard.string(forKey: "longitude") ?? ""
    let lat = UserDefaults.standard.string(forKey: "latitude") ?? ""
    let params : [String:String] = ["lat": lat, "lon": lon, "cnt": "7", "appid": self.APP_ID, "exclude": "current,minutely,hourly,alerts"]
    
    Alamofire.request(self.WEATHER_URL, method: .get, parameters: params).responseArray(keyPath: "daily"){ (response: DataResponse<[Forecast]>) in
      if let forecastArray = response.result.value{
        self.forecastArray = forecastArray
        self.tableView.reloadData()
      } else{
        let alert = UIAlertController(title: "Error", message: "Could not fetch forecast data", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print("Could not fetch forecast data")
      }
    }
    tableView.reloadData()
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
