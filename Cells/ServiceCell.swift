//
//  HouseCell.swift
//  FireHawk
//
//  Created by Tam Nguyen on 11/2/20.
//

import UIKit

class ServiceCell: UITableViewCell {

  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblAddress: UILabel!
  @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var faultIndicator: UIView!
    
    
  private var shadowLayer: CAShapeLayer = CAShapeLayer()
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      lblName.textColor = UIColor(rgb: 0x3584FA)
      lblAddress.textColor = UIColor(rgb: 0x8D8D8D)
      lblDate.textColor = UIColor(rgb: 0x8D8D8D)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
override func layoutSubviews() {
  super.layoutSubviews()

  
}
    
    @IBAction func nextPushed(_ sender: UIButton) {
        
        
    }
}
