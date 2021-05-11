import UIKit

class SettingsViewController : UIViewController, UINavigationControllerDelegate {
  @IBOutlet weak var tempUnitSwitch: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tempUnitSwitch.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "isCelsius") ? 0 : 1
  }
  
  
  @IBAction func okPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func indexChanged(_ sender: Any) {
    switch tempUnitSwitch.selectedSegmentIndex
    {
    case 0:
      UserDefaults.standard.set(true, forKey: "isCelsius")
    case 1:
      UserDefaults.standard.set(false, forKey: "isCelsius")
    default:
      break;
    }
    NotificationCenter.default.post(name: Notification.Name("UnitsChanged"), object: nil)
  }
}
