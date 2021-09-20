//
//  Packet.swift
//  FireHawk
//
//  Created by Graeme Brennan on 2/9/21.
//

import Foundation

struct Packet {
//an array for each frame
    var rawData = [Frame?](repeating: Frame(), count: 38)
    var length: Int?
    var decodedData: String?
    var complete = false
    
public var scan = ""


}
