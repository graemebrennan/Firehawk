//
//  ScannedCard.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/31/20.
//

import UIKit

class ScannedCard: UIView {

  @IBOutlet var contentView: UIView!
  @IBOutlet weak var lblTitle: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  
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
    Bundle.main.loadNibNamed("ScannedCard", owner: self, options: nil)
    contentView.fixInView(self)
    lblTitle.textColor = UIColor(rgb: 0x95B2DC)
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
                                      height: 1.8)
    shadowLayer.shadowOpacity = 0.3
    shadowLayer.shadowRadius = 3.0
    contentView.layer.insertSublayer(shadowLayer, at: 0)
    contentView.backgroundColor = .white
    
    contentView.layer.borderColor = UIColor(rgb: 0xC5C7FF).cgColor
    contentView.layer.borderWidth = 3.0
    
  }

  @IBAction func onPressAutofill(_ sender: Any) {
  }
  
}
