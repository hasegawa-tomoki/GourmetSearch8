//
//  ShopListItemTableViewCell.swift
//  GourmetSearch
//
//  Created by 長谷川智希 on 2017/02/11.
//  Copyright © 2017年 長谷川智希. All rights reserved.
//

import UIKit

class ShopListItemTableViewCell: UITableViewCell {
  @IBOutlet weak var photo: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var iconContainer: UIView!
  @IBOutlet weak var coupon: UILabel!
  @IBOutlet weak var station: UILabel!
  
  @IBOutlet weak var nameHeight: NSLayoutConstraint!
  @IBOutlet weak var stationWidth: NSLayoutConstraint!
  @IBOutlet weak var stationX: NSLayoutConstraint!
  

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }

}
