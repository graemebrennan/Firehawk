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


struct DeviceReport {
    
    // Device Information
    var deviceType: String? // Scanned i.e captured from serial number
    var deviceName: String? // user input
    var deviceRoom: String? // use input
    var deviceHealthStatus: String? // scanned
    var deviceSwicthOnDate: Date? // scanned or user input
    var runtimeClock: Int? // scanned
    var switchOnDate: Date? //

    var plateRemovals: Int? // scanned
    var deviceTestCount: Int? // scanned
    var deviceLastTestDate: Date? // scanned
    var maufactureDate: Date? //
    var snManufactureDate: Date? //
    var snManufactureExpiaryDate: Date? //
    var deviceSerialNumber: String? // scanned
    
    var highCOAlarmCount: Int? // scanned
    var highCOAlarmLastDate: Date? // scanned
    var mediumCOAlarmCount: Int? // scanned
    var mediumCOAlarmLastDate: Date? // scanned
    var lowCOAlarmCount: Int? // scanned
    var lowCOAlarmLastDate: Date? // scanned
    var preCOAlarmCount: Int? // scanned
    var preCOAlarmLastDate: Date? // scanned
    
    var backgroundCOLevel: Int? // scanned
    
    var faultFlag: UInt8? // scanned
    var batteryFault: Bool
    var deviceFault: Bool
    var eol_Fault: Bool
    var remoteFault: Bool
    var batteryFaultDate: Date? // scanned
    var deviceFaultDate: Date? // scanned
    var eol_FaultDate: Date? // scanned
    var remoteFaultDate: Date? // scanned
    
    var batteryChargePercentage: Int? // scanned
    var batteryVoltage: Float?
    var batteryLifeRemaining_YearsLeft: Float? // can work this out using the callander later, so we get years n months

    var batteryLifeRemaining_ReplacentDate: Date?

    var deviceReplacentDate: Date?
    
    var deviceLifeRemaining_HoursLeft: Int?
    var deviceLifeRemaining_DaysLeft: Int?
    var deviceLifeRemaining_MonthsLeft: Int?
    
