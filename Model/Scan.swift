//
//  Scan.swift
//  FireHawk
//
//  Created by Graeme Brennan on 2/3/21.
//

import Foundation

struct FakePacket {
//an array for each frame
//var rawData: [Frame]?

var length: Int?
var decodedData: String?
    
public var scan = "34000101000200400010A020B030CA040D0501234020123023401340154FF"


}


struct fakeData {
    var DeviceTypeYear = 0x34
    var DeviceNumber = 0x0001
    var RuntimeClock = 0x0100           //256
    var PlateRemoval = 0x02             //2
    var DeviceTestCount = 0x0040        //64
    var LastTestDate = 0x0010           //16
    var HighLevelAlarm = 0xA020         //10 - 32
    var MediumLevelAlarm = 0xB030       //11 - 48
    var LowLevelAlarm = 0xC040          //12 - 64
    var PreAlarm = 0xD050               //13 - 80
    var BackgroundLevel = 0x1234        //4660
    var FaultFlag = 0x02                //0b00000010 2
    var BatteryFaultDate = 0x0123       //291
    var DeviceFaultDate = 0x0234        //564
    var EOLFaultDate = 0x0134           //308
    var RemoteFaultDate = 0x0154        //340
    var batteryVoltage = 0xFF           //
}

struct ServiceReport {
    var name: String?
    var date: Date?
    var deviceReports: [DeviceReport]? = []
}


