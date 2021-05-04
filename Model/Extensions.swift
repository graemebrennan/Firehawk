//
//  Extensions.swift
//  FireHawk
//
//  Created by Graeme Brennan on 5/3/21.
//

import Foundation

extension Date {
    func as_ddmmyyyy() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yyyy"
        return dateFormatter.string(from: self)
    }
    
    func as_ddmmyyyy_hhmmss() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yyyy hh:mm:ss"
        return dateFormatter.string(from: self)
    }
    
}
