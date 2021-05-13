import UIKit
import Alamofire
import AlamofireObjectMapper

class ForecastViewController : UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  //constants
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/onecall"
  let APP_ID = "APP_ID"
  
  let refreshControl = UIRefreshControl()
  var forecastArray : [Forecast]?

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.alwaysBounceVertical = true
    collectionView.dataSource = self
    collectionView.delegate = self
    refreshControl.tintColor = UIColor.white;
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    collectionView.addSubview(refreshControl)
    NotificationCenter.default.addObserver(self, selector: #selector(self.unitsChangedReceived(notification:)), name: Notification.Name("UnitsChanged"), object: nil)
    getWeatherData()
  }
  
  @objc func unitsChangedReceived(notification: Notification) {
    collectionView.reloadData()
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
        self.collectionView.reloadData()
      } else{
        let alert = UIAlertController(title: "Error", message: "Could not fetch forecast data", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print("Could not fetch forecast data")
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return forecastArray?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    var cell = UICollectionViewCell()
    if let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCell {
      customCell.configureCell(forecast: forecastArray![indexPath.row])
      cell = customCell
    }
    return cell
  }
}
