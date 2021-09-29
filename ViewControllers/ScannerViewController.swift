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
    
    var pdfDebugDoc: PDFDocument!
    
    var fraemInfoArray: [FrameSettings] = []

    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var ScannerView: UIImageView!
    @IBOutlet weak var circleView: CircleView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressViewTopLabel: UILabel!
    @IBOutlet weak var progressViewNote: UILabel!
    @IBOutlet weak var scanErrorLabel: UILabel!
    
    
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
        
        self.scanErrorLabel.alpha = 1
        
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
        self.scanErrorLabel.alpha = 0
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

//        print("-------------------------------------------------------------------------------")
//        print("videoDevice.videoZoomFactor = \(videoDevice.videoZoomFactor)")
//        print("videoDevice.exposureMode = \(videoDevice.exposureMode.rawValue)")
//        print("videoDevice.activeFormat = \(videoDevice.activeFormat)")
//        print("videoDevice.activeVideoMinFrameDuration = \(videoDevice.activeVideoMinFrameDuration)")
//        print("videoDevice.deviceType = \(videoDevice.deviceType)")
//        print("videoDevice.minExposureTargetBias = \(videoDevice.minExposureTargetBias)")
//        print("videoDevice.activeMaxExposureDuration = \(videoDevice.activeMaxExposureDuration)")
//        print("videoDevice.activeMinExposureDuration = \(videoDevice.activeVideoMinFrameDuration)")
//        print("videoDevice.debugDescription = \(videoDevice.debugDescription)")
//        print("videoDevice.iso = \(videoDevice.iso)")
//        print("AVCaptureDevice.DiscoverySession = \(AVCaptureDevice.DiscoverySession.self)")
//        print("-------------------------------------------------------------------------------")
        
        let cameras = AVCaptureDevice.devices(for: AVMediaType.video)
        print("cameras = \(cameras)")
        

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
        captureSession.sessionPreset = .hd1920x1080
        
        
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
        
//        print("self.previewView.videoPreviewLayer.frame.width = \(self.previewView.videoPreviewLayer.frame.width)")
//        print("self.previewView.videoPreviewLayer.frame.height = \(self.previewView.videoPreviewLayer.frame.height)")
        
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
                    