    init(scan: String) { // initialise parameters from scan
        
        // current calender for scan time reference
        let calendar = Calendar.current
        
        self.batteryFault = false
        self.deviceFault = false
        self.eol_Fault = false
        self.remoteFault = false
        var deviceLifetime = 0
        
        //MARK:- SerialNumber
        let serialNumberStartIndex = scan.index(scan.startIndex, offsetBy: 0)
        let serialNumberEndIndex = scan.index(scan.startIndex, offsetBy: 5)
        let serialNumberString = String(scan[serialNumberStartIndex...serialNumberEndIndex])
        self.deviceSerialNumber = serialNumberString
        print("serialNumberString: \(serialNumberString)")
        
        let SNByte1StartIndex = scan.index(scan.startIndex, offsetBy: 0)
        let SNByte1EndIndex = scan.index(scan.startIndex, offsetBy: 1)
        
        let SNByte1String = String(scan[SNByte1StartIndex...SNByte1EndIndex])
        let SNByte1Int = UInt8(SNByte1String)
        
        let deviceTypeInt = (SNByte1Int! & 0xE0) >> 5
        print("deviceTypeInt: \(deviceTypeInt)")
        let productionYearInt = SNByte1Int! & 0x1F
        print("productionYearInt: \(productionYearInt)")
        
        
        switch deviceTypeInt {
        case 0:
            self.deviceType = "X10"
            print("deviceType: X10 Smoke Alarm)")
            deviceLifetime = 10
            
        case 1:
            self.deviceType = "CO"
            print("deviceType: CO10Y Alarm")
            deviceLifetime = 10
            
        case 2:
            self.deviceType = "H10"
            print("deviceType: H10 Heat Alarm")
            deviceLifetime = 10
            
        case 3:
            self.deviceType = "FH700HIA"
            print("deviceType: FH700HIA")
            deviceLifetime = 10
            
        case 4:
            self.deviceType = "RF"
            print("deviceType: Radio Patress")
            deviceLifetime = 10
            
        case 5:
            self.deviceType = "FH500"
            print("deviceType: FH500")
            deviceLifetime = 10
            
        default:
            self.deviceType = "Unknown Device"
            print("deviceType: Unknown Device")
            deviceLifetime = 10
        }
        //MARK:- fix this, can pull year from within sn no need to pull from string. alkso cant do this directly
        let snManufactureYearStartIndex = scan.index(scan.startIndex, offsetBy: 2)
        let snManufactureYearEndIndex = scan.index(scan.startIndex, offsetBy: 5)
        let snManufactureYearString = String(scan[snManufactureYearStartIndex...snManufactureYearEndIndex])
        let snManufactureYearInt = Int(snManufactureYearString)
        
        var snManufactureDateComponent = DateComponents()
        snManufactureDateComponent.year = snManufactureYearInt! * -1
        let snManufactureDate = calendar.date(byAdding: snManufactureDateComponent, to: Date())
        self.snManufactureDate = snManufactureDate
        print("snManufactureDat: \(snManufactureDate!)")
        
        // get current year
        let currentYear = calendar.component(.year, from: Date())
        // calculate the difference in years between serial date and current date
        let snManufactureYearsLeft = deviceLifetime - (currentYear - snManufactureYearInt!)
        // predict expiary date by claculating (life time - years since manufacture date) = years left from now
        var snManufactureYearsLeftComponent = DateComponents()
        snManufactureYearsLeftComponent.year = snManufactureYearsLeft
        let snManufactureExpiaryDate = calendar.date(byAdding: snManufactureYearsLeftComponent, to: Date())
        self.snManufactureExpiaryDate = snManufactureExpiaryDate
        print("snManufactureExpiaryDate: \(snManufactureExpiaryDate!)")
        
        //MARK:- RunTimeClock
        let runtimeClockStartIndex = scan.index(scan.startIndex, offsetBy: 6)
        let runtimeClockEndIndex = scan.index(scan.startIndex, offsetBy: 9)
        let runtimeClockString = String(scan[runtimeClockStartIndex...runtimeClockEndIndex])
        let runtimeClockInt = Int(runtimeClockString, radix: 16)
        self.runtimeClock = runtimeClockInt
        print("runtimeClock: \(runtimeClockInt!)")

        var runTimeComponent = DateComponents()
        runTimeComponent.hour = runtimeClockInt! * -1
        self.deviceSwicthOnDate = calendar.date(byAdding: runTimeComponent, to: Date())
        print("deviceSwicthOnDate: \(self.deviceSwicthOnDate!)")
        
        //MARK:- PlateRemovals
        let plateRemovalsStartIndex = scan.index(scan.startIndex, offsetBy: 10)
        let plateRemovalsEndIndex = scan.index(scan.startIndex, offsetBy: 11)
        let plateRemovalsString = String(scan[plateRemovalsStartIndex...plateRemovalsEndIndex])
        let plateRemovalsInt = Int(plateRemovalsString, radix: 16)
        self.plateRemovals = plateRemovalsInt
        print("plateRemovalsInt: \(plateRemovalsInt!)")
        
        //MARK:- DeviceTest
        let deviceTestCountStartIndex = scan.index(scan.startIndex, offsetBy: 12)
        let deviceTestCountEndIndex = scan.index(scan.startIndex, offsetBy: 15)
        let deviceTestCountString = String(scan[deviceTestCountStartIndex...deviceTestCountEndIndex])
        let deviceTestCountInt = Int(deviceTestCountString, radix: 16)
        self.deviceTestCount = deviceTestCountInt
        print("deviceTestCountInt: \(deviceTestCountInt!)")
        
        let deviceLastTestDateStartIndex = scan.index(scan.startIndex, offsetBy: 16)
        let deviceLastTestDateEndIndex = scan.index(scan.startIndex, offsetBy: 19)
        let deviceLastTestDateString = String(scan[deviceLastTestDateStartIndex...deviceLastTestDateEndIndex])
        let deviceLastTestDateInt = Int(deviceLastTestDateString, radix: 16)
        
        var lastTestComponent = DateComponents()
        lastTestComponent.hour = Int(Double(deviceLastTestDateInt!) * -21.39)
        let deviceLastTestDate = calendar.date(byAdding: lastTestComponent, to: Date())
        self.deviceLastTestDate = deviceLastTestDate
        print("deviceLastTestDate: \(deviceLastTestDate!)")
        
        //MARK:- HighCOAlarm
        let highCOAlarmCountStartIndex = scan.index(scan.startIndex, offsetBy: 20)
        let highCOAlarmCountEndIndex = scan.index(scan.startIndex, offsetBy: 20)
        let highCOAlarmCountString = String(scan[highCOAlarmCountStartIndex...highCOAlarmCountEndIndex])
        let highCOAlarmCountInt = Int(highCOAlarmCountString, radix: 16)
        self.highCOAlarmCount = highCOAlarmCountInt
        print("highCOAlarmCountInt: \(highCOAlarmCountInt!)")
        
        let highCOAlarmLastDateStartIndex = scan.index(scan.startIndex, offsetBy: 21)
        let highCOAlarmLastDateEndIndex = scan.index(scan.startIndex, offsetBy: 23)
        let highCOAlarmLastDateString = String(scan[highCOAlarmLastDateStartIndex...highCOAlarmLastDateEndIndex])
        let highCOAlarmLastDateInt = Int(highCOAlarmLastDateString, radix: 16)
        
        var highCOAlarmLastDateComponent = DateComponents()
        highCOAlarmLastDateComponent.hour = Int(Double(highCOAlarmLastDateInt!) * -21.39)
        let highCOAlarmLastDate = calendar.date(byAdding: highCOAlarmLastDateComponent, to: Date())
        self.highCOAlarmLastDate = highCOAlarmLastDate
        print("highCOAlarmLastDate: \(highCOAlarmLastDate!)")
        
        //MARK:- MediumCOAlarm
        let mediumCOAlarmCountStartIndex = scan.index(scan.startIndex, offsetBy: 24)
        let mediumCOAlarmCountEndIndex = scan.index(scan.startIndex, offsetBy: 24)
        let mediumCOAlarmCountString = String(scan[mediumCOAlarmCountStartIndex...mediumCOAlarmCountEndIndex])
        let mediumCOAlarmCount = Int(mediumCOAlarmCountString, radix: 16)
        self.mediumCOAlarmCount = Int(mediumCOAlarmCountString, radix: 16)
        print("mediumCOAlarmCount: \(mediumCOAlarmCount!)")
        
        let mediumCOAlarmLastDateStartIndex = scan.index(scan.startIndex, offsetBy: 25)
        let mediumCOAlarmLastDateEndIndex = scan.index(scan.startIndex, offsetBy: 27)
        let mediumCOAlarmLastDateString = String(scan[mediumCOAlarmLastDateStartIndex...mediumCOAlarmLastDateEndIndex])
        let mediumCOAlarmLastDateInt = Int(mediumCOAlarmLastDateString, radix: 16)
        
        var mediumCOAlarmLastDateComponent = DateComponents()
        mediumCOAlarmLastDateComponent.hour = Int(Double(mediumCOAlarmLastDateInt!) * -21.39)
        let mediumCOAlarmLastDate = calendar.date(byAdding: mediumCOAlarmLastDateComponent, to: Date())
        self.mediumCOAlarmLastDate = mediumCOAlarmLastDate
        print("mediumCOAlarmLastDate: \(mediumCOAlarmLastDate!)")
        
        //MARK:- LowCOAlarm
        let lowCOAlarmCountStartIndex = scan.index(scan.startIndex, offsetBy: 28)
        let lowCOAlarmCountEndIndex = scan.index(scan.startIndex, offsetBy: 28)
        let lowCOAlarmCountString = String(scan[lowCOAlarmCountStartIndex...lowCOAlarmCountEndIndex])
        let lowCOAlarmCount = Int(lowCOAlarmCountString, radix: 16)
        self.lowCOAlarmCount = lowCOAlarmCount
        print("lowCOAlarmCount: \(lowCOAlarmCount!)")
 
        let lowCOAlarmLastDateStartIndex = scan.index(scan.startIndex, offsetBy: 29)
        let lowCOAlarmLastDateEndIndex = scan.index(scan.startIndex, offsetBy: 31)
        let lowCOAlarmLastDateString = String(scan[lowCOAlarmLastDateStartIndex...lowCOAlarmLastDateEndIndex])
        let lowCOAlarmLastDateInt = Int(lowCOAlarmLastDateString, radix: 16)
        
        var lowCOAlarmLastDateComponent = DateComponents()
        lowCOAlarmLastDateComponent.hour = Int(Double(lowCOAlarmLastDateInt!) * -21.39)
        let lowCOAlarmLastDate = calendar.date(byAdding: lowCOAlarmLastDateComponent, to: Date())
        self.lowCOAlarmLastDate = lowCOAlarmLastDate
        print("lowCOAlarmLastDate: \(lowCOAlarmLastDate!)")
        
        //MARK:- PreCOAlarm
        let preCOAlarmCountStartIndex = scan.index(scan.startIndex, offsetBy: 32)
        _ = scan.index(scan.startIndex, offsetBy: 32)
        let preCOAlarmCountString = String(scan[preCOAlarmCountStartIndex])
        self.preCOAlarmCount = Int(preCOAlarmCountString, radix: 16)

        let preCOAlarmLastDateStartIndex = scan.index(scan.startIndex, offsetBy: 33)
        let preCOAlarmmLastDateEndIndex = scan.index(scan.startIndex, offsetBy: 35)
        let preCOAlarmLastDateString = String(scan[preCOAlarmLastDateStartIndex...preCOAlarmmLastDateEndIndex])
        let preCOAlarmLastDateInt = Int(preCOAlarmLastDateString, radix: 16)
        
        var preCOAlarmLastDateComponent = DateComponents()
        preCOAlarmLastDateComponent.hour = Int(Double(preCOAlarmLastDateInt!) * -21.39)
        self.preCOAlarmLastDate = calendar.date(byAdding: preCOAlarmLastDateComponent, to: Date())
        
        //MARK:- BackgroundCOLevel
        let BackgroundCOLevelStartIndex = scan.index(scan.startIndex, offsetBy: 36)
        let BackgroundCOLevelEndIndex = scan.index(scan.startIndex, offsetBy: 39)
        let BackgroundCOLevelString = String(scan[BackgroundCOLevelStartIndex...BackgroundCOLevelEndIndex])
        self.backgroundCOLevel = Int(BackgroundCOLevelString, radix: 16)
        
        //MARK:- Faults
        let faultFlagStartIndex = scan.index(scan.startIndex, offsetBy: 40)
        let faultFlagEndIndex = scan.index(scan.startIndex, offsetBy: 41)
        let faultFlagString = String(scan[faultFlagStartIndex...faultFlagEndIndex])
        let faultFlagUInt8 = UInt8(faultFlagString, radix: 16)
        self.faultFlag = faultFlagUInt8
    
        //MARK:- batteryFaultDate
        let batteryFaultDateStartIndex = scan.index(scan.startIndex, offsetBy: 42)
        let batteryFaultDateEndIndex = scan.index(scan.startIndex, offsetBy: 45)
        let batteryFaultDateString = String(scan[batteryFaultDateStartIndex...batteryFaultDateEndIndex])
        let batteryFaultDateInt = Int(batteryFaultDateString, radix: 16)
        
        var batteryFaultDateComponent = DateComponents()
        batteryFaultDateComponent.hour = Int(Double(batteryFaultDateInt!) * -21.39)
        self.batteryFaultDate = calendar.date(byAdding: batteryFaultDateComponent, to: Date())
        
        //MARK:- deviceFaultDate
        let deviceFaultDateStartIndex = scan.index(scan.startIndex, offsetBy: 46)
        let deviceFaultDateEndIndex = scan.index(scan.startIndex, offsetBy: 49)
        let deviceFaultDateString = String(scan[deviceFaultDateStartIndex...deviceFaultDateEndIndex])
        let deviceFaultDateInt = Int(deviceFaultDateString, radix: 16)
        
        var deviceFaultDateComponent = DateComponents()
        deviceFaultDateComponent.hour = Int(Double(deviceFaultDateInt!) * -21.39)
        self.deviceFaultDate = calendar.date(byAdding: deviceFaultDateComponent, to: Date())
        
        //MARK:- eol_FaultDate
        let eol_FaultDateStartIndex = scan.index(scan.startIndex, offsetBy: 50)
        let eol_FaultDateEndIndex = scan.index(scan.startIndex, offsetBy: 53)
        let eol_FaultDateString = String(scan[eol_FaultDateStartIndex...eol_FaultDateEndIndex])
        let eol_FaultDateInt = Int(eol_FaultDateString, radix: 16)
        
        var eol_FaultDateComponent = DateComponents()
        eol_FaultDateComponent.hour = Int(Double(eol_FaultDateInt!) * -21.39)
        self.eol_FaultDate = calendar.date(byAdding: eol_FaultDateComponent, to: Date())
        
        //MARK:- remoteFaultDate
        let remoteFaultDateStartIndex = scan.index(scan.startIndex, offsetBy: 54)
        let remoteFaultDateEndIndex = scan.index(scan.startIndex, offsetBy: 57)
        let remoteFaultDateString = String(scan[remoteFaultDateStartIndex...remoteFaultDateEndIndex])
        let remoteFaultDateInt = Int(remoteFaultDateString, radix: 16)
        
        var remoteFaultDateComponent = DateComponents()
        remoteFaultDateComponent.hour = Int(Double(remoteFaultDateInt!) * -21.39)
        self.remoteFaultDate = calendar.date(byAdding: remoteFaultDateComponent, to: Date())
        
        //MARK:- batteryVoltage
        let batteryVoltageStartIndex = scan.index(scan.startIndex, offsetBy: 59)
        let batteryVoltageEndIndex = scan.index(scan.startIndex, offsetBy: 60)
        let batteryVoltageString = String(scan[batteryVoltageStartIndex...batteryVoltageEndIndex])
        let batteryChargeInt = Int(batteryVoltageString, radix: 16)
        self.batteryChargePercentage = (255/batteryChargeInt!) * 100
        
        let batteryVoltageFloat = 2.00 + (Float(batteryChargeInt!) * 0.005)
        self.batteryVoltage = batteryVoltageFloat
        
        let batteryLifeRemaining_YearsLeft = 10/255 * Float(batteryChargeInt!)
        let batteryLifeRemaining_HoursLeft = batteryLifeRemaining_YearsLeft * (365 * 24)
        self.batteryLifeRemaining_YearsLeft = batteryLifeRemaining_YearsLeft
        
        var batteryLifeRemaining_ReplacentDateComponent = DateComponents()
        batteryLifeRemaining_ReplacentDateComponent.hour = Int(batteryLifeRemaining_HoursLeft)
        let batteryLifeRemaining_ReplacentDate = calendar.date(byAdding: batteryLifeRemaining_ReplacentDateComponent, to: Date())
        
        let dataFormater = DateFormatter()
        dataFormater.dateFormat = "dd.mm.yyyy"
        
        self.batteryLifeRemaining_ReplacentDate = batteryLifeRemaining_ReplacentDate
        
        if (plateRemovalsInt == 0) {
            var maufactureDateComponent = DateComponents()
            maufactureDateComponent.hour = runtimeClockInt! * -1
            self.maufactureDate = calendar.date(byAdding: maufactureDateComponent, to: Date())
        } else {
            self.maufactureDate = snManufactureDate
        }

        
        // use soonest expirey prediction for report
        if batteryLifeRemaining_ReplacentDate! < snManufactureExpiaryDate! {
            self.deviceReplacentDate = batteryLifeRemaining_ReplacentDate!
            
            let components = calendar.dateComponents([.hour], from: Date(), to: batteryLifeRemaining_ReplacentDate!)
            self.deviceLifeRemaining_HoursLeft = components.hour!
        } else {
            self.deviceReplacentDate = snManufactureExpiaryDate!
            
            let components = calendar.dateComponents([.hour], from:  Date(), to: snManufactureExpiaryDate!)
            self.deviceLifeRemaining_HoursLeft = components.hour!
        }
        

        //MARK:- set faults
        if (faultFlagUInt8 != nil) {
            var activeFaults = faultFlagUInt8!
            if (activeFaults & 0x01 == 0x01) {
                self.batteryFault = true
            } else if (activeFaults & 0x02 == 0x02) {
                self.deviceFault = false
            } else if (activeFaults & 0x04 == 0x04) {
                self.eol_Fault = false
            } else if (activeFaults & 0x08 == 0x08) {
                self.remoteFault = false
            }
        } else {
            print("could not extract faults from scan")
        }
        
    }
    
