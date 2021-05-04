//
//  AlarmInfoRow.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/31/20.
//

import UIKit

class AlarmInfoRow: UIView {

  @IBOutlet var contentView: UIView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblDesc1: UILabel!
  @IBOutlet weak var lblDesc2: UILabel!
  @IBOutlet weak var lblDesc3: UILabel!
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  func commonInit() {
    Bundle.main.loadNibNamed("AlarmInfoRow", owner: self, options: nil)
    contentView.fixInView(self)
    lblTitle.textColor = UIColor(rgb: 0x3584FA)
    lblDesc1.textColor = UIColor(rgb: 0x8D8D8D)
    lblDesc2.textColor = UIColor(rgb: 0xB8A2A2)
    lblDesc3.textColor = UIColor(rgb: 0xB8A2A2)
    // Clear data
    lblTitle.text = nil
    lblDesc1.text = nil
    lblDesc2.text = nil
    lblDesc3.text = nil
  }
  

}
