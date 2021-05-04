//
//  DeviceView.swift
//  FireHawk
//
//  Created by Tam Nguyen on 11/2/20.
//

import UIKit

class DeviceView: UIView {

  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblNote: UILabel!
  @IBOutlet weak var imgView: UIImageView!
  private var shadowLayer: CAShapeLayer = CAShapeLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  func commonInit() {
    Bundle.main.loadNibNamed("DeviceView", owner: self, options: nil)
    contentView.fixInView(self)
    lblTitle.textColor = UIColor(rgb: 0x8D8D8D)
    lblNote.textColor = UIColor(rgb: 0x8D8D8D)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let cornerRadius: CGFloat = 16.0
    contentView.layer.cornerRadius = cornerRadius
    shadowLayer.path = UIBezierPath(roundedRect: bounds,
                                    cornerRadius: cornerRadius).cgPath
    shadowLayer.fillColor = backgroundColor?.cgColor
    shadowLayer.shadowColor = UIColor.darkGray.cgColor
    shadowLayer.shadowPath = shadowLayer.path
    shadowLayer.shadowOffset = CGSize(width: 0.0,
                                      height: 2.8)
    shadowLayer.shadowOpacity = 0.3
    shadowLayer.shadowRadius = 3.0
    contentView.layer.insertSublayer(shadowLayer, at: 0)
    
    
    imgView.layer.cornerRadius = cornerRadius
    imgView.clipsToBounds = true
    
  }
}