    //Scanned Properties
    
    
    /*
     packet structure
     
     // raw data string pulled from device during scan
     rawData: String
     the raw data is a binary string pulled directly from the scanner is manchester decoded
     
     //MARK: - Calculated Variables
     deviceHealthStatus: String - Calculated
     this is the general health of the device, to begin with this can have a faulty state and a ok state then add to this latter.
     
     deviceSwitchOnDate: Date - Calculated
     there are a few options here, if the device has only been switched on once then calculate the hourse logged back from the current date, accturate to 4 hours, so im told
     another option here is to calculate the date based on the battery charge level if the switch on count is greater than one.
     
     // Alarm Information
     lifeRemaining_DaysLeft: Int - Calculated
     how much life is left in the device, there are two options here, calculate with battery discharge trend or by first switch on date.
     
     lifeRemaining_ReplacentDate: Date - Calculated
     this can be calculated from the devices switchedOn date + the liftime of the device or based on battry discharge, whichever comes first. this may cause a clash here as battery life may limit the device before the expiry date.
     
     maufactureDate: Date - Calculated
     this can be incorperated into the serial number or it will need to be User input.
     
     battery_Status: String - Calculated  //maybe best implement an enum ranking
     
     device_Status: String - Calculated
     
     eol_Status: String - Calculated
     
     remote_Status: String - Calculated
     
     
     //MARK: - USer Input
     
     deviceName: String - User
     the name of the device given by the user, this seems unnessisary!
     
     deviceRoom: String - User
     the room the device is installed in, this is given by the user.
     
     //user questions
     correctLocation: Bool - UserInput
     clearOfFurniture: Bool - UserInput
     audioTestOk: Bool - UserInput
     deviceInGoodCondition: Bool - UserInput
     deviceNeedToBeReplaced: Bool - UserInput
     
     aditionalComments: String
     
     
     */
    /*
     //MARK: - Scanned Data
     //Co Alarms - review segnificance in the new standards
     highCOAlarm_Count: Int - Scanned (4 bits: 16 values)
     highCOAlarm_LastDate: Date - Scanned (12 bit: 4096 values)
     
     mediumCOAlarm_Count: Int - Scanned (4 bits: 16 values)
     mediumCOAlarm_LastDate: Date - Scanned (12 bit: 4096 values)
     
     lowCOAlarm_Count: Int - Scanned (4 bits: 16 values)
     lowCOAlarm_LastDate: Date - Scanned (12 bit: 4096 values)
     
     preAlarm_Count: Int - Scanned (4 bits: 16 values)
     preAlarm_LastDate: Date - Scanned (12 bit: 4096 values)
     
     backgroundCOLevels: Float - Scanned (12 bit: 4096 values)
     
     deviceLastTestDate: Date - Scanned (12 bit: 4096 values)
     this is based on the structure of the RealTime Clock. it will need to have as many values.2 per year, 520 in 10 years. may be more appropriate to change this count to 9 as it will give 512 values -> close enough.
     
     deviceSerialNumber: String - Scanned (20 bits: 1048576)
     the serial number of the device. this must be unique for all devices in a house. As device memory is an issue we could possible cut its size down based on a device type. s/n clashes will become an issue if a company wide DB is used.
     
     removalsFromMountingPlate: Int - Scanned (4 bits: 16 values)
     a simple count of the times the device is switched on. this can be incremented on device bootup. this can suggest device tampering/ battery manipulation if replaceable. if 16 values the count should be concidered exessive. might be wirth while allowing this to be reset.
     
     deviceTestCount: Int - Scanned (10 bits: 1024 values)
     how many times the device has been tested. this will provide use case information to understand how the products are being used. the standard specifies a test every week, i.e 5
     
     runtimeClock: Int - Scanned (12 bits: 4096 Values)
     this is a runtime clock that counts the number of hours the device has been turned on, im told the resolution is 4 hours, i dont believe this tho. with a resolution of 12 bytes: 4096 values. hours per year = 365*24 = 8760 -> 8760/4 = 2190 -> 2190 * 10 = 21900. need 15 bytes. maybe 16 or reduce the accuracy to a 24 hour period. not sure! working with 4 hourly for now!
     
     deviceType: String - Scanned
     the type of device, this can be identified within the transmission packet or by the length of the packet itself, not sure yet
     
     //Faults
     battery_Fault: String - Scanned (1 bit: 4096 values)
     battery_FaultDate: Date - Scanned (12 bit: 4096 values)
     device_Fault: String - Scanned (1 bit: 4096 values)
     device_FaultDate: Date - Scanned (12 bit: 4096 values)
     eol_Fault: String - Scanned (1 bit: 4096 values)
     eol_FaultDate: Date - Scanned (12 bit: 4096 values)
     remote_Fault: String - Scanned (1 bit: 4096 values)
     remote_FaultDate: Date - Scanned (12 bit: 4096 values)
     
     
     
     */

    
}
