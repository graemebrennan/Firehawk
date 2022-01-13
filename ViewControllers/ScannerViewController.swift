//
//  BarCodeScanViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import AVFoundation
import PDFKit
import MessageUI
import Device

class ScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate  { //FrameExtractorDelegate
    
    var newPropertyDetails = PropertyDetails() // valid only on first scan
    var scanCount: Int? // nil on first scan
    
    
    var newScan: String? = nil
    let SCAN_LENGTH: Int = 72
    // scan button flag
    var startScan = false
    var numPackets = 0
    let LIThreshold = 60
    public var data1: [UInt] = []
    var capture = false
    var outImage: [UIImage] = []
    
    var imageBufferArray: [CVImageBuffer] = []
    
    var frameAnalyser = Frame()
    var frames: [Frame] = []
    var packet = Packet()
    public var fakePacket = FakePacket()
    
    var captureSession = AVCaptureSession()
    
    // initialize video capture device for AVFoundation - see how others do this, it should be global but do they guard/error check?
    var videoDevice: AVCaptureDevice!
    
    //var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var FrameCapturCount = 0
    var scanComplete = false
    var frameProcessCounter = 0
    var frameWidth: Int = 0
    var frameHeigth: Int = 0
    var framecapture: [UIImage] = []
    var PacketCollection = 0
    
    var scannedImageArray: [UIImage] = []
    var sampleBufferArray: [CMSampleBuffer] = []
    var ibArray: [CVImageBuffer] = []
    
    let frameProcessQueue = DispatchQueue(label: "frameProcessQueue", qos: .utility)
    let FrameCaptureQueue = DispatchQueue(label: "FrameCaptureQueue")
    var seguePerformed = false
    var completeFrames = 0
    
    var counter = 0
    var corruptFrameCounter = 0
    var badManchester = 0
    
    var droppedFrames = 0
    
    let sampleDelay = 30
    let singleSample = 39
    let doubleSample = 78
    
    //var ImageMaster: ScannerFunctions60FPS?
    let packetCount = 7
    var badScan = false
    
    var pdfDebugDoc: PDFDocument!
    
    var fraemInfoArray: [FrameSettings] = []
    var fps: Double = 30
    
    var PacketCount = 39
    
    //var frameExtractor: FrameExtractor!
    
    var scanEnded = false
    
    var crossCheckArray: [Int] = []
    
