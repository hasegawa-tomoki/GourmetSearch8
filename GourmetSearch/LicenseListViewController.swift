import UIKit

class LicenseListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet weak var tableView: UITableView!
  
  private struct Software {
    var name: String
    var license: String
  }
  
  private var softwares = [Software]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let path = Bundle.main.path(
      forResource: "Licenses", ofType: "plist") else {
        return
    }
    guard let items = NSArray(contentsOfFile: path) else {
      return
    }
    
    for item in items {
      guard let software = item as? NSDictionary else {
        continue
      }
      // ソフトウェア名、ライセンス文章ともにnilチェックする
      guard let name = software["Name"] as? String else {
        continue
      }
      guard let license = software["License"] as? String else {
        continue
      }
      // softwares配列に追加する
      softwares.append(Software(name: name, license: license))
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // セルの選択状態を解除する
    tableView.deselectRow(at: indexPath, animated: true)
    // Segueを実行する
    performSegue(withIdentifier: "PushLicenseDetail", sender: indexPath)
  }
  
  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Software", for: indexPath)
    cell.textLabel?.text = softwares[indexPath.row].name
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return softwares.count
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PushLicenseDetail" {
      let vc = segue.destination as! LicenseDetailViewController
      if let indexPath = sender as? NSIndexPath {
        vc.name = softwares[indexPath.row].name
        vc.license = softwares[indexPath.row].license
      }
    }
  }
}
