//
//  DeviceCell.swift
//  FireHawk
//
//  Created by Tam Nguyen on 11/2/20.
//

import UIKit

class DeviceCell: UITableViewCell {
  
  
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblDate: UILabel!
  @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblSerialNumber: UILabel!
    @IBOutlet weak var FaultIndicatorView: UIView!
    @IBOutlet weak var lblNote: UILabel!
    
  private var shadowLayer: CAShapeLayer = CAShapeLayer()
  
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        lblName.textColor = UIColor(rgb: 0x3584FA)
        lblDate.textColor = UIColor(rgb: 0x8D8D8D)
        lblSerialNumber.textColor = UIColor(rgb: 0x8D8D8D)
        lblNote.textColor = UIColor(rgb: 0x8D8D8D)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  override func layoutSubviews() {
    super.layoutSubviews()

    
  }
}
