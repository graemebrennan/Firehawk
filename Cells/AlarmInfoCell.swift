//
//  AlarmInfoCell.swift
//  FireHawk
//
//  Created by Graeme Brennan on 10/8/21.
//

import UIKit

class AlarmInfoCell: UITableViewCell {

    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var FaultIndicator: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        title.textColor = UIColor(rgb: 0x3584FA)
        count.textColor = UIColor(rgb: 0x8D8D8D)
        date.textColor = UIColor(rgb: 0x8D8D8D)
        FaultIndicator.backgroundColor = .lightGray
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