    var badCheckSum = false
    var tog = true
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var ScannerView: UIImageView!
    @IBOutlet weak var circleView: CircleView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressViewTopLabel: UILabel!
    @IBOutlet weak var progressViewNote: UILabel!
    @IBOutlet weak var scanErrorLabel: UILabel!
    @IBOutlet weak var instructionLable: UILabel!
    
    
    static func route() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "BarCodeScanViewController") as? ScannerViewController else {
            return UIViewController()
        }
        return vc
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View did appear")

            self.progressView.alpha = 0
            self.progressBar.progress = 0
            
            getFrameRate()
            
            if self.fps == 30 {
                
                instructionLable.text = "Press and hold down the Test/Silence button untill the alarm beeps. Release button and position the camera over the red light, hold close enought to fill the green circle. Press the scan button to begin data read"
            } else {
                instructionLable.text = "Press and hold down the Display button untill the alarm beeps. Release button and position the camera over the red light, hold close enought to fill the green circle. Press the scan button to begin data read"
            }
            
            // setup AVCaptureSession IO
        if !self.captureSession.isRunning {
            // run the capture session
            self.captureSession.startRunning()
        }
            
            
            
            
            
            self.FrameCapturCount = 0
            self.counter = 0
            self.seguePerformed = false
            
            self.scanErrorLabel.alpha = 0
            

            
            // setup begining video preview layer
            self.setupPreviewLayer()
            
            if self.scanCount != nil {
                self.ReSetScanExposureSettings()
            }
            
            
            self.packet = Packet()
            
            self.scanEnded = false
            
            self.setupCrossCheckArray()
            
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

         print("View did Load")

        self.progressView.alpha = 0
        self.scanErrorLabel.alpha = 0
        setUpElements()
        self.ConnectIOToCameraSession_BackCamera()
        
    }
    
    func setupCrossCheckArray() {
        for i in 0..<PacketCount  {
            crossCheckArray.append(i+1)
        }
        
    }
    
    func captured(image: UIImage) {

        // print("will this work every frame?")

    }
    
    
    func setUpElements() {
        
        Utilities.styleFilledButton(scanButton)
        
    }
    
    func ConnectIOToCameraSession_BackCamera() {
        
        //Begin capture session configuration
        captureSession.beginConfiguration()
        
        //Select the back camera device for captue session, this device is globaly declared but initialy configured here.
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        //         // print("-------------------------------------------------------------------------------")
        //         // print("videoDevice.videoZoomFactor = \(videoDevice.videoZoomFactor)")
        //         // print("videoDevice.exposureMode = \(videoDevice.exposureMode.rawValue)")
        //         // print("videoDevice.activeFormat = \(videoDevice.activeFormat)")
        //         // print("videoDevice.activeVideoMinFrameDuration = \(videoDevice.activeVideoMinFrameDuration)")
        //         // print("videoDevice.deviceType = \(videoDevice.deviceType)")
        //         // print("videoDevice.minExposureTargetBias = \(videoDevice.minExposureTargetBias)")
        //         // print("videoDevice.activeMaxExposureDuration = \(videoDevice.activeMaxExposureDuration)")
        //         // print("videoDevice.activeMinExposureDuration = \(videoDevice.activeVideoMinFrameDuration)")
        //         // print("videoDevice.debugDescription = \(videoDevice.debugDescription)")
        //         // print("videoDevice.iso = \(videoDevice.iso)")
        //         // print("AVCaptureDevice.DiscoverySession = \(AVCaptureDevice.DiscoverySession.self)")
        //         // print("-------------------------------------------------------------------------------")
        
        //let cameras = AVCaptureDevice.devices(for: AVMediaType.video)
        //         // print("cameras = \(cameras)")
        //
        
        // create a corresponding device input
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoDeviceInput)
        else { fatalError("Error creating back camera device input to capture session") }
        
        // add input device to the camera session
        captureSession.addInput(videoDeviceInput)
        
        // create output
        let videoOutput = AVCaptureVideoDataOutput()
        
        // settings
        videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
        
        videoOutput.alwaysDiscardsLateVideoFrames = false
        
        //Check if output can be added to the capture session, returns bool
        guard captureSession.canAddOutput(videoOutput) else { fatalError("Error adding Video Output to capture session") }
        
        //Set Capture Session Presets - need to experiment with this.
        //        captureSession.sessionPreset = .low
        //        captureSession.sessionPreset = .medium
        //      captureSession.sessionPreset = .high
        //        captureSession.sessionPreset = .photo
        //        captureSession.sessionPreset = .qHD960x540
        //         captureSession.sessionPreset = .hd1920x1080
        //          captureSession.sessionPreset = .hd4K3840x2160
        
        //Add output to the session
        print("min zoom factor = \(videoDevice.minAvailableVideoZoomFactor)")
        print("max zoom factor = \(videoDevice.maxAvailableVideoZoomFactor)")
       // videoDevice.videoZoomFactor = 0.6
        
        //Add output to the session
        captureSession.addOutput(videoOutput)
        
        // commit configuration
        captureSession.commitConfiguration()
        
        //sampleBufferDelegate Queue
        videoOutput.setSampleBufferDelegate(self, queue: FrameCaptureQueue)
    }
    
    
    
    
    //    func captured(image: UIImage) {
    //
    //        self.framecapture = [image]
    //    }
    
    let previewView = PreviewView()
    
    func setupPreviewLayer() {
        
        self.previewView.session = self.captureSession
        self.ScannerView.layer.addSublayer(self.previewView.videoPreviewLayer)
        self.previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewView.videoPreviewLayer.frame = view.layer.bounds
        self.previewView.videoPreviewLayer.frame = self.view.layer.frame

        
                 // print("self.previewView.videoPreviewLayer.frame.width = \(self.previewView.videoPreviewLayer.frame.width)")
                 // print("self.previewView.videoPreviewLayer.frame.height = \(self.previewView.videoPreviewLayer.frame.height)")
        
    }
    
    @IBAction func onPressScan(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        
        SetScanExposureSettings()
        
        self.FrameCapturCount = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startScan = true
        }
        
    }
    
    
    
    
    // MARK: Sample buffer to UIImage conversion
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        let context = CIContext(options: nil)
        //let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
        print("----------FrameDroped \(droppedFrames) ")
