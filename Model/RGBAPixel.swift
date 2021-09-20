//
//  RGBAPixel.swift
//  FireHawk
//
//  Created by Graeme Brennan on 2/9/21.
//

import Foundation

struct RGBAPixel{
    init( rawVal : UInt32 ){
        raw = rawVal
    }
    var raw: UInt32
    var red:UInt8 {
        get { return UInt8(raw & 0xFF)}
        set { raw = UInt32(newValue) | (raw & 0xFFFFFF00)}
    }
    
    var green:UInt8 {
        get { return UInt8( (raw & 0xFF00) >> 8)}
        set { raw = (UInt32(newValue) << 8 ) | (raw & 0xFFFF00FF)}
    }
    
    var blue:UInt8 {
        get { return UInt8( (raw & 0xFF0000) >> 16)}
        set { raw = (UInt32(newValue) << 16 ) | (raw & 0xFF00FFFF)}
    }
    
    var alpha:UInt8 {
        get { return UInt8( (raw & 0xFF000000) >> 24)}
        set { raw = (UInt32(newValue) << 24 ) | (raw & 0x00FFFFFF)}
    }
}
