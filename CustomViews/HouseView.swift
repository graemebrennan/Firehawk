//
//  HouseView.swift
//  FireHawk
//
//  Created by Tam Nguyen on 11/2/20.
//

import UIKit

class HouseView: UIView {

  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblAddress: UILabel!
  @IBOutlet weak var lblDate: UILabel!
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
    Bundle.main.loadNibNamed("HouseView", owner: self, options: nil)
    contentView.fixInView(self)
    lblName.textColor = UIColor(rgb: 0x8D8D8D)
    lblAddress.textColor = UIColor(rgb: 0x8D8D8D)
    lblDate.textColor = UIColor(rgb: 0x8D8D8D)
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
  
  contentView.layer.borderColor = UIColor(rgb: 0x95B2DC).cgColor
  contentView.layer.borderWidth = 2.0
  
  imgView.layer.cornerRadius = cornerRadius
  imgView.clipsToBounds = true
  
}
  
}
