//
//  DeviceReport.swift
//  FireHawk
//
//  Created by Graeme Brennan on 26/7/21.
//
//MARK:- TODO
//  add manufacture month to the serial number and use it to calculate the replacement date. 

import Foundation

struct ScanAnalysis {
    
    // Device Information
    var deviceType: String? // Scanned i.e captured from serial number
    var deviceName: String? // user input
    var deviceRoom: String? // use input
    var deviceHealthStatus: String? // scanned
    var deviceSwicthOnDate: Date? // scanned or user input
    var runtimeClock: Int? // scanned
    var runtimeClockHours: Int? // scanned
    
    var switchOnDate: Date? //

    var plateRemovals: Int? // scanned
    var lastPlateRemovalDate: Date? // scanned
    var lastPlateRemovalComponent = DateComponents()
    var plateRemovalsFaultIndicator = "off"
    
    var deviceTestCount: Int? // scanned
    var deviceLastTestDate: Date? // scanned
    var lastTestComponent = DateComponents()
    var deviceTestFaultIndicator = "off"
    
    var maufactureDate: Date? //
    var snManufactureDate: Date? //
    var snManufactureExpiaryDate: Date? //
    var deviceSerialNumber: String? // scanned
    
    var highCOAlarmCount: Int? // scanned
    var highCOAlarmLastDate: Date? // scanned
    var highCOAlarmFaultIndicator = "off"
    var mediumCOAlarmCount: Int? // scanned
    var mediumCOAlarmLastDate: Date? // scanned
    var mediumCOAlarmFaultIndicator = "off"
    var lowCOAlarmCount: Int? // scanned
    var lowCOAlarmLastDate: Date? // scanned
    var lowCOAlarmFaultIndicator = "off"
    var preCOAlarmCount: Int? // scanned
    var preCOAlarmLastDate: Date? // scanned
    var preCOAlarmFaultIndicator = "off"
    
    var backgroundCOLevel: Int? // scanned
    
    var faultFlag: UInt8 = 0// scanned
    var batteryFault: Bool?
    var deviceFault: Bool?
    var eol_Fault: Bool?
    var remoteFault: Bool?
    var batteryFaultDate: Date? // scanned
    var deviceFaultDate: Date? // scanned
    var eol_FaultDate: Date? // scanned
    var remoteFaultDate: Date? // scanned
    
    var batteryChargePercentage: Float? // scanned
    var batteryVoltage: Float?
    var batteryLifeRemaining_YearsLeft: Float? // can work this out using the callander later, so we get years n months

    var batteryLifeRemaining_ReplacentDate: Date?

    var deviceReplacentDate: Date?
    
    var deviceLifeRemaining_HoursLeft: Int?
    var deviceLifeRemaining_DaysLeft: Int?
    var deviceLifeRemaining_MonthsLeft: Int?
    var deviceLifeRemaining_YearsLeft: Int?
    
    var deviceLifetimeYears: Int?
    
    var softwareVersion: String?
    
    var checkSum: String?
    
    var checkSumValue: UInt8?
    var checkSumUInt16: UInt16 = 0
    
    let HoursInAMonth = 730
    let HoursInAYear = 8760
    
    var lifeRemainingFaultIndicator = "off"
    var scanDate = Date()
    
    var deviceFaultIndicator = "off"
    
    var peakCO: Int?
    
