import UIKit

class LicenseDetailViewController: UIViewController {
  @IBOutlet weak var text: UILabel!
  @IBOutlet weak var textHeight: NSLayoutConstraint!
  
  var name = ""
  var license = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    text.text = license
    title = name
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLayoutSubviews() {
    let frame = CGSize(width: text.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
    textHeight.constant = text.sizeThatFits(frame).height
    view.layoutIfNeeded()
  }
}
