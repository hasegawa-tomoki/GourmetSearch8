import UIKit
import CoreLocation

class SearchTopTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
  var freeword: UITextField? = nil
  
  let ls = LocationService()
  let nc = NotificationCenter.default
  var observers = [NSObjectProtocol]()
  var here: (lat: Double, lon: Double)? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    // 位置情報取得を禁止している場合
    observers.append(
      nc.addObserver(forName: .authDenied, object: nil, queue: nil, using: {
        notification in
        // 位置情報がONになっていないダイアログ表示
        self.present(self.ls.locationServiceDisabledAlert,
                     animated: true,
                     completion: nil)
      })
    )
    
    // 位置情報取得を制限している場合
    observers.append(
      nc.addObserver(forName: .authRestricted, object: nil, queue: nil, using: {
        notification in
        // 位置情報が制限されているダイアログ表示
        self.present(self.ls.locationServiceRestrictedAlert,
                     animated: true,
                     completion: nil)
      })
    )
    
    // 位置情報取得に失敗した場合
    observers.append(
      nc.addObserver(forName: .didFailLocation, object: nil, queue: nil, using: {
        notification in
        // 位置情報取得に失敗したダイアログ
        self.present(self.ls.locationServiceDidFailAlert,
                     animated: true,
                     completion: nil)
      })
    )
    
    // 位置情報を取得した場合
    observers.append(
      nc.addObserver(forName: .didUpdateLocation, object: nil, queue: nil, using: {
        notification in
        
        // 位置情報が渡されていなければ早期離脱
        guard let userInfo = notification.userInfo as? [String: CLLocation] else {
          return
        }
        
        // userInfoがキー location を持っていなければ早期離脱
        guard let clloc = userInfo["location"] else {
          return
        }
        
        self.here = (
          lat: clloc.coordinate.latitude,
          lon: clloc.coordinate.longitude
        )
        
        self.performSegue(withIdentifier: "PushShopListFromHere", sender: self)
      })
    )
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    // Notificationの待ち受けを解除する
    for observer in observers {
      nc.removeObserver(observer)
    }
    observers = []
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 && indexPath.row == 1 {
      ls.startUpdatingLocation()
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
  }
  
  // MARK: - UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 2
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      switch indexPath.row {
      case 0:
        let cell = tableView.dequeueReusableCell(withIdentifier: "Freeword") as! FreewordTableViewCell
        // UITextFieldへの参照を保存しておく
        freeword = cell.freeword
        // UITextFieldDelegateを自身に設定
        cell.freeword.delegate = self
        // タップを無視
        cell.selectionStyle = .none
        
        return cell
        
      case 1:
        let cell = UITableViewCell()
        cell.textLabel?.text = "現在地から検索"
        cell.accessoryType = .disclosureIndicator
        
        return cell
        
      default:
        return UITableViewCell()
      }
    }
    
    return UITableViewCell()
  }
  
  // MARK: - UIGestureRecognizerDelegate
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if let ifr = freeword?.isFirstResponder {
      return ifr
    }
    return false
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    performSegue(withIdentifier: "PushShopList", sender: self)
    
    return true
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PushShopList" {
      let vc = segue.destination as! ShopListViewController
      vc.yls.condition.query = freeword?.text
    }
    
    if segue.identifier == "PushShopListFromHere" {
      let vc = segue.destination as! ShopListViewController
      vc.yls.condition.lat = self.here?.lat
      vc.yls.condition.lon = self.here?.lon
    }
  }
  
  // MARK: - IBAction
  @IBAction func onTap(_ sender: UITapGestureRecognizer) {
    freeword?.resignFirstResponder()
  }
}
