import Foundation

public class ShopPhoto {
  var photos = [String: [String]]()
  var names = [String: String]()
  var gids = [String]()
  let path: URL
  
  // シングルトン実装
  static let sharedInstance = ShopPhoto()
  
  // イニシャライザ
  private init(){
    // データ保存先パスを取得
    path = try! FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false)
    
    // UserDefaultsからデータを読み込む
    load()
  }
  
  // データを読み込む
  private func load(){
    photos.removeAll()
    names.removeAll()
    gids.removeAll()
    let ud = UserDefaults.standard
    ud.register(defaults:[
      "photos": [String: [String]](),
      "names": [String: String](),
      "gids": [String]()
      ])
    ud.synchronize()
    if let photos = ud.object(forKey: "photos") as? [String: [String]] {
      self.photos = photos
    }
    if let names = ud.object(forKey: "names") as? [String: String] {
      self.names = names
    }
    if let gids = ud.object(forKey: "gids") as? [String] {
      self.gids = gids
    }
  }
  
  // データを書き込む
  private func save(){
    let ud = UserDefaults.standard
    ud.set(photos, forKey: "photos")
    ud.set(names, forKey: "names")
    ud.set(gids, forKey: "gids")
    ud.synchronize()
  }
  
  // 写真を追加する
  public func append(shop: Shop, image: UIImage){
    // 店舗IDか店舗名が無ければ終わり
    if shop.gid == nil { return }
    if shop.name == nil { return }
    // UIImageからJPEGデータ作成
    guard let data = UIImageJPEGRepresentation(image, 0.8) else {
      return
    }
    // ファイル名作成
    let filename = NSUUID().uuidString + ".jpg"
    // 書き込み先URL作成
    let fileURL = path.appendingPathComponent(filename)
    // 書き込み
    do {
      try data.write(to: fileURL, options: .atomic)
    } catch {
      print(error)
      return
    }
    // 書き込みに成功したら配列に格納して保存
    if photos[shop.gid!] == nil {
      // 初めての店舗なら準備する
      photos[shop.gid!] = [String]()
    } else {
      // 初めての店舗でなければ順番だけ変更する
      gids = gids.filter { $0 != shop.gid! }
    }
    gids.append(shop.gid!)
    
    // ファイル名を配列に格納
    photos[shop.gid!]?.append(filename)
    // 店舗名を格納
    names[shop.gid!] = shop.name
    // UserDefaultに保存
    save()
  }
  // 指定された店舗・インデックスの写真を返す
  public func image(gid: String, index: Int) -> UIImage {
    if photos[gid] == nil { return UIImage() }
    guard let photoCount = photos[gid]?.count else { return UIImage() }
    if index >= photoCount { return UIImage() }
    
    if let filename = photos[gid]?[index] {
      let fileURL = path.appendingPathComponent(filename)
      guard let data = try? Data(contentsOf: fileURL) else {
        return UIImage()
      }
      if let image = UIImage(data: data) {
        return image
      }
    }
    
    return UIImage()
  }
  
  // 店舗IDで指定された店舗の写真枚数を返す
  public func count(gid: String) -> Int {
    if photos[gid] == nil { return 0 }
    return photos[gid]!.count
  }
  
  // インデックスで指定された店舗の写真枚数を返す
  public func numberOfPhotos(in index: Int) -> Int {
    if index >= gids.count { return 0 }
    if let photos = photos[gids[index]] {
      return photos.count
    }
    return 0
  }
}