//                    print("uiImage.size.width = \(uiImage.size.width)")
//                    print("uiImage.size.height = \(uiImage.size.height)")
//                    print("output = \(output.connections)")
//
//                    print("videoDevice.iso = \(videoDevice.iso)")
//                    print("videoDevice.exposureDuration = \(videoDevice.exposureDuration)")
//
//                    print("sampleBuffer.formatDescription = \(sampleBuffer.formatDescription)")
//                    print("sampleBuffer.duration = \(sampleBuffer.duration)")
                    
                    //var frameInfo = FrameSettings(Iso: Int(videoDevice.iso), width: Int(uiImage.size.width), height: Int(uiImage.size.height), image: uiImage)
       

                    //fraemInfoArray.append(frameInfo)
                    
                    
                    // create background task for frame image processing
                    
                    frameProcessQueue.async { [unowned self] in
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
        self.FrameCapturCount = 0
        self.ReSetScanExposureSettings()
        
    }
    
    func frameProcesser(uiImage: UIImage) {
        
        var frame: Frame?
            
            frame = self.ProcessImage(uiImage: uiImage)
        // the above function will return a manchester decoded string or "Corrupt Scan Data" if the frame failed
        
        if frame?.HexVal == "Corrupt Scan Data" {
            print("Corrupt frame: \(counter) = \(frame?.str)")
            
        } else {
            
            print("frame.packetNum \(frame?.packetNum)")
            print("frame.HexVal \(frame?.HexVal)")

            //self.packet.rawData[frame.packetNum]?.HexVal
            if (frame?.packetNum!)! <= 38 {
                if packet.rawData[(frame?.packetNum!)!-1]?.HexVal == nil {
                    packet.rawData[(frame?.packetNum!)!-1] = frame
                } else {
                  //  print("packet exisits already")
                }
            }
        }
        
      frame = nil
            
        DispatchQueue.main.async {
            
            var progress = 0
            var completeFramesCount = 0
            
            
            for i in 0 ..< 38 {
                if self.packet.rawData[i]?.HexVal != nil {
                    completeFramesCount = completeFramesCount + 1
//                    print(" -------------------------completed frames  \(i) = \(self.packet.rawData[i]?.HexVal)")
//                    print(" -------------------------completeFramesCount = \(completeFramesCount)")
                }
            }
            
            self.progressBar.progress = (Float(completeFramesCount) / 38)
//            print(" -------------------------self.progressBar.progress = \(self.progressBar.progress)")
            
            // if a frame is bad
            if self.badScan == true {
               // self.restartScan()
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
            
//            print( " self.frameProcessCount = \(self.counter) ")
            
            // didnt get all the frames, there is something wrong
            if self.progressBar.progress < 1 && self.counter == 40 {
                print( " there is a problem ")
               
                self.scanErrorLabel.alpha = 1
                
                self.counter = 0
                
                self.ReSetScanExposureSettings()
                
                self.progressView.alpha = 0
            }
        }
        
        counter += 1
    }
    
    func SetScanExposureSettings() {
        
        print("SetScanExposureSettings()")
        
        do{
            try videoDevice.lockForConfiguration()
        } catch {
            self.scanErrorLabel.alpha = 1
            self.scanErrorLabel.text = "error accessing camera"
        }
        
        let exposureTime = CMTimeGetSeconds(self.videoDevice.activeFormat.minExposureDuration)
        
        print("exposureTime = \(exposureTime)")
        
        let duration = CMTime.init(seconds: exposureTime, preferredTimescale: 1_000_000)
        print("duration = \(duration)")
       
//        let durationX2 = CMTime.init(seconds: (exposureTime * 2), preferredTimescale: 1_000_000)
//        let durationX4 = CMTime.init(seconds: (exposureTime * 4), preferredTimescale: 1_000_000)
        
        try videoDevice.setExposureModeCustom(duration: duration, iso: 200, completionHandler: nil )
        
        videoDevice.videoZoomFactor = 1.0
        
       // videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
        
        videoDevice.automaticallyAdjustsVideoHDREnabled = false
        
//        var formats = videoDevice.formats
//        
//        print("videoDevice.activeFormat = \(videoDevice.activeFormat)")
//        
//        for i in 0..<formats.count {
//            print("videoDevice.formats[\(i)] = \(formats[i])")
//        }
//        
//        
//        videoDevice.activeFormat = formats[44]
        
        
   //     videoDevice.activeDepthDataFormat
   //     videoDevice.activeDepthDataMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
        //print("videoDevice.formats = \(videoDevice.formats)")
//        print("videoDevice.activeVideoMaxFrameDuration = \(videoDevice.activeVideoMaxFrameDuration)")
//        print("videoDevice.activeVideoMinFrameDuration = \(videoDevice.activeVideoMinFrameDuration)")
//        print("videoDevice.activeMaxExposureDuration = \(videoDevice.activeMaxExposureDuration)")
//        print("videoDevice.exposureMode = \(videoDevice.exposureMode.rawValue)")
//        print("videoDevice.isAdjustingExposure = \(videoDevice.isAdjustingExposure)")
//        print("videoDevice.exposureDuration = \(videoDevice.exposureDuration)")
//        print("videoDevice.activeDepthDataMinFrameDuration = \(videoDevice.activeDepthDataMinFrameDuration)")
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
            
            
            // bad scan ned to restart
            self.badScan = true
            self.ImageMaster = nil
            
            return outputFrame
            
        }else{
            
            outputFrame.rawBinaryString = ImageMaster!.binaryString
            outputFrame.HexVal = ImageMaster!.byteData
            outputFrame.packetNum = Int(ImageMaster!.byteNum!)
            
            
            self.ImageMaster = nil
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
        
        let pdfTitle = "Debug Report"
        
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
        
        print("creating Email")
        
        guard MFMailComposeViewController.canSendMail() else {
            // TODO:- Show alert informing the user
            print("Mail services are not available")
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