//
//                if self.scanEnded != true {
//                    droppedFrames += 1
//
        //        print("----------FrameDroped \(droppedFrames) @ \(self.FrameCapturCount)")
//        //
//                    print("\(sampleBuffer.attachments)")
//             }
//
    }
    
    
    //var bufArray = [CMSampleBuffer?](repeating: buf as! CMSampleBuffer, count: 39)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("FrameCapture \(self.FrameCapturCount)")
        
        //CMSampleBufferCreateCopy
        
        if startScan == true && self.scanEnded == false && self.tog == true
        {
            //            // give a little time for the camera settings to adjust
          //  if self.FrameCapturCount >= 30
          //  {
                //                // this is a small delay to allow the camer configuration to settle
                
                //    CMSampleBufferGetImageBuffer(sampleBuffer)
                guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
                //                    self.packet.rawData[self.FrameCapturCount-30]?.buffer = sampleBuffer
                //let buffer = sampleBuffer
                //                    // create background task for frame image processing
                frameProcessQueue.async { [weak self] in
//                    //self.frameProcesser(uiImage: uiImage)
//                    //                        sampleBufferArray.append(buffer)
                    self?.scannedImageArray.append(uiImage)
//                    //                    self.ibArray.append(CMSampleBufferGetImageBuffer(sampleBuffer)!)
                }
//                DispatchQueue.main.async {
//                                self.scannedImageArray.append(uiImage)
//                            }

                // print("sampleBufferArray.append(sampleBuffer) \(self.FrameCapturCount - 30)")

                //
                //
                //
                if self.FrameCapturCount > (doubleSample) {
                    self.scanEnded = true
                    //
                    DispatchQueue.main.sync { [weak self] in
                        self?.EndFrameProcessor()
                    }
                    
                    frameProcessQueue.sync { [weak self] in
                        //self.frameProcesser(uiImage: uiImage)
                        //                        sampleBufferArray.append(buffer)
                        self!.ScanAnalaysis()
                        //                    self.ibArray.append(CMSampleBufferGetImageBuffer(sampleBuffer)!)
                    }
                    
                    
                    
                    
                }
           // }
            //
//            print("add frame capture count")
            self.FrameCapturCount += 1
            
        }
        
        if self.fps == 30 {
            self.tog = true
        } else {
            self.tog.toggle()
        }

