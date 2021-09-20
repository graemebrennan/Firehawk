//
//  ScannerFunctions.swift
//  FireHawk
//
//  Created by Graeme Brennan on 2/9/21.
//

import Foundation
import AVFoundation
import UIKit


class ScanningFunctions2 {
    
   
    let pixels: UnsafeMutableBufferPointer<RGBAPixel>
 //   var p: UnsafeMutableBufferPointer<RGBAPixel>] = []
 //   var pLast: UnsafeMutableBufferPointer<RGBAPixel>
    
    var binaryState = 1
    var binaryStatemem = 0
    var col = 0
    var lineWidthRed = 0
    var lineWidthBlack = 0
    var biggestPreambleLineWidth = 0
    var lines: [Lines] = []
    
    var preambleIndex: [Int] = []
    var binaryString = ""
    
    var decodedString: String?
    var byteNum: String?
    var byteData: String?
    
    var num = 0
    
    var startScan = 0
    var endScan = 0
    var scanWidth = 0
    var redLineWidthAverage = 0
    var redLineWidthTotal = 0
    var widthcheck = 0
    var startIndex = 0
    var endIndex = 0
    var centerPreamble = 0
    
    // raw image variables
    var width = 0
    var height = 0
    var ciImage: CIImage
    var upperLightThreshold = 0
    var lowerLightThreshold = 0
    var totalPacketTime = 0
    
    var outImage: [UIImage] = []
    //var packet = Packet()
    
    
    init (uiImage: UIImage) {
        
        // create a CIImage from Image Buffer
        let frame = uiImage
        let cg1 = uiImage.cgImage!
        self.ciImage = CIImage(cgImage: cg1)
        
        let imageRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        // ------------------------------------------------------------------------------------------------------filtered image from samplebuffer
        //CIImage.
        
        // get fltered image
        
        self.height = Int(imageRect.height)
        self.width = Int((imageRect.width))
        
        let bitsPerComponent = Int(8)
        let bytesPerRow = 4 * width
        
        // get colour space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // allocate buffer for pixles
        let rawData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: (width * height))
        
        // get bitmap info as 32 bit uint
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        //                let CGPointZero = CGPoint(x: 0, y: 0)
        
        // Filter image
        // add image filters
        
        // initialise CIContext needed in conjunction with CIImage for eveluating images
        let context = CIContext()
        // create a rectange with frame width and height - why?
        
        
        let filter = CIFilter(name: "CIColorControls")!
//        filter.setValue(5, forKey: kCIInputSaturationKey)
//        filter.setValue(3, forKey: kCIInputBrightnessKey)
//        filter.setValue(2, forKey: kCIInputContrastKey)
//
        filter.setValue(self.ciImage, forKey: kCIInputImageKey)
        
        let result = filter.outputImage!
        
        let ciImage_Filtered = context.createCGImage(result, from: result.extent)!
        //
        
        // Create Quarts 2d Image from a reagoin of a core image object
        // this can be used to limit the size/ area of the scan!!!
        // if let imageContext = context.createCGImage(ciImage, from: imageRect){
        
        let imageContext2 = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            
        imageContext2!.draw(ciImage_Filtered, in: imageRect)
            
            // code from https://www.youtube.com/watch?v=S9fbO9l4mVM
            
