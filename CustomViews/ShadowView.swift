//
//  ShadowView.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/31/20.
//

import UIKit

@IBDesignable class ShadowView: UIView {

  @IBInspectable var backgroudColor: UIColor = .white {
    didSet {
      setNeedsLayout()
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 16.0 {
    didSet {
      setNeedsLayout()
    }
  }
  
  private var shadowLayer: CAShapeLayer = CAShapeLayer()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = cornerRadius
    shadowLayer.path = UIBezierPath(roundedRect: bounds,
                                    cornerRadius: cornerRadius).cgPath
    shadowLayer.fillColor = backgroundColor?.cgColor
    shadowLayer.shadowColor = UIColor.darkGray.cgColor
    shadowLayer.shadowPath = shadowLayer.path
    shadowLayer.shadowOffset = CGSize(width: 0.0,
                                      height: 1.8)
    shadowLayer.shadowOpacity = 0.3
    shadowLayer.shadowRadius = 3.0
    layer.insertSublayer(shadowLayer, at: 0)
    
    backgroundColor = backgroudColor
  }

}
