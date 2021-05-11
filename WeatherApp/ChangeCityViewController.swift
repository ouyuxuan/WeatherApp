import UIKit

protocol ChangeCityDelegate {
  func userEnteredNewCityName (city : String)
}

class ChangeCityViewController: UIViewController {
  //delegate variable
  var delegate : ChangeCityDelegate?
  @IBOutlet weak var changeCityTextField: UITextField!
  @IBOutlet weak var getWeatherBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  //return to weatherVC when getWeather is pressed and pass the new city name
  @IBAction func getWeatherPressed(_ sender: AnyObject) {
    let cityName = changeCityTextField.text!
    delegate?.userEnteredNewCityName(city: cityName)
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func cancelPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func resetPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
