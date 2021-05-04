//
//  MultiLineInputField.swift
//  FireHawk
//
//  Created by Graeme Brennan on 15/4/21.
//

import UIKit

class MultiLineInputField: UIView {

    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tfInput: UILabel!
    
    
    private var shadowLayer: CAShapeLayer = CAShapeLayer()
    

//    var placeholder: String = "Enter comments text here..." {
//      didSet {
//        tfInput.placeholder = placeholder
//      }
//    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      commonInit()
    }
    
    func commonInit() {
      Bundle.main.loadNibNamed("InputField", owner: self, options: nil)
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
}
