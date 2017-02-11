import UIKit

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet weak var tableView: UITableView!
  
  var yls: YahooLocalSearch = YahooLocalSearch()
  var loadDataObserver: NSObjectProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    var qc = QueryCondition()
    qc.query = "ハンバーガー"
    
    yls = YahooLocalSearch(condition: qc)
    
    // 読込完了通知を受信した時の処理
    loadDataObserver = NotificationCenter.default.addObserver(
      forName: .apiLoadComplete,
      object: nil,
      queue: nil,
      using: {
        (notification) in
        print("APIリクエスト完了")
        // エラーがあればダイアログを開く
        if notification.userInfo != nil {
          if let userInfo = notification.userInfo as? [String: String?] {
            if userInfo["error"] != nil {
              let alertView = UIAlertController(title: "通信エラー",
                                                message: "通信エラーが発生しました。",
                                                preferredStyle: .alert)
              alertView.addAction(
                UIAlertAction(title: "OK", style: .default) {
                  action in return
                }
              )
              self.present(alertView,
                           animated: true, completion: nil)
            }
          }
        }
      }
    )
    
    yls.loadData(reset: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    // 通知の待ち受けを終了
    NotificationCenter.default.removeObserver(self.loadDataObserver!)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return 20
  }
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ShopListItem") as! ShopListItemTableViewCell
      cell.name.text = "\(indexPath.row)"
      return cell
    }
    return UITableViewCell()
  }
}

