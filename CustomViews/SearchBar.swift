//
//  SearchBar.swift
//  FireHawk
//
//  Created by Tam Nguyen on 11/2/20.
//

import UIKit

class SearchBar: UIView {

  @IBOutlet var contentView: UIView!
  @IBOutlet var textfield: UITextField!
  
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
    Bundle.main.loadNibNamed("SearchBar", owner: self, options: nil)
    contentView.fixInView(self)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let cornerRadius: CGFloat = bounds.height * 0.5
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
  }
  
  @IBAction func onPressSearch(_ sender: Any) {
    
  }
}
