import UIKit
import MapKit
import Social

class ShopDetailViewController: UIViewController, UIScrollViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var photo: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var tel: UILabel!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var map: MKMapView!
  @IBOutlet weak var favoriteIcon: UIImageView!
  @IBOutlet weak var favoriteLabel: UILabel!
  @IBOutlet weak var line: UIButton!
  @IBOutlet weak var twitter: UIButton!
  @IBOutlet weak var facebook: UIButton!
  
  @IBOutlet weak var nameHeight: NSLayoutConstraint!
  @IBOutlet weak var addressContainerHeight: NSLayoutConstraint!
  
  var shop = Shop()
  let ipc = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 写真
    if let url = shop.photoUrl {
      photo.sd_setImage(with: URL(string: url),
                        placeholderImage: UIImage(named: "loading"));
    } else {
      photo.image = UIImage(named: "loading")
    }
    // 店舗名
    name.text = shop.name
    // 電話番号
    tel.text = shop.tel
    // 住所
    address.text = shop.address
    
    if let lat = shop.lat {
      if let lon = shop.lon {
        // 地図の表示範囲を指定
        let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 200, 200)
        map.setRegion(mkcr, animated: false)
        // ピンを設定
        let pin = MKPointAnnotation()
        pin.coordinate = cllc
        map.addAnnotation(pin)
      }
    }
    
    // お気に入り状態をボタンラベルに反映
    updateFavoriteButton()
    
    // UIImagePickerControllerDelegateの設定
    // Delegate設定
    ipc.delegate = self
    // トリミングなどを行う
    ipc.allowsEditing = true
    
    // LINEの利用可能状態をチェック
    if UIApplication.shared.canOpenURL(URL(string: "line://")!){
      line.isEnabled = true
    }
    // Twitterの利用可能状態をチェック
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
      twitter.isEnabled = true
    }
    // Facebookの利用可能状態をチェック
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
      facebook.isEnabled = true
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.scrollView.delegate = self
    super.viewWillAppear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    self.scrollView.delegate = nil
    super.viewDidDisappear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLayoutSubviews() {
    let nameFrame = name.sizeThatFits(
      CGSize(width: name.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
    nameHeight.constant = nameFrame.height
    
    let addressFrame = address.sizeThatFits(
      CGSize(width: address.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
    addressContainerHeight.constant = addressFrame.height
    
    view.layoutIfNeeded()
  }
  
  // MARK: - UIImagePickerControllerDelegate
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    ipc.dismiss(animated: true, completion: nil)
  }
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
      ShopPhoto.sharedInstance.append(shop: shop, image: image)
    }
    
    ipc.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - UIScrollViewDelegate
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
    if scrollOffset <= 0 {
      photo.frame.origin.y = scrollOffset
      photo.frame.size.height = 200 - scrollOffset
    }
  }
  
  // MARK: - アプリケーションロジック
  func share(type: String){
    guard let vc = SLComposeViewController(forServiceType: type) else {
      return
    }
    if let name = shop.name {
      vc.setInitialText(name + "\n")
    }
    
    if let gid = shop.gid {
      if ShopPhoto.sharedInstance.count(gid: gid) > 0 {
        // 写真があれば追加する
        vc.add(ShopPhoto.sharedInstance.image(gid: gid, index: 0))
      }
    }
    
    if let url = shop.url {
      // URLを作って追加する
      vc.add(URL(string: url))
    }
    
    self.present(vc, animated: true, completion: nil)
  }
  
  func updateFavoriteButton(){
    guard let gid = shop.gid else {
      return
    }
    
    if Favorite.inFavorites(gid) {
      // お気に入りに入っている
      favoriteIcon.image = UIImage(named: "star-on")
      favoriteLabel.text = "お気に入りからはずす"
    } else {
      // お気に入りに入っていない
      favoriteIcon.image = UIImage(named: "star-off")
      favoriteLabel.text = "お気に入りに入れる"
    }
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PushMapDetail" {
      let vc = segue.destination as! ShopMapDetailViewController
      vc.shop = shop
    }
  }
  
  // MARK: - IBAction
  @IBAction func telTapped(_ sender: UIButton) {
    guard let tel = shop.tel else {
      return
    }
    guard let url = URL(string: "tel:\(tel)") else {
      return
    }
    
    if !UIApplication.shared.canOpenURL(url) {
      let alert = UIAlertController(title: "電話をかけることができません",
                                    message: "この端末には電話機能が搭載されていません。",
                                    preferredStyle: .alert)
      alert.addAction(
        UIAlertAction(title: "OK", style: .default, handler: nil)
      )
      present(alert, animated: true, completion: nil)
      return
    }
    
    guard let name = shop.name else {
      return
    }
    
    let alert = UIAlertController(title: "電話", message: "\(name)に電話をかけます。", preferredStyle: .alert)
    alert.addAction(
      UIAlertAction(title: "電話をかける", style: .destructive, handler: {
        action in
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return
      })
    )
    
    alert.addAction(
      UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
    )
    
    present(alert, animated: true, completion: nil)
  }
  
  @IBAction func addressTapped(_ sender: UIButton) {
    performSegue(withIdentifier: "PushMapDetail", sender: nil)
  }
  
  @IBAction func favoriteTapped(_ sender: UIButton) {
    guard let gid = shop.gid else {
      return
    }
    // お気に入りセル: お気に入り状態を変更する
    Favorite.toggle(gid)
    updateFavoriteButton()
  }
  
  @IBAction func addPhotoTapped(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // カメラが使えるか確認して使えるなら「写真を撮る」選択肢を表示
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      alert.addAction(
        UIAlertAction(title: "写真を撮る", style: .default, handler: {
          action in
          // ソースはカメラ
          self.ipc.sourceType = .camera
          // カメラUIを起動
          self.present(self.ipc, animated: true, completion: nil)
        })
      )
    }
    
    // 「写真を選択」ボタンはいつでも使える
    alert.addAction(
      UIAlertAction(title: "写真を選択", style: .default, handler: {
        action in
        // ソースは写真選択
        self.ipc.sourceType = .photoLibrary
        // 写真選択UIを起動
        self.present(self.ipc, animated: true, completion: nil)
      })
    )
    alert.addAction(
      UIAlertAction(title: "キャンセル", style: .cancel, handler: {
        action in
      })
    )
    present(alert, animated: true, completion: nil)
  }
  
  @IBAction func lineTapped(_ sender: UIButton) {
    var message = ""
    
    if let name = shop.name {
      message += name + "\n"
    }
    
    if let url = shop.url {
      message += url + "\n"
    }
    
    if let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
      if let uri = URL(string: "line://msg/text/" + encoded) {
        UIApplication.shared.open(uri, options: [:], completionHandler: nil)
      }
    }
  }
  @IBAction func twitterTapped(_ sender: UIButton) {
    share(type: SLServiceTypeTwitter)
  }
  @IBAction func facebookTapped(_ sender: UIButton) {
    share(type: SLServiceTypeFacebook)
  }
}
