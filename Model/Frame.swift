//
//  Frame.swift
//  FireHawk
//
//  Created by Graeme Brennan on 2/9/21.
//


import UIKit
import AVFoundation

struct Frame {
    var rawBinaryString: String?
    var rawPacketNum: String?
    var rawDataByte: String?
    
    var HexVal: String?
    var packetNum: Int?
    var frameNumber :Int?
    
    var outputImage: UIImage?
    var str: String?
    
    var buffer: CMSampleBuffer?
}
