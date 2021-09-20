//
//  BarCodeScanViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit
import AVFoundation


class ScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
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
    
    let frameProcessQueue = DispatchQueue(label: "frameProcessQueue", qos: .utility)
    let FrameCaptureQueue = DispatchQueue(label: "FrameCaptureQueue")
    var seguePerformed = false
    var completeFrames = 0
    
    var counter = 0
    var corruptFrameCounter = 0
    var badManchester = 0
    
    var droppedFrames = 0
    
    var ImageMaster: ScanningFunctions2?
    let packetCount = 7
    var badScan = false
    

    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var ScannerView: UIImageView!
    @IBOutlet weak var circleView: CircleView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressViewTopLabel: UILabel!
    @IBOutlet weak var progressViewNote: UILabel!
    
    
    static func route() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "BarCodeScanViewController") as? ScannerViewController else {
            return UIViewController()
        }
        return vc
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.progressView.alpha = 0
        
        print("View did appear")
    //    ConnectIOToCameraSession_BackCamera()
        
        self.FrameCapturCount = 0
        self.counter = 0
        self.seguePerformed = false
        // run the capture session
        captureSession.startRunning()
        
        // setup begining video preview layer
        setupPreviewLayer()
        
        if scanCount != nil {
            ReSetScanExposureSettings()
        }
        
        self.packet = Packet()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did Load")
        self.progressView.alpha = 0
        
        setUpElements()
        
        
        // setup AVCaptureSession IO
        self.ConnectIOToCameraSession_BackCamera()
        
        
    }
    
    

    func setUpElements() {
        
        Utilities.styleFilledButton(scanButton)
        
    }
    
    func ConnectIOToCameraSession_BackCamera() {
        
        //Begin capture session configuration
        captureSession.beginConfiguration()
        
        //Select the back camera device for captue session, this device is globaly declared but initialy configured here.
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)

        
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
        videoOutput.videoSettings = [:]
        videoOutput.alwaysDiscardsLateVideoFrames = false
        
        //Check if output can be added to the capture session, returns bool
        guard captureSession.canAddOutput(videoOutput) else { fatalError("Error adding Video Output to capture session") }
        
        //Set Capture Session Presets - need to experiment with this.
        captureSession.sessionPreset = .high
        
        //Add output to the session
        captureSession.addOutput(videoOutput)
        
        // commit configuration
        captureSession.commitConfiguration()
        
        // sampleBufferDelegate Queue
        videoOutput.setSampleBufferDelegate(self, queue: FrameCaptureQueue)
    }
    

    
    
    func captured(image: UIImage) {
        
        self.framecapture = [image]
    }
    
    let previewView = PreviewView()
    
    func setupPreviewLayer() {
        
        self.previewView.session = self.captureSession
        self.ScannerView.layer.addSublayer(self.previewView.videoPreviewLayer)
        self.previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewView.videoPreviewLayer.frame = view.layer.bounds
        self.previewView.videoPreviewLayer.frame = self.view.layer.frame
        
    }
    
    @IBAction func onPressScan(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        
        self.startScan = true
        SetScanExposureSettings()
    }
    

    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("FrameDroped wtf")
        droppedFrames += 1
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
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if startScan == true && self.FrameCapturCount < 61
        {
            // give a little time for the camera settings to adjust
            if self.FrameCapturCount > 10
            {
                // this is a small delay to allow the camer configuration to settle
                if (self.FrameCapturCount < 51) // || (self.completeFrames < 27) // TODO:- set up data complete frame here.
                {
                    guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
                    
//                    frameProcessQueue.async {
//                        self.frameProcesser(uiImage: uiImage)
//
//                    }
                    DispatchQueue.main.async {
                        self.frameProcesser(uiImage: uiImage)
                        
                    }
                    
                }else {
                    
                    print("self.FrameCapturCount = \(self.FrameCapturCount)")
                    EndFrameProcessor()
                    self.FrameCapturCount = 0
                    
                    DispatchQueue.main.async {
                        self.progressView.alpha = 1
                    }
                   
                    
                }
            }
            
            self.FrameCapturCount += 1
            

        }
     
    }
    
    func EndFrameProcessor() {
        print("captureOutput:  end of scan")
        
        self.startScan = false
        
        //self.SetScanExposureSettings()
        
        self.FrameCapturCount = 0
        
       // self.stopCaptureSession()
        self.ReSetScanExposureSettings()
        
    }
    
    func frameProcesser(uiImage: UIImage) {
        
        let frame = self.ProcessImage(uiImage: uiImage)
        // the above function will return a manchester decoded string or "Corrupt Scan Data" if the frame failed
        
        if frame.HexVal == "Corrupt Scan Data" {
            print("Corrupt frame: \(counter) = \(frame.str)")
            
        } else {
            
            print("frame.packetNum \(frame.packetNum)")
            print("frame.HexVal \(frame.HexVal)")

            //self.packet.rawData[frame.packetNum]?.HexVal
            if frame.packetNum! <= 38 {
                if packet.rawData[frame.packetNum!-1]?.HexVal == nil {
                    packet.rawData[frame.packetNum!-1] = frame
                } else {
                    print("packet exisits already")
                }
            }
        }
        
      
            
        DispatchQueue.main.async {
            
            var progress = 0
            var completeFramesCount = 0
            
            
            for i in 0 ..< 38 {
                if self.packet.rawData[i]?.HexVal != nil {
                    completeFramesCount = completeFramesCount + 1
                    print(" -------------------------completed frames  \(i) = \(self.packet.rawData[i]?.HexVal)")
                    print(" -------------------------completeFramesCount = \(completeFramesCount)")
                }
            }
            
            self.progressBar.progress = (Float(completeFramesCount) / 38)
            print(" -------------------------self.progressBar.progress = \(self.progressBar.progress)")
            
            // if a frame is bad
            if self.badScan == true {
                self.restartScan()
            }
            
            // complete scan
            if self.progressBar.progress == 1 && self.seguePerformed == false {
                
                var scanString = ""
                // build scan string
                for i in 0..<38 {
                    
                    scanString.append((self.packet.rawData[i]?.HexVal)!)
                    
                }
                
                self.newScan = scanString
                
                self.seguePerformed = true
                
                self.performSegue(withIdentifier: "ScanToDeviceReport", sender: self)
                
            }
            
            print( " self.frameProcessCount = \(self.counter) ")
            
            if self.progressBar.progress < 1 && self.counter == 40 {
                print( " there is a problem ")
                
           //     self.progressViewTopLabel.text = "Error"
            //    self.progressViewTopLabel.textColor = .red
                
           //     self.progressViewNote.text = "There was a error during the scan please retry"
           //     self.progressViewNote.textColor = .red
                
                self.counter = 0
                
                self.ReSetScanExposureSettings()
                
                self.progressView.alpha = 0
            }
        }
        
        counter += 1
    }
    
    
    func checkProgress() {
        
    }
    
    
    func restartScan() {
        
    }
    
    func SetScanExposureSettings() {
        
        print("SetScanExposureSettings()")
        
        do{
            try videoDevice.lockForConfiguration()
            print("try ok")
        } catch {
            print("error setting camera")
        }
        
        print("set Scan exposure")
        let exposureTime = CMTimeGetSeconds(self.videoDevice.activeFormat.minExposureDuration)
        videoDevice.setExposureModeCustom(duration:  CMTime.init(seconds: exposureTime, preferredTimescale: 1_000_000), iso: 150, completionHandler: nil )
        
    }
    
    
    func ReSetScanExposureSettings() {
        
        print("SetScanExposureSettings()")
        
        do{
            try videoDevice.lockForConfiguration()
            print("try ok")
        } catch {
            print("error setting camera")
        }
        
        videoDevice.exposureMode = .continuousAutoExposure
    }
    
    func printDate() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSS"
        print("time frame recieved = ", formatter.string(from: date))
    }
    
    func printDateEnd() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSS"
        print("time frame processing ended = ", formatter.string(from: date))
    }
    
    func stopCaptureSession() {
        
        print("stopCaptureSession")
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
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
        
        print("ProcessImage")
        
        self.ImageMaster = ScanningFunctions2(uiImage: uiImage)
        
       // self.scannedImageArray.append((self.ImageMaster?.outImage[1])!)
        if ImageMaster!.binaryString.isEmpty || ImageMaster!.byteData == nil || ImageMaster!.byteNum == nil {
            
            outputFrame.HexVal = "Corrupt Scan Data"
            return outputFrame
            
            // bad scan ned to restart
            self.badScan = true
            
        }else{
            
            outputFrame.rawBinaryString = ImageMaster!.binaryString
            outputFrame.HexVal = ImageMaster!.byteData
            outputFrame.packetNum = Int(ImageMaster!.byteNum!)
            
            return outputFrame
        }
    }
    
    
    func getImageFromSampleBuffer (buffer: CMSampleBuffer) -> UIImage? {
        print("getImageFromSampleBuffer")
        
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
    }
    
    
    func checkScan() -> Bool {
        
        var sum: UInt16 = 0
        
        let ckSumStrStartIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: SCAN_LENGTH-2)
        let ckSumStrEndIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: SCAN_LENGTH-1)
        let ckSumStr = String(self.newScan![ckSumStrStartIndex...ckSumStrEndIndex])
        let ckSum = Int(ckSumStr)
        
        for i in stride(from: 0, to: SCAN_LENGTH, by: 2) {
            
            //MARK:- SerialNumber
            let newValStrStartIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: i)
            let newValStrEndIndex = self.newScan!.index(self.newScan!.startIndex, offsetBy: i+1)
            let newValStr = String(self.newScan![newValStrStartIndex...newValStrEndIndex])
            
            var newValInt = Int(newValStr, radix: 16)
            
            sum += UInt16(newValInt!)
            sum = sum & 0x00FF
            
        }
        
        print ("checksume pass")
        return true
    }
    
    @IBAction func unwindToScannerViewController(_ sender: UIStoryboardSegue) {}
    
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

