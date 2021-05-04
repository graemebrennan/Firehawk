//
//  FaultRow.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/31/20.
//

import UIKit

class BoolInputRow: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var scPosition: UISwitch!

    
    
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  func commonInit() {
    Bundle.main.loadNibNamed("FaultRow", owner: self, options: nil)
    contentView.fixInView(self)
    lblTitle.textColor = UIColor(rgb: 0x3584FA)
    // Clear data
    lblTitle.text = nil
  }
  

  
}