//        print("tog = \(tog)")
    }
    
    func ScanAnalaysis() {
        
        let imageCount = self.scannedImageArray.count
        
        for _ in 0..<imageCount
        {
            if seguePerformed == true {
                self.scannedImageArray.removeAll()
            } else {
                //            frameProcessQueue.sync {
                //guard let uiImage = imageFromSampleBuffer(sampleBuffer: self.sampleBufferArray[i]) else { return }
                
                weak var image = self.scannedImageArray[0]
                
                self.frameProcesser(uiImage: image!)
                
                self.scannedImageArray.remove(at: 0)
                //            }self.scannedImageArray
                
                DispatchQueue.main.async { [unowned self] in
                    
                    //AVCaptureDeviceDiscoverySession var progress = 0
                    var completeFramesCount = 0
                    
                    
                    for i in 0 ..< 39 {
                        
                        if self.packet.rawData[i]?.HexVal != nil {
                            if let index = crossCheckArray.firstIndex(of: (packet.rawData[i]?.packetNum)!) {
                                crossCheckArray.remove(at: index)
                                

                                // print(" -------------------------have packet \(String(describing: self.packet.rawData[i]!.packetNum)) = \(String(describing: self.packet.rawData[i]!.HexVal))")


                                // print(" -------------------------remaining packet count = \(crossCheckArray.count)")

                                
                                completeFramesCount = completeFramesCount + 1

                                // print(" -------------------------completeFramesCount = \(completeFramesCount)")

                            }
                        }
                    }
                    
                    self.progressBar.progress = 1 - (Float(crossCheckArray.count) / 39)

                    // print(" -------------------------self.progressBar.progress = \(self.progressBar.progress)")

                    // if a frame is bad
                    if self.badScan == true {
                        // self.restartScan()
                    }
                    
                    // complete scan
                    if self.progressBar.progress == 1 && self.seguePerformed == false && self.badCheckSum == false{
                        
                        var scanString = ""
                        // build scan string
                        for i in 0..<39 {
                            
                            scanString.append((self.packet.rawData[i]?.HexVal)!)
                            
                        }
                        
                        self.newScan = scanString
                        
                        if self.checkScanCheckSum(str: scanString) {
                            
                            self.seguePerformed = true

                            // print( " CheckSum OK ")
                            self.stopSession()
                            self.performSegue(withIdentifier: "ScanToDeviceReport", sender: self)
                        } else {
                            

                            // print( " Bad CheckSum ")

                            self.badCheckSum = true
                            
                            //TODO Reset the captured array
                            self.resetPacketFrameValues()
                        }
                    }
                    

                    // print( " self.frameProcessCount = \(self.counter) ")

                    
                    // didnt get all the frames, there is something wrong
                    if (self.progressBar.progress < 1 && self.counter == 79) || self.badCheckSum == true {

                        // print( " there is a problem ")

                        
                        self.badScanReset()
                    }
                }
                
                counter += 1
            }
        }
    }
    
    func resetPacketFrameValues() {
        for i in 0 ..< 39 {
            
            self.packet.rawData[i]?.HexVal = nil
            
        }

        // print("Packet has been reset")

    }
    
    
    func badScanReset() {
        self.scanErrorLabel.alpha = 1
        
        self.counter = 0
        
        self.ReSetScanExposureSettings()
        
        self.progressView.alpha = 0
        
        self.setupCrossCheckArray()
        self.FrameCapturCount = 0
        self.scanEnded = false
        self.badCheckSum = false
        self.captureSession.startRunning()
    }
    
    func checkScanCheckSum(str: String) -> Bool {
        
        //MARK:- Check Sum
        let checkSumStartIndex = str.index(str.startIndex, offsetBy: 76)
        let checkSumEndIndex = str.index(str.startIndex, offsetBy: 77)
        let checkSumString = String(str[checkSumStartIndex...checkSumEndIndex])
        let checkSumUInt8 = UInt8(checkSumString, radix: 16)
        

        // print("checkSum String= \(checkSumString)")

        var checkIntTemp: UInt16 = 0
        
        //checksum
        for i in stride(from: 0, to: str.count - 2, by: 2) {
            let byteStartIndex = str.index(str.startIndex, offsetBy: i)
            let byteEndIndex = str.index(str.startIndex, offsetBy: i+1)
            
            let byteString = String(str[byteStartIndex...byteEndIndex])
            let byteInt = UInt16(byteString, radix: 16)
            

            // print("Check sum value = \(checkIntTemp) + \(byteInt!) = \((checkIntTemp + byteInt!))")

            checkIntTemp = (checkIntTemp + byteInt!)// & 0x00FF
        }
        
        checkIntTemp = (checkIntTemp & 0x00FF)
        
        if UInt8(checkIntTemp) == checkSumUInt8 {
            

            // print("Good Check Sum")

            return true
        } else {
            return false
        }
        
    }
    
    
    func EndFrameProcessor() {

        // print("captureOutput:  end of scan")

        self.startScan = false
        self.FrameCapturCount = 0
        self.progressView.alpha = 1
        self.ReSetScanExposureSettings()
        
        self.captureSession.stopRunning()
       
    }
    
    
    func frameProcesser(uiImage: UIImage) {
        
        var frame: Frame?
        
        frame = self.ProcessImage(uiImage: uiImage)
        // the above function will return a manchester decoded string or "Corrupt Scan Data" if the frame failed
        
        if frame?.HexVal == "Corrupt Scan Data" {

            // print("Corrupt frame: \(counter) = \(String(describing: frame?.str))")

        } else {
            

            // print("frame.packetNum \(String(describing: frame?.packetNum))")

            

            // print("frame.HexVal \(String(describing: frame?.HexVal))")

            
            
            //self.packet.rawData[frame.packetNum]?.HexVal
            if (frame?.packetNum!)! <= 39 {

                // print("frame?.packetNum! = \(String(describing: frame?.packetNum!))")

                
                if packet.rawData[(frame?.packetNum!)!-1]?.HexVal == nil {
                    packet.rawData[(frame?.packetNum!)!-1] = frame
                } else {

                    // print("packet exisits already")

                }
            }
        }
        
        //frame = nil
        
        
    }
    
    func SetScanExposureSettings() {
        

        // print("SetScanExposureSettings()")

        
        do{
            try videoDevice.lockForConfiguration()
        } catch {
            self.scanErrorLabel.alpha = 1
            self.scanErrorLabel.text = "error accessing camera"
        }
        
        // print("Device.version() = \(Device.version())")

        
        //TODO:- might need to find the right video format for each phone. maybe the simulator can do this?
        //        captureSession.sessionPreset = .low
        //        captureSession.sessionPreset = .medium
        //      captureSession.sessionPreset = .high
        //captureSession.sessionPreset = .photo
        //        captureSession.sessionPreset = .qHD960x540
        
        
        if self.fps == 30 {
            captureSession.sessionPreset = .hd1920x1080
        } else {
            captureSession.sessionPreset = .hd4K3840x2160
        }
        
        if setVideoFormat(fps: self.fps) {

            // print("frame rate set ok")

            // print("videoDevice.activeFormat = \(videoDevice.activeFormat)")

        } else {

            // print("Error setting frame rate")

        }
        
        let exposureTime = CMTimeGetSeconds(self.videoDevice.activeFormat.minExposureDuration)
        

        // print("exposureTime = \(exposureTime)")

        
        let duration = CMTime.init(seconds: exposureTime, preferredTimescale: 1_000_000)

        // print("duration = \(duration)")

        
        videoDevice.setExposureModeCustom(duration: duration, iso: 100, completionHandler: nil )
        
        videoDevice.videoZoomFactor = 1.0
        
        // videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
        
        videoDevice.automaticallyAdjustsVideoHDREnabled = false
        
        //        var formats = videoDevice.formats
        //
        //         // print("videoDevice.activeFormat = \(videoDevice.activeFormat)")
        //
        //
        //        for i in 0..<formats.count {
        //             // print("videoDevice.formats[\(i)] = \(formats[i])")
        //        }
        
        
        //         // print("videoDevice.activeformats = \(videoDevice.activeFormat)")
        //         // print("videoDevice.activeVideoMaxFrameDuration = \(videoDevice.activeVideoMaxFrameDuration)")
        //         // print("videoDevice.activeVideoMinFrameDuration = \(videoDevice.activeVideoMinFrameDuration)")
        //         // print("videoDevice.activeMaxExposureDuration = \(videoDevice.activeMaxExposureDuration)")
        //         // print("videoDevice.exposureMode = \(videoDevice.exposureMode.rawValue)")
        //         // print("videoDevice.isAdjustingExposure = \(videoDevice.isAdjustingExposure)")
        //         // print("videoDevice.exposureDuration = \(videoDevice.exposureDuration)")
        //         // print("videoDevice.activeDepthDataMinFrameDuration = \(videoDevice.activeDepthDataMinFrameDuration)")
        //
        //         // print("----------------  Exposure -----------------")
        //         // print("videoDevice.isAdjustingExposure = \(videoDevice.isAdjustingExposure)")
        //         // print("videoDevice.minExposureTargetBias = \(videoDevice.minExposureTargetBias)")
        //         // print("videoDevice.maxExposureTargetBias = \(videoDevice.maxExposureTargetBias)")
        //         // print("videoDevice.modelID = \(videoDevice.modelID)")
        //         // print("videoDevice.iso = \(videoDevice.iso)")
        //
        //         // print("videoDevice.activeDepthDataMinFrameDuration = \(videoDevice.activeDepthDataMinFrameDuration)")
        //         // print("videoDevice.activeDepthDataMinFrameDuration = \(videoDevice.activeDepthDataMinFrameDuration)")
    }
    
    func getFrameRate() {
        
        switch Device.version() {
        case .iPhone6:
            self.fps = 30
        case .iPhone6Plus:
            self.fps = 30
        case .iPhone6S:
            self.fps = 30
        case .iPhone6SPlus:
            self.fps = 30
        case .iPhone7:
            self.fps = 30
        case .iPhone7Plus:
            self.fps = 30
        case .iPhone8:
            self.fps = 30
        case .iPhoneX:
            self.fps = 30
        case .iPhoneXS:
            self.fps = 30
        case .iPhoneXS_Max:
            self.fps = 30
        case .iPhone11:
            self.fps = 60
        default:
            self.fps = 60
        }
    }
    
    func setVideoFormat(fps: Double) -> Bool {
        
        for vFormat in videoDevice.formats {
            
            // 2
            let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
            let frameRates = ranges[0]
            
            //AVCaptureDeviceDiscoverySession vFormat.mediaType.rawValue
            
            if frameRates.maxFrameRate >= fps {
                let dimensions = CMVideoFormatDescriptionGetDimensions(vFormat.formatDescription)
                // // print("dimensions = \(dimensions)")
                
                switch fps {
                case 30:
                    if dimensions.width == 1920 && dimensions.height == 1080 {

                        // print("i found format")
                        
                        videoDevice.activeFormat = vFormat as AVCaptureDevice.Format
                        videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(fps))
                        videoDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(fps))

                        // print("videoDevice.activeFormat = \(videoDevice.activeFormat)")

                        return true
                    }
                case 60:
                    if dimensions.width > 1920 && dimensions.height > 1080 { //3840 2160

                        // print("i found format")

                        videoDevice.activeFormat = vFormat as AVCaptureDevice.Format
                        videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(fps))
                        videoDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(fps))

                        // print("videoDevice.activeFormat = \(videoDevice.activeFormat)")

                        return true
                    }
                default:

                    print("no available format")
                    
                }
                
            }
            
            
        }
        
        
        
        return false
    }
    
    func ReSetScanExposureSettings() {
        
        // print("SetScanExposureSettings()")
        
        do{
            try videoDevice.lockForConfiguration()

            // print("try ok")

        } catch {

            // print("error setting camera")

        }
        
        videoDevice.exposureMode = .continuousAutoExposure
    }
    
    //MARK:- Camera Session
    func startSession() {
    
        if !captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
        
    }
    
    func ProcessFrame(_ uiImage: UIImage) -> Frame {
        
        //getImageFromSampleBuffer(buffer: sampleBuffer)
        var string = ""
        var f = Frame()
        
        f = ProcessImage(uiImage: uiImage)
        string = f.HexVal!
        
        if string == "Corrupt Scan Data" {
            
            corruptFrameCounter += 1
            
        } else {
            
        }
        
        return f
    }
    
    func ProcessImage(uiImage: UIImage) -> Frame {
        
        var outputFrame = Frame()
        

        // print("ProcessImage")

        
        
        
        if self.fps == 30 {

            // print("test2")

            let imageMaster = ScannerFunctions30FPS(uiImage: uiImage)

            // print("test2")

            if imageMaster.binaryString.isEmpty || imageMaster.byteData == nil || imageMaster.byteNum == nil {
                
                outputFrame.HexVal = "Corrupt Scan Data"
                
                
                // bad scan ned to restart
                self.badScan = true
                //self.ImageMaster = nil
                
                return outputFrame
                
            } else {
                
                outputFrame.rawBinaryString = imageMaster.binaryString
                outputFrame.HexVal = imageMaster.byteData
                outputFrame.packetNum = Int(imageMaster.byteNum!)
                
                //outputFrame.outputImage = imageMaster.outImage[0]
                //self.ImageMaster = nil
                return outputFrame
            }
            
        } else if self.fps == 60 {
            
            let imageMaster = ScannerFunctions60FPS(inImage: uiImage)
            
            if imageMaster.binaryString.isEmpty || imageMaster.byteData == nil || imageMaster.byteNum == nil {
                
                outputFrame.HexVal = "Corrupt Scan Data"
                
                
                // bad scan ned to restart
                self.badScan = true
                //self.ImageMaster = nil
                
                return outputFrame
                
            } else {
                
                outputFrame.rawBinaryString = imageMaster.binaryString
                outputFrame.HexVal = imageMaster.byteData
                outputFrame.packetNum = Int(imageMaster.byteNum!)
                
                //outputFrame.outputImage = imageMaster.outImage[0]
                //self.ImageMaster = nil
                return outputFrame
            }
        } else {
            return outputFrame
        }
        
        // let imageMaster = ScanningFunctions3(uiImage: uiImage)
        // self.scannedImageArray.append((self.ImageMaster?.outImage[1])!)
        
        
        
        
        
        
    }
    
    
    func getImageFromSampleBuffer (buffer: CMSampleBuffer) -> UIImage? {

        // print("getImageFromSampleBuffer")

        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
        
        return nil
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let deviceReportVC = segue.destination as! DeviceReportViewController
        
        deviceReportVC.newScan = self.newScan
        deviceReportVC.propertyDetails = self.newPropertyDetails
        deviceReportVC.scanCount = self.scanCount
        
        //TODO:- get rid of this when everything is tested ok
        deviceReportVC.packet = self.packet
    }
    
    
    //    func checkScan() -> Bool {
    //
    //        var sum: UInt16 = 0
    //
    //        let ckSumStrStartIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: SCAN_LENGTH-2)
    //        let ckSumStrEndIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: SCAN_LENGTH-1)
    //        //let ckSumStr = String(self.newScan![ckSumStrStartIndex...ckSumStrEndIndex])
    //        //let ckSum = Int(ckSumStr)
    //
    //        for i in stride(from: 0, to: SCAN_LENGTH, by: 2) {
    //
    //            //MARK:- SerialNumber
    //            let newValStrStartIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: i)
    //            let newValStrEndIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: i+1)
    //            let newValStr = String(self.newScan![newValStrStartIndex...newValStrEndIndex])
    //
    //            let newValInt = Int(newValStr, radix: 16)
    //
    //            sum += UInt16(newValInt!)
    //            sum = sum & 0x00FF
    //
    //        }
    //
    //         // print ("checksume pass")
    //        return true
    //    }
    
    @IBAction func unwindToScannerViewController(_ sender: UIStoryboardSegue) {}
    
    @IBAction func supportPressed(_ sender: Any) {
        
        // if support button pressed send an email with decive info
        composeEmail()
    }
    
    func composeEmail() {
        
        // build title page
        composeCameraDataPagePDF()
        
        //self.pdfDocument
        showMailComposer()
    }
    
    func composeCameraDataPagePDF() {
        
        //let pdfTitle = "Debug Report"
        
        var frameInfoString = ""
        
        for i in 0 ..< fraemInfoArray.count {
            frameInfoString.append("iso\(i) = \(fraemInfoArray[i].Iso), width\(i) = \(fraemInfoArray[i].width), height\(i) = \(fraemInfoArray[i].height)\n")
        }
        
        let pdfBody = """
                    
                    ios version = \(UIDevice.current.systemVersion)
                    version = \(Device.version())
                    size = \(Device.size())
                    type = \(Device.type())
                    
                    videoDevice.videoZoomFactor = \(videoDevice.videoZoomFactor)
                    videoDevice.exposureMode = \(videoDevice.exposureMode)
                    videoDevice.isAdjustingExposure = \(videoDevice.isAdjustingExposure)
                    videoDevice.maxAvailableVideoZoomFactor = \(videoDevice.maxAvailableVideoZoomFactor)
                    videoDevice.minAvailableVideoZoomFactor = \(videoDevice.minAvailableVideoZoomFactor)
                    
                    captureSession.sessionPreset = \(captureSession.sessionPreset)
                    captureSession.inputs = \(captureSession.inputs)
                    captureSession.connections = \(captureSession.connections)
                    
                    
                    frame data:
                    \(frameInfoString)
                    """
        
        
        let pdfCreator = PDFDebugCreator(title: "Debug Report", body: pdfBody)
        
        let data = pdfCreator.createPDFReport()
        
        self.pdfDebugDoc = PDFDocument(data: data)
        
    }
    
    func showMailComposer() {
        

        // print("creating Email")

        
        guard MFMailComposeViewController.canSendMail() else {
            // TODO:- Show alert informing the user

            // print("Mail services are not available")

            return
        }
        
        // send email of PDF
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([""])
        composeVC.setSubject("Firehawk Service Report")
        composeVC.setMessageBody("", isHTML: true)
        
        //Attach pdf
        composeVC.addAttachmentData(self.pdfDebugDoc.dataRepresentation()! as Data, mimeType: "pdf" , fileName: "DebugReport.pdf")
        
        self.present(composeVC, animated: true, completion: nil)
    }
}


