import UIKit

class SearchTopTableViewController: UITableViewController, UITextFieldDelegate {
  var freeword: UITextField? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - UITableViewDelegate
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
      return 1
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 && indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Freeword") as! FreewordTableViewCell
      // UITextFieldへの参照を保存しておく
      freeword = cell.freeword
      
      // UITextFieldDelegateを自身に設定
      cell.freeword.delegate = self
      // タップを無視
      cell.selectionStyle = .none
      
      return cell
    }
    return UITableViewCell()
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
  }
  
  // MARK: - IBAction
  @IBAction func onTap(_ sender: UITapGestureRecognizer) {
    freeword?.resignFirstResponder()
  }
}