        self.pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawData, count: width * height)

        self.startScan = Int(Double(self.height) * 0.3)
        self.endScan = Int(Double(self.height) * 0.7)
        
    //    self.FindROI()
        
        // find the average red light intensity and create a threshold for a high and low signal
        self.FindSignalThresholds()
        
        
        // this runs and fills a lines array check this has a usefull output
        self.DecodeImage()
        
     //   self.DrawMarkAtLineStart()
        
        if lines.count > 15 {

            self.FindLindWidthAverage()
            self.IdentifyLineType()
            self.CalculatePacketWidth()
            self.CalaculateNextSample()
            self.DrawPacketLimits()
            
            if self.preambleIndex.count > 0 {
                self.SamplePacket()
                
            }else {
                print("badPreamble")
            }
        } else {
            print("not enogh lines")
        }
       self.BuildOutputImage()
    }

    
    func FindROI() {
        
        // find ROI
        for i in 1..<10
        {
            for j in 1..<10
            {
                for x in 0..<10
                {
                    
                    self.pixels[((width/10) * i) + x + (((height/10) * j) * width)] = RGBAPixel(rawVal: 0xAA00FFFF)
                    
                }
            }
        }
    }

    // this function will scan the center of the image and calculate the upper and lower light thresholds for the image analysis.
    func FindSignalThresholds() {
        
        var lightMax = 0
        var lightTotal = 0
        var lightValue = 0
        var lightAvg = 0
        
        var focusStartHeight = Int(Float(height) * 0.3)
        var focusEndHeight = Int(Float(height) * 0.7)
        
        var focusStartWidth = Int(Float(width) * 0.3)
        var focusEndWidth = Int(Float(width) * 0.7)
        
        for j in focusStartHeight..<focusEndHeight {
            
            for i in stride(from: focusStartWidth, through: focusEndWidth, by: 20) {
                let p = self.pixels[(i) + j * (self.width)]
                
                if Int(p.red) > lightMax {
                    lightMax = Int(p.red)
                    
                }
              
            }
            
            //average light intensity over frame
            lightTotal += lightMax
            lightMax = 0

        }
        
        
        lightAvg = (lightTotal / (focusEndHeight - focusStartHeight))
        
        // gb check light max is averaging to find a good light threshold, i think here is my noise problem
        self.upperLightThreshold = Int(Float(lightAvg) * 0.7)
        self.lowerLightThreshold = Int(Float(lightAvg) * 0.3)
        
    }
                    
    // this function builds the array of lines from the objects pixel buffer
    func DecodeImage() {
        
        var brightestPixel = 0
        var p = self.pixels[0]
        var pLast = self.pixels[0]
        
        var focusStartHeight = Int(Float(height) * 0.2)
        var focusEndHeight = Int(Float(height) * 0.8)
        
        var focusStartWidth = Int(Float(width) * 0.2)
        var focusEndWidth = Int(Float(width) * 0.8)
        
        var rowTotalValue = 0
        var rowAvgValue = 0
        var rowMaxValue: UInt8 = 0
        var rowMaxValueLast: UInt8 = 0
        
        var count = 0
        var pred = 0
        
        for j in focusStartHeight..<focusEndHeight {
            
            for i in stride(from: focusStartWidth, through: focusEndWidth, by: 20) {
                p = self.pixels[(i) + j * (self.width)]

                // averageValue of a row
                pred = Int(p.red)
                rowTotalValue = rowTotalValue + Int(p.red)
                count = count + 1
            }
            
            rowAvgValue = rowTotalValue / count
      //      print ("rowMaxValue = \(rowAvgValue), Row = \(j)")
            rowMaxValue = UInt8(rowAvgValue)
            rowAvgValue = 0
            rowTotalValue = 0
            count = 0
                // find the brightest spot in the image
                
        //        if p.red > pLast.red
        //        {
        //            brightestPixel = j
        //        }
                
                if (rowMaxValue > upperLightThreshold) && (binaryState == 0)
                {

                    // found a change in brightness
                    if (rowMaxValueLast > upperLightThreshold)
                    {
                        binaryState = 1

                        //transition to a red line so close the curent black line
                        //lineWidthBlack = j - col

                        if lines.count > 0
                        {
                            lineWidthBlack = j - col

                            lines.append(Lines(start: col, end: j, width: lineWidthBlack, position: "low", type: nil))
                            
                        }else
                        {

                            lines.append(Lines(start: focusStartHeight, end: j, width: (j-focusStartHeight), position: "N/A", type: nil))
                            
                        }
                        col = j
//                        print("p.red is Greater than the upper thresholde of '\(upperLightThreshold)' as p.red =  \(rowMaxValue)")
//                        print("binaryState: \(binaryState)")
//                        print("lineWidthBlack: \(lineWidthBlack)")
                    }

                }else if (rowMaxValue < lowerLightThreshold) && (binaryState == 1)
                {
                    if (rowMaxValueLast < lowerLightThreshold)
                    {
                        binaryState = 0

                        if lines.count > 0
                        {
                            lineWidthRed = j - col

                            lines.append(Lines(start: col-1, end: j-1, width: lineWidthRed, position: "high", type: nil))
                            

                        }else
                        {


                            lines.append(Lines(start: focusStartHeight, end: j, width: (j-focusStartHeight), position: "N/A", type: nil))
                            
                        }

                        col = j
//                        print("p.red is Lower than the upper thresholde of '\(lowerLightThreshold)' as p.red =  \(rowMaxValue)")
//                        print("binaryState: \(binaryState)")
//                        print("lineWidthRed: \(lineWidthRed)")
                    }
                }





            rowMaxValueLast = rowMaxValue
            rowMaxValue = 0
        //        //     find number of red columns in frame
        //        if binaryState != binaryStatemem
        //        {
        //            // a line change has been detected
        //            // update binarystate memory for next change
        //            binaryStatemem = binaryState
        //
        //            // find the thickest line in frame this will be a preamble line
        //            if lineWidthRed > biggestPreambleLineWidth{
        //                biggestPreambleLineWidth = lineWidthRed
        //                //                                biggestPreambleLineWidthColEnd = j
        //                //                                biggestPreambleLineWidthColBeginning = j - biggestPreambleLineWidth
        //            }
        //        }
            
        
    //        self.BuildOutputImage()
            
        }
        
    }
            
      //      print("test")

        
    func FindLindWidthAverage() {
        // find the location of the preamble lines
        for i in 0..<lines.count {
            
            //calculate average line width
            redLineWidthTotal += lines[i].width
            // find big red preamble lines
            widthcheck = lines[i].width
            
        }
        
        redLineWidthAverage = redLineWidthTotal / lines.count
    }
        
    func IdentifyLineType() {
        
        for i in 0..<lines.count {
            
            
            
            //calculate average line width
            if ((lines[i].width) > (2 * redLineWidthAverage) + 3 ) && (lines[i].position == "high")
            {
                lines[i].type = "Preamble"
                preambleIndex.append(i)
                
            }else
            {
                lines[i].type = "Data"
            }
            
              print("lineType [\(i)]= \(lines[i].type!)" )
        }
        
        for i in 0..<preambleIndex.count {
            print("PreambleIndex = \(preambleIndex[i])")
        }
        
    }
        
    func CalculatePacketWidth() {
        
        if preambleIndex.count > 0 {
            
            // calculate image rows between preambles i.e how many rows dose the center packet take up in the frame
            
            if preambleIndex.count > 2 {
                // find centre preamble
                centerPreamble = preambleIndex.count / 2
                
                
                startIndex = lines[preambleIndex[centerPreamble]].start
                endIndex = lines[preambleIndex[centerPreamble+1]].start
                
                
            }else if preambleIndex.count == 2 {
                centerPreamble = 0

                startIndex = lines[preambleIndex[centerPreamble]].start
                endIndex = lines[preambleIndex[centerPreamble+1]].start

            }else {
                
            }
            
            self.totalPacketTime = endIndex - startIndex
        
//            print("totalPacketTime = \(totalPacketTime)")
            
        }
    }
                
    func CalaculateNextSample() {
//        // calculate the time between samples for each packet
//        let sampleTime = Int(self.totalPacketTime / 34)
//        let sampleTest = Int(Double(sampleTime) * 1.6)
//
//        // lines[preambleIndex[0]].start
//
//        if (lines[preambleIndex[centerPreamble] + 1].width) > (sampleTest)
//        {
//            // first bit is low
//        }else
//        {
//            // first bit is high
//        }
////                    for bit in 0..<28 {
////
////                        print("preambleIndex[\(bit)].start = \(lines[preambleIndex[centerPreamble] + bit].start)")
////                        print("preambleIndex[\(bit)].end = \(lines[preambleIndex[centerPreamble] + bit].end)")
////                        print("preambleIndex[\(bit)].width = \(lines[preambleIndex[centerPreamble] + bit].width)")
////                        print("preambleIndex[\(bit)].position = \(lines[preambleIndex[centerPreamble] + bit].position!)")
////                        print("preambleIndex[\(bit)].type = \(lines[preambleIndex[centerPreamble] + bit].type!)")
////                    }
////
//        // calculate the first samples position
//        //var firstSample = redLines[preambleIndex[ packetIndex-1 ]].start + ((totalPacketTime / 34) / 2)
//        // idealy thi should be 11 but im not sure the arduino or light intensity thresholds are adequate so a littl tuneing may be nessisary
//        var c = Float(11.2 * Float(self.totalPacketTime / 68))
//        return c
    }
            
    func DrawPacketLimits() {
        // draw start marker
        for i in 0..<100
        {
            pixels[(width/2) + i + (startIndex * width)] = RGBAPixel(rawVal: 0xAAFFFFFF)
        }
        
        for i in 0..<100
        {
            // draw end marker
            pixels[(width/2) + i + (endIndex * width)] = RGBAPixel(rawVal: 0xAAFFFFFF)
        }
        
    }
       
    func SamplePacket() {
        
        
      //  var startOfPacket = lines[startIndex]
      //  var endOfPacket = lines[endIndex]
        var bitCorrectionFactor = 0.8
        var preambleWidth = lines[preambleIndex[centerPreamble]].width
        var bitWidth = Int(Double(preambleWidth / 4) * bitCorrectionFactor)
        
        
//        for bit in 1..<24 {
//
//            print("lines[startIndex + 1].type = \(lines[preambleIndex[centerPreamble] + bit].type)")
//            print("lines[startIndex + 1].position = \(lines[preambleIndex[centerPreamble] + bit].position)")
//            print("lines[startIndex + 1].width = \(lines[preambleIndex[centerPreamble] + bit].width)")
//
//            if lines[preambleIndex[centerPreamble] + bit].width > (bitWidth * 2) {
//                print("wideLine")
//            }else {
//                print("thinLine")
//            }
//
//
//
//
//
//
//        }
        var c = Float(self.totalPacketTime / 68) + 0.5
        var samples = Float(self.totalPacketTime / 34)
        
        
        for bit in 0..<28 {

            //let row = Int((11 * Float(sampleTime)) + (Float(bit) * 2 * Float(sampleTime)))
            let row = Int( ( Float(bit + 5) * Float(totalPacketTime) ) / Float(34.00) + c)


           // let row = Int((Float(bit + 5) * samples) + c )

        //      print("row = \(row)")


//            print("preambleIndex[0] = \(preambleIndex[0])")
//            print("row = \(row)")
//            print("lines[preambleIndex[0]].start = \(lines[preambleIndex[0]].start)")
//            print("redLines[preambleIndex[0]].start + row = \(redLines[preambleIndex[0]].start + row)")
            var testindex = (width/2) - 30 + ((lines[preambleIndex[0]].start + row + 1 ) * width)
            // get data in binary form
            
            
//              print("pixle val = \(pixels[testindex].red)")
//            print("testindex = \(testindex)")
//            print("pixels[testindex].red \(pixels[testindex].red) ")


            if pixels[testindex].red > upperLightThreshold {
                // we have a binary 1
                binaryString.append("1")

                // draw inspection spot
                for i in 0..<20
                {
                    pixels[(width/2) - i - 30 + ((startIndex + row + 1) * width)] = RGBAPixel(rawVal: 0xAA00FFFF)
                }

            } else{
                // we have a binary 0
                binaryString.append("0")
                // draw inspection spot
                for i in 0..<20
                {
                    pixels[(width/2) + i - 30 + ((startIndex + row + 1) * width)] = RGBAPixel(rawVal: 0xAA00FFFF)
                }
            }

            // draw test pixle
        //    pixels[(width/2) + ((startIndex + row) * width)] = RGBAPixel(rawVal: 0xAA00FFFF)

        }
        
        let decodedString = ManchesterDecoder(encodedString: binaryString)
        
        if decodedString == "Corrupt Scan Data" {
            binaryString = ""
            print("----------------------SamplePacketBackup")
            SamplePacketBackup()
        } else {
            
            // unpack decoded string
            let PacketNumStartIndex = decodedString.index(decodedString.startIndex, offsetBy: 0)
            let PacketNumEndIndex = decodedString.index(decodedString.startIndex, offsetBy: 5)
            let nstr = String(decodedString[PacketNumStartIndex...PacketNumEndIndex])
            let n = UInt8(nstr, radix: 2)
            self.byteNum = String(UInt8(nstr, radix: 2)!)
           
            if n! > 38 {

                print("----------------------test spot issue n = \(self.byteNum)")
            }
            
            
            
            
            let rawDataByteStartIndex = decodedString.index(decodedString.startIndex, offsetBy: 6)
            let rawDataByteEndIndex = decodedString.index(decodedString.startIndex, offsetBy: 13)
            let dstr = String(decodedString[rawDataByteStartIndex...rawDataByteEndIndex])
            let hexInt = UInt16(dstr, radix: 2)
            
            // swift ignores the leading 0
            if hexInt! < 16 {
                self.byteData = "0" + String(hexInt!, radix: 16)
            } else {
                self.byteData = String(hexInt!, radix: 16)
            }
//
            
            //self.packet.rawData[Int(n!)]?.packetNum = Int(self.byteData!)
        }
        //TODO:-  delete When stable
        

        
       // self.BuildOutputImage()
        
    }
           
    func SamplePacketBackup() {
        
        
      //  var startOfPacket = lines[startIndex]
      //  var endOfPacket = lines[endIndex]
        var bitCorrectionFactor = 0.8
        var preambleWidth = lines[preambleIndex[centerPreamble]].width
        var bitWidth = Int(Double(preambleWidth / 4) * bitCorrectionFactor)
        
        
//        for bit in 1..<24 {
//
//            print("lines[startIndex + 1].type = \(lines[preambleIndex[centerPreamble] + bit].type)")
//            print("lines[startIndex + 1].position = \(lines[preambleIndex[centerPreamble] + bit].position)")
//            print("lines[startIndex + 1].width = \(lines[preambleIndex[centerPreamble] + bit].width)")
//
//            if lines[preambleIndex[centerPreamble] + bit].width > (bitWidth * 2) {
//                print("wideLine")
//            }else {
//                print("thinLine")
//            }
//
//
//
//
//
//
//        }
        var c = Float(self.totalPacketTime / 68) + 0.5
        var samples = Float(self.totalPacketTime / 34)
        
        
        for bit in 0..<28 {

            //let row = Int((11 * Float(sampleTime)) + (Float(bit) * 2 * Float(sampleTime)))
            let row = Int( ( Float(bit + 5) * Float(totalPacketTime) ) / Float(34.00) + c)


           // let row = Int((Float(bit + 5) * samples) + c )

        //      print("row = \(row)")


//            print("preambleIndex[0] = \(preambleIndex[0])")
//            print("row = \(row)")
//            print("lines[preambleIndex[0]].start = \(lines[preambleIndex[0]].start)")
//            print("redLines[preambleIndex[0]].start + row = \(redLines[preambleIndex[0]].start + row)")
            var testindex = (width/2) + 30 + ((lines[preambleIndex[0]].start + row + 1 ) * width)
            // get data in binary form
            
            
//              print("pixle val = \(pixels[testindex].red)")
//            print("testindex = \(testindex)")
//            print("pixels[testindex].red \(pixels[testindex].red) ")


            if pixels[testindex].red > upperLightThreshold {
                // we have a binary 1
                binaryString.append("1")

                // draw inspection spot
                for i in 0..<20
                {
                    pixels[(width/2)  + 30 - i + ((startIndex + row + 1) * width)] = RGBAPixel(rawVal: 0xAAFF0000)
                }

            } else{
                // we have a binary 0
                binaryString.append("0")
                // draw inspection spot
                for i in 0..<20
                {
                    pixels[(width/2)  + 30 + i + ((startIndex + row + 1) * width)] = RGBAPixel(rawVal: 0xAAFF0000)
                }
            }

            // draw test pixle
        //    pixels[(width/2) + ((startIndex + row) * width)] = RGBAPixel(rawVal: 0xAA00FFFF)

        }
        
        let decodedString = ManchesterDecoder(encodedString: binaryString)
        

        //TODO:-  delete When stable
        
        self.BuildOutputImage()
    }
    
    func ManchesterDecoder(encodedString: String) -> String {
        var decodedString = ""
        
        for j in stride(from: 0, to: 28, by: 2)
        {
            
            let firstBitIndex = encodedString.index(encodedString.startIndex, offsetBy: j)
            let secondBitIndex = encodedString.index(encodedString.startIndex, offsetBy: j+1)
            
            if (encodedString[firstBitIndex] == "1") && (encodedString[secondBitIndex] == "0") {
                
                decodedString.append("0")
                
            }else if (encodedString[firstBitIndex] == "0") && (encodedString[secondBitIndex] == "1")
            {
                decodedString.append("1")
            }else
            {
                print("Bad ManchesterDecoder")
                return "Corrupt Scan Data"
            }
            
        }
        
        print("decodedString = \(decodedString)")
        return decodedString
    }
    
    func BuildOutputImage(){
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // get bitmap info as 32 bit uint
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
       
        let bitsPerComponent = Int(8)
        
        let bytesPerRow = 4 * width
        
                    let outContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent,bytesPerRow: bytesPerRow,space: colorSpace,bitmapInfo: bitmapInfo,releaseCallback: nil,releaseInfo: nil)
    
                    outImage.append(UIImage(cgImage: outContext!.makeImage()!))
        
        //MARK: - i have the raw data as a binary string at this point
  //     print("binaryString: = \(binaryString)")

    }
        
    
    func DrawMarkAtLineStart() {
        
        for i in 0..<self.lines.count{
            for j in 0..<20 {
                
            
            self.pixels[(width/2) - j + ((self.lines[i].start) * width)] = RGBAPixel(rawVal: 0xAA00FFFF)
            }
        }
        
        BuildOutputImage()
    }
    
    func DrawMarkAtLinepoint(point: Int) {
        

            for j in 0..<20 {
                
            
            self.pixels[(width/2) + j + ((point) * width)] = RGBAPixel(rawVal: 0x00FFFFFF)
            }
        
    }
    
    
}