extension ScannerViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            //Show error alert
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:

             print("Cancelled")

        case .failed:

             print("Failed to send")

        case .saved:

             print("Saved")

        case .sent:

             print("Email Sent")

        @unknown default:
            break
        }
        
        controller.dismiss(animated: true)
    }
    
    func dateFormat(date: Date) -> String {
        
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short//"dd/mm/yyyy"
        
        
        let str = formatter1.string(from: date)
        return str
    }
}


class PreviewView: UIView {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}


public enum DeviceType {
    case iPad(String?)
    case iPhone(String?)
    case simulator(String?)
    case appleTV(String?)
    case unknown
}

extension UIDevice {
    public static func getDevice() -> DeviceType {
        var info = utsname()
        uname(&info)
        let machineMirror = Mirror(reflecting: info.machine)
        let code = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        if code.lowercased().range(of: "ipad") != nil {
            if let range = code.lowercased().range(of: "ipad") {
                var mutate = code
                mutate.removeSubrange(range)
                return .iPad(mutate)
            }else{
                return .iPad(nil)
            }
        }else if code.lowercased().range(of: "iphone") != nil {
            if let range = code.lowercased().range(of: "iphone") {
                var mutate = code
                mutate.removeSubrange(range)
                return .iPhone(mutate)
            }else{
                return .iPhone(nil)
            }
        }else if code.lowercased().range(of: "i386") != nil || code.lowercased().range(of: "x86_64") != nil{
            return .simulator(code)
        }else if code.lowercased().range(of: "appletv") != nil {
            if let range = code.lowercased().range(of: "appletv") {
                var mutate = code
                mutate.removeSubrange(range)
                return .appleTV(mutate)
            }else{
                return .appleTV(nil)
            }
        }else{
            return .unknown
        }
    }
}
