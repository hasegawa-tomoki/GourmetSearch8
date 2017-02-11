import UIKit

class FreewordTableViewCell: UITableViewCell {
  @IBOutlet weak var freeword: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
