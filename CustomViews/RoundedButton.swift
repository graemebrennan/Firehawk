//
//  RoundedButton.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
  
  @IBInspectable var buttonBackgroudColor: UIColor = UIColor(hex: "#95B2DCFF")! {
    didSet {
      setNeedsLayout()
    }
  }
  
  @IBInspectable var buttonTitleColor: UIColor = .white {
    didSet {
      setNeedsLayout()
    }
  }
  
  @IBInspectable var buttonTitleSize: CGFloat = 15.0 {
    didSet {
      setNeedsLayout()
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 16.0 {
    didSet {
      setNeedsLayout()
    }
  }
  
  @IBInspectable var shadowColor: UIColor = UIColor.darkGray {
    didSet {
      setNeedsLayout()
    }
  }
  
  private var shadowLayer: CAShapeLayer = CAShapeLayer() {
    didSet {
      setNeedsLayout()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = cornerRadius
    shadowLayer.path = UIBezierPath(roundedRect: bounds,
                                    cornerRadius: cornerRadius).cgPath
    shadowLayer.fillColor = backgroundColor?.cgColor
    shadowLayer.shadowColor = shadowColor.cgColor
    shadowLayer.shadowPath = shadowLayer.path
    shadowLayer.shadowOffset = CGSize(width: 0.0,
                                      height: 1.8)
    shadowLayer.shadowOpacity = 0.3
    shadowLayer.shadowRadius = 3.0
    layer.insertSublayer(shadowLayer, at: 0)
    
    backgroundColor = buttonBackgroudColor
    setTitleColor(buttonTitleColor, for: .normal)
    setTitleColor(buttonTitleColor, for: .highlighted)
    titleLabel?.font = UIFont.systemFont(ofSize: buttonTitleSize)
  }
  
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
  
}