    init(scan: String) { // initialise parameters from scan
        
        // current calender for scan time reference
        let calendar = Calendar.current
        
        self.batteryFault = true
        self.deviceFault = true
        self.eol_Fault = true
        self.remoteFault = true
        //var deviceLifetime = 0
        
        //MARK:- SerialNumber
        let serialNumberStartIndex = scan.index(scan.startIndex, offsetBy: 0)
        let serialNumberEndIndex = scan.index(scan.startIndex, offsetBy: 7)
        let serialNumberString = String(scan[serialNumberStartIndex...serialNumberEndIndex])
        self.deviceSerialNumber = serialNumberString
        print("serialNumberString: \(serialNumberString)")
        
        let SNByte1StartIndex = scan.index(scan.startIndex, offsetBy: 0)
        let SNByte1EndIndex = scan.index(scan.startIndex, offsetBy: 1)
        
        let SNByte1String = String(scan[SNByte1StartIndex...SNByte1EndIndex])
        let SNByte1Int = UInt8(SNByte1String, radix: 16)
        
        // get only first 3 bits >> to get byte value
        //let check = SNByte1Int! & 0xE0
        let deviceTypeInt = (SNByte1Int! & 0xE0) >> 5
        print("deviceTypeInt: \(deviceTypeInt)")
        let productionYearInt = SNByte1Int! & 0x1F
        print("productionYearInt: \(productionYearInt)")
        
        let SNByte2StartIndex = scan.index(scan.startIndex, offsetBy: 2)
        let SNByte2EndIndex = scan.index(scan.startIndex, offsetBy: 3)
        
        let SNByte2String = String(scan[SNByte2StartIndex...SNByte2EndIndex])
        let SNByte2Int = UInt8(SNByte2String, radix: 16)
        
        let productionMonth = (SNByte2Int! & 0xF0) >> 4

        
        switch deviceTypeInt {
        case 0:
            self.deviceType = "X10"
            print("deviceType: X10 Smoke Alarm)")
            self.deviceLifetimeYears = 10
            
        case 1:
            self.deviceType = "FH700HIA"
            print("deviceType: FH700HIA")
            self.deviceLifetimeYears = 10
            
        case 2:
            self.deviceType = "H10"
            print("deviceType: H10 Heat Alarm")
            self.deviceLifetimeYears = 10
            
        case 3:
            self.deviceType = "CO7B 10Y"
            print("deviceType: CO10Y Alarm")
            self.deviceLifetimeYears = 10
            
        case 4:
            self.deviceType = "RF"
            print("deviceType: Radio Patress")
            self.deviceLifetimeYears = 10
            
        case 5:
            self.deviceType = "FH500"
            print("deviceType: FH500")
            self.deviceLifetimeYears = 10
            
        default:
            self.deviceType = "Unknown Device"
            print("deviceType: Unknown Device")
            self.deviceLifetimeYears = 10
        }
        
        //MARK:- fix this, can pull year from within sn no need to pull from string. alkso cant do this directly
        //TODO:- need to get month information to add production month, i dont need the year here as i have it above in first byte.
        //let snManufactureYearStartIndex = scan.index(scan.startIndex, offsetBy: 2)
        //let snManufactureYearEndIndex = scan.index(scan.startIndex, offsetBy: 7)
        //let snManufactureYearString = String(scan[snManufactureYearStartIndex...snManufactureYearEndIndex])
        //let snManufactureYearInt = Int(snManufactureYearString)
        
       
        var snManufactureDateComponent = DateComponents()
        
        snManufactureDateComponent.year = Int("20" + String(productionYearInt))
        snManufactureDateComponent.month = Int(productionMonth)

        
//        let snManufactureDate = calendar.date(byAdding: snManufactureDateComponent, to: Date())
        let snManufactureDate =  calendar.date(from: snManufactureDateComponent)
        self.snManufactureDate = snManufactureDate
        print("snManufactureDat: \(snManufactureDate!)")
        
        // get current year
        let currentYear = calendar.component(.year, from: Date())
        // calculate the difference in years between serial date and current date
        let snManufactureYearsLeft = self.deviceLifetimeYears! - (currentYear - (2000 + Int(productionYearInt)) )
        // predict expiary date by claculating (life time - years since manufacture date) = years left from now
        var snManufactureYearsLeftComponent = DateComponents()
        snManufactureYearsLeftComponent.year = snManufactureYearsLeft
        let snManufactureExpiaryDate = calendar.date(byAdding: snManufactureYearsLeftComponent, to: snManufactureDate!)
        self.snManufactureExpiaryDate = snManufactureExpiaryDate
        print("snManufactureExpiaryDate: \(snManufactureExpiaryDate!)")
        
        //MARK:- RunTimeClock
        let runtimeClockStartIndex = scan.index(scan.startIndex, offsetBy: 8)
        let runtimeClockEndIndex = scan.index(scan.startIndex, offsetBy: 11)
        let runtimeClockString = String(scan[runtimeClockStartIndex...runtimeClockEndIndex])
        let runtimeClockInt = Int(runtimeClockString, radix: 16)
        self.runtimeClock = runtimeClockInt
        self.runtimeClockHours = runtimeClockInt! * 2
        print("runtimeClock: \(runtimeClockInt!)")

        var runTimeComponent = DateComponents()
        runTimeComponent.hour = runtimeClockInt! * -2
        self.deviceSwicthOnDate = calendar.date(byAdding: runTimeComponent, to: Date())
        print("deviceSwicthOnDate: \(self.deviceSwicthOnDate!)")
        
        
        //MARK:- Life Remaining Indicator
        if self.runtimeClockHours! >= 83220 {
            // red lifetime warning, in last 6 months
            self.lifeRemainingFaultIndicator = "red"
        } else if (self.runtimeClockHours! >= 78840) {
            // amber warning in last year
            self.lifeRemainingFaultIndicator = "amber"
        } else {
            self.lifeRemainingFaultIndicator = "green"
        }
        
        if self.runtimeClockHours! > 87600 {
            self.deviceLifeRemaining_HoursLeft = 0
            self.deviceLifeRemaining_DaysLeft = 0
            self.deviceLifeRemaining_MonthsLeft = 0
            self.deviceLifeRemaining_YearsLeft = 0
        } else {
            self.deviceLifeRemaining_HoursLeft = (self.deviceLifetimeYears! * 8760) - self.runtimeClockHours!
            self.deviceLifeRemaining_DaysLeft = self.deviceLifeRemaining_HoursLeft! / 24
            self.deviceLifeRemaining_MonthsLeft = self.deviceLifeRemaining_DaysLeft! / 30
            self.deviceLifeRemaining_YearsLeft = self.deviceLifeRemaining_MonthsLeft! / 12
        }

        
        //MARK:- PlateRemovals
        let plateRemovalStartIndex = scan.index(scan.startIndex, offsetBy: 12)
        let plateRemovalEndIndex = scan.index(scan.startIndex, offsetBy: 13)
        let plateRemovalString = String(scan[plateRemovalStartIndex...plateRemovalEndIndex])
        let plateRemovalInt = Int(plateRemovalString, radix: 16)
        self.plateRemovals = plateRemovalInt
        print("plateRemovalsInt: \(plateRemovalInt!)")
       
        if  plateRemovalInt == 0 {
            self.lastPlateRemovalDate = nil
            self.plateRemovalsFaultIndicator = "green"
        } else {
            let lastPlateRemovalDateStartIndex = scan.index(scan.startIndex, offsetBy: 14)
            let lastPlateRemovalDateEndIndex = scan.index(scan.startIndex, offsetBy: 17)
            let lastPlateRemovalDateString = String(scan[lastPlateRemovalDateStartIndex...lastPlateRemovalDateEndIndex])
            let lastPlateRemovalDateInt = Int(lastPlateRemovalDateString, radix: 16)
            
            // create date componant
           // self.lastPlateRemovalComponent = DateComponents()
            // set hours value, int is clock ticks every two hours so multiply by 2 to get hours, '-' to count back from current time
            self.lastPlateRemovalComponent.hour = (runtimeClockInt! - lastPlateRemovalDateInt!) * -2
            // set date of event by adding negative value to current date
            self.lastPlateRemovalDate = calendar.date(byAdding: lastPlateRemovalComponent, to: Date())
            print("lastPlateRemovalDate: \(lastPlateRemovalDate!)")
            
                    if (self.lastPlateRemovalComponent.hour!) < 4380 {
                        // device was removed in past year or has never been removed
                        self.plateRemovalsFaultIndicator = "red"
            
                    } else if (self.lastPlateRemovalComponent.hour!) <= 8760 {
                        // device was removed in past year
                        self.plateRemovalsFaultIndicator = "amber"
                    } else {
                        self.plateRemovalsFaultIndicator = "green"
                    }
        }
        

//

        //MARK:- DeviceTest
        let deviceTestCountStartIndex = scan.index(scan.startIndex, offsetBy: 18)
        let deviceTestCountEndIndex = scan.index(scan.startIndex, offsetBy: 21)
        let deviceTestCountString = String(scan[deviceTestCountStartIndex...deviceTestCountEndIndex])
        let deviceTestCountInt = Int(deviceTestCountString, radix: 16)
        self.deviceTestCount = deviceTestCountInt
        print("deviceTestCountInt: \(deviceTestCountInt!)")

        if  deviceTestCountInt == 0 {
            self.deviceLastTestDate = nil
            self.deviceTestFaultIndicator = "green"
        } else {
            let deviceLastTestDateStartIndex = scan.index(scan.startIndex, offsetBy: 22)
            let deviceLastTestDateEndIndex = scan.index(scan.startIndex, offsetBy: 25)
            let deviceLastTestDateString = String(scan[deviceLastTestDateStartIndex...deviceLastTestDateEndIndex])
            let deviceLastTestDateInt = Int(deviceLastTestDateString, radix: 16)
            
            
            self.lastTestComponent.hour = (runtimeClockInt! - deviceLastTestDateInt!) * -2
            let deviceLastTestDate = calendar.date(byAdding: lastTestComponent, to: Date())
            self.deviceLastTestDate = deviceLastTestDate
            print("deviceLastTestDate: \(deviceLastTestDate!)")
            
            if (self.lastTestComponent.hour!) > 730 {
                // the device has not been tested in a month
                self.deviceTestFaultIndicator = "red"
            } else if (self.lastTestComponent.hour!) > 336 {
                // the device has not been in two weeks
                self.deviceTestFaultIndicator = "amber"
            } else {
                self.deviceTestFaultIndicator = "green"
            }
        }
        


        
        //MARK:- HighCOAlarm
        let highCOAlarmCountStartIndex = scan.index(scan.startIndex, offsetBy: 26)
        let highCOAlarmCountEndIndex = scan.index(scan.startIndex, offsetBy: 27)
        let highCOAlarmCountString = String(scan[highCOAlarmCountStartIndex...highCOAlarmCountEndIndex])
        let highCOAlarmCountInt = Int(highCOAlarmCountString, radix: 16)
        self.highCOAlarmCount = highCOAlarmCountInt
        print("highCOAlarmCountInt: \(highCOAlarmCountInt!)")
        
        if  highCOAlarmCountInt == 0 {
            self.highCOAlarmLastDate = nil
            self.highCOAlarmFaultIndicator = "green"
        } else {
            let highCOAlarmLastDateStartIndex = scan.index(scan.startIndex, offsetBy: 28)
            let highCOAlarmLastDateEndIndex = scan.index(scan.startIndex, offsetBy: 31)
            let highCOAlarmLastDateString = String(scan[highCOAlarmLastDateStartIndex...highCOAlarmLastDateEndIndex])
            
            if highCOAlarmLastDateString == "ffff" {
                // no date set yet
                
                self.highCOAlarmFaultIndicator = "green"
                //self.highCOAlarmLastDate = nil
                
            } else {
                let highCOAlarmLastDateInt = Int(highCOAlarmLastDateString, radix: 16)
                
                var highCOAlarmLastDateComponent = DateComponents()
                highCOAlarmLastDateComponent.hour = (runtimeClockInt! - highCOAlarmLastDateInt!) * -2
                let highCOAlarmLastDate = calendar.date(byAdding: highCOAlarmLastDateComponent, to: Date())
                self.highCOAlarmLastDate = highCOAlarmLastDate
                print("highCOAlarmLastDate: \(highCOAlarmLastDate!)")
                
                let HoursSinceLastHighCOAlarmEvent = (self.runtimeClock! - highCOAlarmLastDateInt!) * 2
                
                if HoursSinceLastHighCOAlarmEvent <= HoursInAMonth {
                    // event within the last year but not in the last month
                    self.highCOAlarmFaultIndicator = "red"
                } else if HoursSinceLastHighCOAlarmEvent <= HoursInAYear {

                    // the alam happened within the last month
                    self.highCOAlarmFaultIndicator = "amber"
                } else {
                    self.highCOAlarmFaultIndicator = "green"
                }
            }


        }
        
        //MARK:- MediumCOAlarm
        let mediumCOAlarmCountStartIndex = scan.index(scan.startIndex, offsetBy: 32)
        let mediumCOAlarmCountEndIndex = scan.index(scan.startIndex, offsetBy: 33)
        let mediumCOAlarmCountString = String(scan[mediumCOAlarmCountStartIndex...mediumCOAlarmCountEndIndex])
        let mediumCOAlarmCount = Int(mediumCOAlarmCountString, radix: 16)
        self.mediumCOAlarmCount = mediumCOAlarmCount
        print("mediumCOAlarmCount: \(mediumCOAlarmCount!)")
        
        if  mediumCOAlarmCount == 0 {
            self.mediumCOAlarmLastDate = nil
            self.mediumCOAlarmFaultIndicator = "green"
        } else {
            let mediumCOAlarmLastDateStartIndex = scan.index(scan.startIndex, offsetBy: 34)
            let mediumCOAlarmLastDateEndIndex = scan.index(scan.startIndex, offsetBy: 37)
            let mediumCOAlarmLastDateString = String(scan[mediumCOAlarmLastDateStartIndex...mediumCOAlarmLastDateEndIndex])
            let mediumCOAlarmLastDateInt = Int(mediumCOAlarmLastDateString, radix: 16)
            
            if mediumCOAlarmLastDateString == "ffff" {
                // no date set yet
                
                self.mediumCOAlarmFaultIndicator = "green"
                //self.highCOAlarmLastDate = nil
                
            } else {
                var mediumCOAlarmLastDateComponent = DateComponents()
                mediumCOAlarmLastDateComponent.hour = (runtimeClockInt! - mediumCOAlarmLastDateInt!) * -2
                let mediumCOAlarmLastDate = calendar.date(byAdding: mediumCOAlarmLastDateComponent, to: Date())
                self.mediumCOAlarmLastDate = mediumCOAlarmLastDate
                print("mediumCOAlarmLastDate: \(mediumCOAlarmLastDate!)")
                
                let HoursSinceLastMediumCOAlarmEvent = (self.runtimeClock! - mediumCOAlarmLastDateInt!) * 2
                
                if HoursSinceLastMediumCOAlarmEvent <= HoursInAMonth {
                    // the alam happened within the last month
                    self.mediumCOAlarmFaultIndicator = "red"
                } else if HoursSinceLastMediumCOAlarmEvent <= HoursInAYear {
                    // event withing the last year but not in the last month
                    self.mediumCOAlarmFaultIndicator = "amber"
                } else {
                    self.mediumCOAlarmFaultIndicator = "green"
                }
            }
        }
        //MARK:- LowCOAlarm
        let lowCOAlarmCountStartIndex = scan.index(scan.startIndex, offsetBy: 38)
        let lowCOAlarmCountEndIndex = scan.index(scan.startIndex, offsetBy: 39)
        let lowCOAlarmCountString = String(scan[lowCOAlarmCountStartIndex...lowCOAlarmCountEndIndex])
        let lowCOAlarmCount = Int(lowCOAlarmCountString, radix: 16)
        self.lowCOAlarmCount = lowCOAlarmCount
        print("lowCOAlarmCount: \(lowCOAlarmCount!)")
 
        if lowCOAlarmCount == 0 {
            self.lowCOAlarmLastDate = nil
            self.lowCOAlarmFaultIndicator = "green"
        } else {
            let lowCOAlarmLastDateStartIndex = scan.index(scan.startIndex, offsetBy: 40)
            let lowCOAlarmLastDateEndIndex = scan.index(scan.startIndex, offsetBy: 43)
            let lowCOAlarmLastDateString = String(scan[lowCOAlarmLastDateStartIndex...lowCOAlarmLastDateEndIndex])
            let lowCOAlarmLastDateInt = Int(lowCOAlarmLastDateString, radix: 16)
            
            if lowCOAlarmLastDateString == "ffff" {
                // no date set yet
                
                self.lowCOAlarmFaultIndicator = "green"
                //self.highCOAlarmLastDate = nil
                
            } else {
                var lowCOAlarmLastDateComponent = DateComponents()
                lowCOAlarmLastDateComponent.hour = (runtimeClockInt! - lowCOAlarmLastDateInt!) * -2
                let lowCOAlarmLastDate = calendar.date(byAdding: lowCOAlarmLastDateComponent, to: Date())
                self.lowCOAlarmLastDate = lowCOAlarmLastDate
                print("lowCOAlarmLastDate: \(lowCOAlarmLastDate!)")
                
                let HoursSinceLastLowCOAlarmEvent = (self.runtimeClock! - lowCOAlarmLastDateInt!) * 2
                
                if HoursSinceLastLowCOAlarmEvent <= HoursInAMonth {
                    // the alam happened within the last month
                    self.lowCOAlarmFaultIndicator = "red"
                } else if HoursSinceLastLowCOAlarmEvent <= HoursInAYear {
                    // event withing the last year but not in the last month
                    self.lowCOAlarmFaultIndicator = "amber"
                } else {
                    self.lowCOAlarmFaultIndicator = "green"
                    
                }
            }
        }
        
        //MARK:- PreCOAlarm
        let preCOAlarmCountStartIndex = scan.index(scan.startIndex, offsetBy: 44)
        let preCOAlarmCountEndIndex = scan.index(scan.startIndex, offsetBy: 45)
        let preCOAlarmCountString = String(scan[preCOAlarmCountStartIndex...preCOAlarmCountEndIndex])
        let preCOAlarmCountInt = Int(preCOAlarmCountString, radix: 16)
        self.preCOAlarmCount = preCOAlarmCountInt
       
        if  preCOAlarmCountInt == 0 {
            self.preCOAlarmLastDate = nil
            self.preCOAlarmFaultIndicator = "green"
        } else {
            let preCOAlarmLastDateStartIndex = scan.index(scan.startIndex, offsetBy: 46)
            let preCOAlarmmLastDateEndIndex = scan.index(scan.startIndex, offsetBy: 49)
            let preCOAlarmLastDateString = String(scan[preCOAlarmLastDateStartIndex...preCOAlarmmLastDateEndIndex])
            let preCOAlarmLastDateInt = Int(preCOAlarmLastDateString, radix: 16)
            
            if preCOAlarmLastDateString == "ffff" {
                // no date set yet
                
                self.preCOAlarmFaultIndicator = "green"
                //self.highCOAlarmLastDate = nil
                
            } else {
                var preCOAlarmLastDateComponent = DateComponents()
                preCOAlarmLastDateComponent.hour = (runtimeClockInt! - preCOAlarmLastDateInt!) * -2
                self.preCOAlarmLastDate = calendar.date(byAdding: preCOAlarmLastDateComponent, to: Date())
                
                let HoursSinceLastPreCOAlarmEvent = (self.runtimeClock! - preCOAlarmLastDateInt!) * 2
                
                if HoursSinceLastPreCOAlarmEvent <= HoursInAMonth {
                    // the alam happened within the last month
                    self.preCOAlarmFaultIndicator = "red"
                } else if HoursSinceLastPreCOAlarmEvent <= HoursInAYear {
                    // event withing the last year but not in the last month
                    self.preCOAlarmFaultIndicator = "amber"
                } else {
                    self.preCOAlarmFaultIndicator = "green"
                }
            }
        }
        
        //MARK:- Faults
        let faultFlagStartIndex = scan.index(scan.startIndex, offsetBy: 70)
        let faultFlagEndIndex = scan.index(scan.startIndex, offsetBy: 71)
        let faultFlagString = String(scan[faultFlagStartIndex...faultFlagEndIndex])
        let faultFlagUInt8 = UInt8(faultFlagString, radix: 16)
        self.faultFlag = faultFlagUInt8! //0xFF//
    
        if (self.faultFlag & 0x01) == 0x01
        {
            //MARK:- batteryFaultDate
            let batteryFaultDateStartIndex = scan.index(scan.startIndex, offsetBy: 50)
            let batteryFaultDateEndIndex = scan.index(scan.startIndex, offsetBy: 53)
            let batteryFaultDateString = String(scan[batteryFaultDateStartIndex...batteryFaultDateEndIndex])
            
            if batteryFaultDateString == "ffff" {
                print("date value not set")
                self.batteryFaultDate = nil
            } else {
            
                let batteryFaultDateInt = Int(batteryFaultDateString, radix: 16)
                
                
                var batteryFaultDateComponent = DateComponents()
                batteryFaultDateComponent.hour = (runtimeClockInt! - batteryFaultDateInt!) * -2
                let batteryFaultDate = calendar.date(byAdding: batteryFaultDateComponent, to: Date())
                self.batteryFaultDate = batteryFaultDate
            }
        } else {
            self.batteryFaultDate = nil
        }
       
        print("self.batteryFaultDate: \(String(describing: self.batteryFaultDate))")
       
        if (self.faultFlag & 0x02) == 0x02
        {
            //MARK:- deviceFaultDate
            let deviceFaultDateStartIndex = scan.index(scan.startIndex, offsetBy: 54)
            let deviceFaultDateEndIndex = scan.index(scan.startIndex, offsetBy: 57)
            let deviceFaultDateString = String(scan[deviceFaultDateStartIndex...deviceFaultDateEndIndex])
            
            if deviceFaultDateString == "ffff"{
                print("date value not set")
                self.deviceFaultDate = nil
            } else {

            
                let deviceFaultDateInt = Int(deviceFaultDateString, radix: 16)
                
                var deviceFaultDateComponent = DateComponents()
                deviceFaultDateComponent.hour = (runtimeClockInt! - deviceFaultDateInt!) * -2
                self.deviceFaultDate = calendar.date(byAdding: deviceFaultDateComponent, to: Date())
            }
        } else {
            self.deviceFaultDate = nil
        }
        
        print("self.deviceFaultDate: \(String(describing: self.deviceFaultDate))")
        
        if (self.faultFlag & 0x04) == 0x04
        {
            //MARK:- eol_FaultDate
            let eol_FaultDateStartIndex = scan.index(scan.startIndex, offsetBy: 58)
            let eol_FaultDateEndIndex = scan.index(scan.startIndex, offsetBy: 61)
            let eol_FaultDateString = String(scan[eol_FaultDateStartIndex...eol_FaultDateEndIndex])
            
            if eol_FaultDateString == "ffff" {
                print("date value not set")
                self.eol_FaultDate = nil
                
            } else {
                
                
                let eol_FaultDateInt = Int(eol_FaultDateString, radix: 16)
                
                var eol_FaultDateComponent = DateComponents()
                eol_FaultDateComponent.hour = (runtimeClockInt! - eol_FaultDateInt!) * -2
                self.eol_FaultDate = calendar.date(byAdding: eol_FaultDateComponent, to: Date())
            }
        } else {
            self.eol_FaultDate = nil
        }
        
        print("self.eol_FaultDate: \(String(describing: self.eol_FaultDate))")
        
        if (self.faultFlag & 0x08) == 0x08
        {
            //MARK:- remoteFaultDate
            let remoteFaultDateStartIndex = scan.index(scan.startIndex, offsetBy: 62)
            let remoteFaultDateEndIndex = scan.index(scan.startIndex, offsetBy: 65)
            let remoteFaultDateString = String(scan[remoteFaultDateStartIndex...remoteFaultDateEndIndex])
            
            if remoteFaultDateString == "ffff" {
                print("remoteFaultDateString date value not set")
                self.remoteFaultDate = nil
                
            } else {
                
                let remoteFaultDateInt = Int(remoteFaultDateString, radix: 16)
                
                var remoteFaultDateComponent = DateComponents()
                remoteFaultDateComponent.hour = (runtimeClockInt! - remoteFaultDateInt!) * -2
                self.remoteFaultDate = calendar.date(byAdding: remoteFaultDateComponent, to: Date())
            }
        } else {
            self.remoteFaultDate = nil
        }
        
        print("self.remoteFaultDate: \(String(describing: self.remoteFaultDate))")
        
        //MARK:- PeakCO
        let peakCOStartIndex = scan.index(scan.startIndex, offsetBy: 66)
        let peakCOEndIndex = scan.index(scan.startIndex, offsetBy: 69)
        let peakCOString = String(scan[peakCOStartIndex...peakCOEndIndex])
        let peakCOInt = Int(peakCOString, radix: 16)
        
      
        self.peakCO = peakCOInt
        
        print("self.peakCO: \(String(describing: self.peakCO))")
        
        //MARK:- batteryVoltage
        let batteryVoltageStartIndex = scan.index(scan.startIndex, offsetBy: 72)
        let batteryVoltageEndIndex = scan.index(scan.startIndex, offsetBy: 73)
        let batteryVoltageString = String(scan[batteryVoltageStartIndex...batteryVoltageEndIndex])
        let batteryChargeInt = Int(batteryVoltageString, radix: 16)
        
        let batteryVoltageFloat = Float(batteryChargeInt! + 128) * 0.01
        self.batteryVoltage = batteryVoltageFloat
        
        print("self.batteryVoltage: \(String(describing: self.batteryVoltage))")
        
        if batteryVoltageFloat <= 2.00 {
            print("flatBattery")
            self.batteryChargePercentage = 0.00
        } else {
            let batteryChargePercentage = (Float(batteryChargeInt! - 100)/155) * 100
            self.batteryChargePercentage = batteryChargePercentage
        }
        
        print("self.batteryChargePercentage = \(String(describing: self.batteryChargePercentage))")
        
        //TODO:- complete batery condition filtering and move to replacemnet dates 27/07/2021
        let batteryLifeRemaining_YearsLeft = Float(self.deviceLifetimeYears!) * self.batteryChargePercentage!
        let batteryLifeRemaining_HoursLeft = batteryLifeRemaining_YearsLeft * (365 * 24)
        self.batteryLifeRemaining_YearsLeft = batteryLifeRemaining_YearsLeft
       
        print("self.batteryLifeRemaining_YearsLeft: \(String(describing: self.batteryLifeRemaining_YearsLeft))")
        
        var batteryLifeRemaining_ReplacentDateComponent = DateComponents()
        batteryLifeRemaining_ReplacentDateComponent.hour = Int(batteryLifeRemaining_HoursLeft)
        let batteryLifeRemaining_ReplacentDate = calendar.date(byAdding: batteryLifeRemaining_ReplacentDateComponent, to: Date())
        
        let dataFormater = DateFormatter()
        dataFormater.dateFormat = "dd.mm.yyyy"
        
        self.batteryLifeRemaining_ReplacentDate = batteryLifeRemaining_ReplacentDate
        
        print("self.batteryLifeRemaining_ReplacentDate: \(String(describing: self.batteryLifeRemaining_ReplacentDate))")
        
        if (plateRemovalInt == 0) {
            var maufactureDateComponent = DateComponents()
            maufactureDateComponent.hour = runtimeClockInt! * -2
            self.maufactureDate = calendar.date(byAdding: maufactureDateComponent, to: Date())
        } else {
            self.maufactureDate = snManufactureDate
        }
        
        print("self.maufactureDate: \(String(describing: self.maufactureDate))")
        
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
        
        print("self.deviceReplacentDate: \(String(describing: self.deviceReplacentDate))")
        print("self.deviceLifeRemaining_HoursLeft: \(String(describing: self.deviceLifeRemaining_HoursLeft))")
        
        //MARK:- Software Version
        let softwateVersionStartIndex = scan.index(scan.startIndex, offsetBy: 74)
        let softwateVersionEndIndex = scan.index(scan.startIndex, offsetBy: 75)
        let softwateVersionString = String(scan[softwateVersionStartIndex...softwateVersionEndIndex])
        self.softwareVersion = softwateVersionString
        print("Software Verson String= \(softwateVersionString)")
        
        //MARK:- set faults

            
        //var activeFaults = self.faultFlag
        
        if (self.faultFlag & 0x01 != 0x01) {
            self.batteryFault = false
        }
        
        if (self.faultFlag & 0x02 != 0x02) {
            self.deviceFault = false
        }
        
        if (self.faultFlag & 0x04 != 0x04) {
            self.eol_Fault = false
        }
        
        if (self.faultFlag & 0x08 != 0x08) {
            self.remoteFault = false
        }
        
        
//        //MARK:- Check Sum
//        let checkSumStartIndex = scan.index(scan.startIndex, offsetBy: 76)
//        let checkSumEndIndex = scan.index(scan.startIndex, offsetBy: 77)
//        let checkSumString = String(scan[checkSumStartIndex...checkSumEndIndex])
//        self.checkSum = checkSumString
//        self.checkSumValue = UInt8(checkSumString, radix: 16)
//
//        print("checkSum String= \(checkSumString)")
//
//        var checkIntTemp = 0
//
//        //checksum
//        for i in stride(from: 0, to: scan.count - 2, by: 2) {
//            let byteStartIndex = scan.index(scan.startIndex, offsetBy: i)
//            let byteEndIndex = scan.index(scan.startIndex, offsetBy: i+1)
//
//            let byteString = String(scan[byteStartIndex...byteEndIndex])
//            let byteInt = UInt16(byteString, radix: 16)
//
//            self.checkSumUInt16 = (self.checkSumUInt16 + byteInt!)// & 0x00FF
//            print("Check sum value = \(self.checkSumUInt16)    ,\(checkIntTemp) + \(byteInt!) ")
//
//            checkIntTemp = Int(self.checkSumUInt16)
//        }
//
//        self.checkSumUInt16 = self.checkSumUInt16 & 0x00FF
//
//        if self.checkSumValue! == self.checkSumUInt16 {
//            print("bad Check sum, Invalid scan")
//        }
//
        
        //MARK:- Device Health Marker
        
        if self.faultFlag == 0x00 && self.lifeRemainingFaultIndicator == "green"
                    && self.plateRemovalsFaultIndicator == "green"
                    && self.deviceTestFaultIndicator == "green"
                    && self.highCOAlarmFaultIndicator == "green"
                    && self.mediumCOAlarmFaultIndicator  == "green"
                    && self.lowCOAlarmFaultIndicator == "green"
                    && self.preCOAlarmFaultIndicator == "green" {
            
            self.deviceFaultIndicator = "green"
            
        } else if self.faultFlag != 0x00 || self.lifeRemainingFaultIndicator == "red"
                    || self.plateRemovalsFaultIndicator == "red"
                    || self.deviceTestFaultIndicator == "red"
                    || self.highCOAlarmFaultIndicator == "red"
                    || self.mediumCOAlarmFaultIndicator  == "red"
                    || self.lowCOAlarmFaultIndicator == "red"
                    || self.preCOAlarmFaultIndicator == "red" {
            // main indicator is red
            self.deviceFaultIndicator = "red"
            
        } else {
            
            self.deviceFaultIndicator = "amber"
        }
        
    }
    
    
}
