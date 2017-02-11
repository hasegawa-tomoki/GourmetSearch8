import UIKit

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet weak var tableView: UITableView!
  
  var yls: YahooLocalSearch = YahooLocalSearch()
  var loadDataObserver: NSObjectProtocol?
  var refreshObserver: NSObjectProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Pull to Refreshコントロール初期化
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self,
                             action: #selector(ShopListViewController.onRefresh(_:)),
                             for: .valueChanged)
    self.tableView.addSubview(refreshControl)
    
    // お気に入りでなければ編集ボタンを削除
    if !(self.navigationController is FavoriteNavigationController) {
      self.navigationItem.rightBarButtonItem = nil
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    /*
     var qc = QueryCondition()
     qc.query = "ハンバーガー"
     
     yls = YahooLocalSearch(condition: qc)
     */
    
    // 読込完了通知を受信した時の処理
    loadDataObserver = NotificationCenter.default.addObserver(
      forName: .apiLoadComplete,
      object: nil,
      queue: nil,
      using: {
        (notification) in
        
        // 店舗ID（Gid）が指定されたいたらその順番に並べ替える
        if self.yls.condition.gid != nil {
          self.yls.sortByGid()
        }
        
        self.tableView.reloadData()
        
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
    
    if yls.shops.count == 0 {
      if self.navigationController is FavoriteNavigationController {
        // お気に入り: お気に入りから検索条件を作って検索
        loadFavorites()
        // ナビゲーションバータイトル設定
        self.navigationItem.title = "お気に入り"
      } else {
        // 検索: 設定された検索条件から検索
        yls.loadData(reset: true)
        // ナビゲーションバータイトル設定
        self.navigationItem.title = "店舗一覧"
      }
    }
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
    // セルの高さを返す
    return 100
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // セルの選択状態を解除する
    tableView.deselectRow(at: indexPath, animated: true)
    // Segueを実行する
    performSegue(withIdentifier: "PushShopDetail", sender: indexPath)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // お気に入りなら削除可能
    return self.navigationController is FavoriteNavigationController
  }
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    // 削除の場合
    if editingStyle == .delete {
      guard let gid = yls.shops[indexPath.row].gid else {
        return
      }
      // User Defaultsに反映する
      Favorite.remove(gid)
      // yls.shopsに反映する
      yls.shops.remove(at: indexPath.row)
      // UITableView上の見た目に反映する
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // お気に入りなら順番編集可能
    return self.navigationController is FavoriteNavigationController
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    // 移動元と移動先が同じなら何もしない
    if sourceIndexPath == destinationIndexPath { return }
    
    // yls.shopsに反映する
    let source = yls.shops[sourceIndexPath.row]
    yls.shops.remove(at: sourceIndexPath.row)
    yls.shops.insert(source, at: destinationIndexPath.row)
    
    // User Defaultsに反映する
    Favorite.move(sourceIndexPath.row, to: destinationIndexPath.row)
  }
  
  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      // セルの数は店舗数
      return yls.shops.count
    }
    // 通常はここに到達しない
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      if indexPath.row < yls.shops.count {
        // rowが店舗数以下なら店舗セルを返す
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopListItem") as! ShopListItemTableViewCell
        cell.shop = yls.shops[indexPath.row]
        
        // まだ残りがあって、現在の列の下の店舗が3つ以下になったら追加取得
        if yls.shops.count < yls.total {
          if yls.shops.count - indexPath.row <= 4 {
            yls.loadData()
          }
        }
        
        return cell
      }
    }
    // 通常はここに到達しない
    return UITableViewCell()
  }
  
  // MARK: - アプリケーションロジック
  
  func loadFavorites(){
    // お気に入りをUser Defaultsから読み込む
    Favorite.load()
    
    // お気に入りがあれば店舗ID（Gid）一覧を作成して検索を実行する
    if Favorite.favorites.count > 0 {
      // お気に入り一覧を表現する検索条件オブジェクト
      var condition = QueryCondition()
      // favoritesプロパティの配列の中身を「,」で結合して文字列にする
      condition.gid = Favorite.favorites.joined(separator: ",")
      
      // 検索条件を設定して検索実行
      yls.condition = condition
      yls.loadData(reset: true)
    } else {
      // お気に入りがなければ検索を実行せずAPI読込完了通知
      NotificationCenter.default.post(name: .apiLoadComplete, object: nil)
    }
  }
  
  // Pull to Refresh
  func onRefresh(_ refreshControl: UIRefreshControl){
    // UIRefreshControlを読込中状態にする
    refreshControl.beginRefreshing()
    
    // 終了通知を受信したらUIRefreshControlを停止する
    refreshObserver = NotificationCenter.default.addObserver(
      forName: .apiLoadComplete,
      object: nil,
      queue: nil,
      using: {
        notification in
        // 通知の待ち受けを終了
        NotificationCenter.default.removeObserver(self.refreshObserver!)
        // UITefreshControlを停止する
        refreshControl.endRefreshing()
    })
    
    if self.navigationController is FavoriteNavigationController {
      // お気に入り: User Defaultsからお気に入り一覧を再取得してAPI実行する
      loadFavorites()
    } else {
      // 検索: そのまま再取得する
      yls.loadData(reset: true)
    }
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PushShopDetail" {
      let vc = segue.destination as! ShopDetailViewController
      if let indexPath = sender as? IndexPath {
        vc.shop = yls.shops[indexPath.row]
      }
    }
  }
  
  // MARK: - IBAction
  @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
    if tableView.isEditing {
      tableView.setEditing(false, animated: true)
      sender.title = "編集"
    } else {
      tableView.setEditing(true, animated: true)
      sender.title = "完了"
    }
  }
}

