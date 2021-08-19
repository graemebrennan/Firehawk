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
//    let cornerRadius: CGFloat = 16.0
//    shadowView.layer.cornerRadius = cornerRadius
//    bgView.layer.cornerRadius = cornerRadius
//    shadowLayer.path = UIBezierPath(roundedRect: shadowView.bounds,
//                                    cornerRadius: cornerRadius).cgPath
//    shadowLayer.fillColor = backgroundColor?.cgColor
//    shadowLayer.shadowColor = UIColor.darkGray.cgColor
//    shadowLayer.shadowPath = shadowLayer.path
//    shadowLayer.shadowOffset = CGSize(width: 0.0,
//                                      height: 2.8)
//    shadowLayer.shadowOpacity = 0.3
//    shadowLayer.shadowRadius = 3.0
//    shadowView.layer.insertSublayer(shadowLayer, at: 0)
//
//
//    imgView.layer.cornerRadius = cornerRadius
//    imgView.clipsToBounds = true
    
  }
}
