import UIKit

class PhotoListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    collectionView.reloadData()
  }
  
  // MARK: - UICollectionViewDelegateFlowLayout
  
  // セルのサイズを調整する
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = self.view.frame.size.width / 3
    return CGSize(width: size, height: size)
  }
  
  // MARK: - UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    // セクションの数 = 店舗数を返す
    return ShopPhoto.sharedInstance.gids.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return ShopPhoto.sharedInstance.numberOfPhotos(in: section)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    // Storyboardで設定したセルを取得する
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "PhotoListItem",
      for: indexPath) as! PhotoListItemCollectionViewCell
    
    // 指定されたインデックスの店舗IDを取得する
    let gid = ShopPhoto.sharedInstance.gids[indexPath.section]
    
    // 店舗IDとインデックスを指定して写真を取得し、セルに設定する
    cell.photo.image = ShopPhoto.sharedInstance.image(gid: gid, index: indexPath.row)
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    // ヘッダの場合のみ処理をする
    if kind == UICollectionElementKindSectionHeader {
      // Storyboardで設定したヘッダを取得する
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: UICollectionElementKindSectionHeader,
        withReuseIdentifier: "PhotoListHeader",
        for: indexPath) as! PhotoListItemCollectionViewHeader
      
      // 指定されたインデックスの店舗IDを取得する
      let gid = ShopPhoto.sharedInstance.gids[indexPath.section]
      
      // 店舗名を取得する
      let name = ShopPhoto.sharedInstance.names[gid]
      
      // ヘッダに店舗名を設定する
      header.title.text = name
      
      return header
    }
    
    return UICollectionReusableView()
  }
}
