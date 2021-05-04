//
//  SelectField.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/31/20.
//

import UIKit

class SelectField: UIView {
  
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
  
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var bgView: UIView!
  @IBOutlet private weak var lblPlaceholder: UILabel!
  
  var placeholder: String = "Please select one option" {
    didSet {
      updateLabel()
    }
  }
  
  var selectedValue: String? {
    didSet {
      updateLabel()
    }
  }
  
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
    Bundle.main.loadNibNamed("SelectField", owner: self, options: nil)
    contentView.fixInView(self)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let cornerRadius: CGFloat = 12.0
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
    bgView.layer.cornerRadius = 8.0
    
  }
  
  func updateLabel() {
    if selectedValue == nil {
      lblPlaceholder.text = placeholder
      lblPlaceholder.textColor = UIColor(rgb: 0xCDCCCC)
    }else{
      lblPlaceholder.text = selectedValue
      lblPlaceholder.textColor = UIColor(rgb: 0x838282)
    }
  }
  
  @IBAction func onPress(_ sender: UIButton) {
  }
  
}


