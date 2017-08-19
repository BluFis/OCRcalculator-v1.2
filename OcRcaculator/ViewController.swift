//
//  ViewController.swift
//  OcRcaculator
//
//  Created by Apple on 2017/8/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import SwiftOCR
import AVFoundation


extension UIImage {
    func detectOrientationDegree () -> CGFloat {
        switch imageOrientation {
        case .right, .rightMirrored:    return 90
        case .left, .leftMirrored:      return -90
        case .up, .upMirrored:          return 180
        case .down, .downMirrored:      return 0
        }
    }
}


class ViewController: UIViewController{
    @IBOutlet weak var addBtn: mathButton!
    // MARK: - Outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var viewFinder: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    @IBOutlet weak var memoryDisplay: UILabel!
    @IBOutlet weak var scanView: UIView!
    

    @IBOutlet weak var resetBtn: mathButton!
    
    @IBOutlet weak var AutoBtn: Button!
    @IBOutlet weak var recogBtn: Button!
    @IBOutlet weak var animateLabel: UILabel!
    var timer:Timer!
    var isAuto:Bool = false
    var doubleAdmit = DoubleAdmit()
    let decimalSeparator = NumberFormatter().decimalSeparator!
    var caculator = CalculatorBrain()
    var ocrInstance = SwiftOCR()
    @IBOutlet weak var detailBtn: UIButton!
    @IBOutlet weak var decimalSeparatorButton: UIButton!
    var userIsInTheMiddleOfTyping = false
    fileprivate var stillImageOutput: AVCaptureStillImageOutput!
    fileprivate let captureSession = AVCaptureSession()
    fileprivate let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    var displayValue: Double {
        get {
            return (NumberFormatter().number(from: label.text!)?.doubleValue)!
        }
        set {
            
                label.text = String(newValue).beautifyNumbers()
            
            
        }
    }
    var variables = Dictionary<String,Double>() {
        didSet {
            memoryDisplay.text = variables.flatMap{$0+":\($1)"}.joined(separator: ", ").beautifyNumbers()
        }
    }
    // MARK: - View LifeCycle  

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    adjustButtonLayout(for: view, isPortrait: newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .regular)
}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // start camera init
        DispatchQueue.global(qos: .userInitiated).async {
            if self.device != nil {
                self.configureCameraForUse()
            }
        }
        adjustButtonLayout(for: view, isPortrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular)
        decimalSeparatorButton.setTitle(decimalSeparator, for: .normal);
        
        caculator.addUnaryOperation(named: "✅", { [unowned self] (operand) -> Double in
            self.label.textColor = UIColor.green
            return sqrt(operand)
        }) { "√(" + $0 + ")" }
       
        try! device?.lockForConfiguration()
        device?.focusMode = .continuousAutoFocus
        device?.unlockForConfiguration()
    }
    
    // MARK: - IBActions
    
    
    @IBAction func lightControl(_ sender: Button) {
 
        if !isAuto{
        
        UIView.animate(withDuration: 1.2, delay: 0,  options: .repeat, animations: {
            self.scanView.alpha = 1
             self.scanView.layer.frame = CGRect(x: self.scanView.layer.frame.origin.x, y: self.cameraView.layer.frame.maxY, width: self.scanView.layer.frame.width, height: self.scanView.layer.frame.height)
            DispatchQueue.main.async {
               
                self.timer = Timer.scheduledTimer(timeInterval: 3.2,target:self,selector:#selector(self.animate),userInfo:nil,repeats:true)
                
            }
        })
          isAuto = true
        self.AutoBtn.setTitle("暂停", for: .normal)
        }else{
            self.scanView.alpha = 0
            timer.invalidate()
            isAuto = false
            self.AutoBtn.setTitle("自动",for:.normal)
      
        }

    }
    
    
    
    
    
    @IBAction func cameraControl(_ sender: Any) {
        
        self.captureSession.isRunning == true ? self.captureSession.stopRunning() : self.captureSession.startRunning()
        
        
    }
    
    
    
    
    @IBAction func storeToMemory(_ sender: UIButton) {
        variables["M"] = displayValue
        userIsInTheMiddleOfTyping = false
        displayResult()
    }
    
    @IBAction func callMemory(_ sender: UIButton) {
        caculator.setOperand(variable: "M")
        userIsInTheMiddleOfTyping = false
        displayResult()
    }

   
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            caculator.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
           caculator.performOperation(mathematicalSymbol)
        }
        displayResult()
        
    }
    @IBAction func reset(_ sender: UIButton) {
        caculator = CalculatorBrain()
        displayValue = 0
        descriptionDisplay.text = " "
        userIsInTheMiddleOfTyping = false
        variables = Dictionary<String,Double>()
    }
    @IBAction func undo(_ sender: Any) {
        if userIsInTheMiddleOfTyping, var text = label.text {
            text.remove(at: text.index(before: text.endIndex))
            if text.isEmpty || "0" == text {
                text = "0"
                userIsInTheMiddleOfTyping = false
            }
            label.text = text
        } else {
            caculator.undo()
            displayResult()
        }
    }
    
    
    @IBAction func caculateBtnClicked(_ sender: mathButton) {
        let digit = sender.currentTitle!
        //print("\(digit) was touched")
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = label.text!
            if decimalSeparator != digit || !textCurrentlyInDisplay.contains(decimalSeparator) {
                label.text = textCurrentlyInDisplay + digit
            }
        } else {
            switch digit {
            case decimalSeparator:
                label.text = "0" + decimalSeparator
            case "0":
                if "0" == label.text {
                    return
                }
                fallthrough
            default:
                label.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    @IBAction func takePhotoButtonPressed (_ sender: UIButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.isAuto{
            self.reset(self.resetBtn)
            }
            let capturedType = self.stillImageOutput.connection(withMediaType: AVMediaTypeVideo)
            self.stillImageOutput.captureStillImageAsynchronously(from: capturedType!) { [weak self] buffer, error -> Void in
                if buffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!)
                    let image = UIImage(data: imageData!)
                    
                    let croppedImage = self?.prepareImageForCrop(using: image!)
                 
                    self?.ocrInstance.recognize(croppedImage!) { [weak self] recognizedString in
                        DispatchQueue.main.async {
                            self?.doubleAdmit.recongonize(str: recognizedString) == "" ? print("error") : self?.caculate(str:(self?.doubleAdmit.recongonize(str: recognizedString))!)
                        }
                    }
                } else {
                    return
                }
            }
        }
    }
    
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        do {
            try device!.lockForConfiguration()
            var zoomScale = CGFloat(slider.value * 10.0)
            let zoomFactor = device?.activeFormat.videoMaxZoomFactor
            
            if zoomScale < 1 {
                zoomScale = 1
            } else if zoomScale > zoomFactor! {
                zoomScale = zoomFactor!
            }
            
            device?.videoZoomFactor = zoomScale
            device?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
    }
}

extension ViewController{
    
    func caculate(str:String) {
       var digit = ""
        if str != "." && str != "-"{
          digit = str
        }else{
            return
        }
        //print("\(digit) was touched")
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = label.text!
            if decimalSeparator != digit || !textCurrentlyInDisplay.contains(decimalSeparator) {
                label.text = textCurrentlyInDisplay + digit
            }
        } else {
            switch digit {
            case decimalSeparator:
                label.text = "0" + decimalSeparator
            case "0":
                if "0" == label.text {
                    return
                }
                fallthrough
            default:
                label.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    
    func displayResult() {
        let evaluated = caculator.evaluate(using: variables)
        
        if let error = evaluated.error {
            label.text = error
        } else if let result = evaluated.result {
            displayValue = result
        }
        
        if "" != evaluated.description {
            descriptionDisplay.text = evaluated.description.beautifyNumbers() + (evaluated.isPending ? "…" : "=")
        } else {
            descriptionDisplay.text = " "
            
        }
    }
    

    
    func adjustButtonLayout(for view: UIView, isPortrait: Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.isHidden = isPortrait
            } else if subview.tag == 2 {
                subview.isHidden = !isPortrait
            }
            if let button = subview as? UIButton {
                button.setBackgroundColor(UIColor.black, forState: .highlighted)
                button.setTitleColor(UIColor.white, for: .highlighted)
            } else if let stack = subview as? UIStackView {
                adjustButtonLayout(for: stack, isPortrait: isPortrait);
            }
        }
    }
}

    


extension ViewController {
    // MARK: AVFoundation
    fileprivate func configureCameraForUse () {
        self.stillImageOutput = AVCaptureStillImageOutput()
        let fullResolution = UIDevice.current.userInterfaceIdiom == .phone && max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) < 568.0
        
        if fullResolution {
            self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        } else {
            self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        }
        
        self.captureSession.addOutput(self.stillImageOutput)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.prepareCaptureSession()
        }
    }
    
    private func prepareCaptureSession () {
        do {
            self.captureSession.addInput(try AVCaptureDeviceInput(device: self.device!))
        } catch {
            print("AVCaptureDeviceInput Error")
        }
        
        
        
        // device lock is important to grab data correctly from image
        do {
            try self.device?.lockForConfiguration()
            self.device?.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            self.device?.focusMode = .continuousAutoFocus
            self.device?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
        
        //Set initial Zoom scale
        do {
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            try device?.lockForConfiguration()
            
            let zoomScale: CGFloat = 2.5
            
            if zoomScale <= (device?.activeFormat.videoMaxZoomFactor)! {
                device?.videoZoomFactor = zoomScale
            }
            
            device?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
        
        DispatchQueue.main.async(execute: {
            // layer customization
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            previewLayer?.frame = self.cameraView.layer.bounds
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.cameraView.layer.addSublayer(previewLayer!)
            self.cameraView.layer.addSublayer(self.viewFinder.layer)
            self.cameraView.layer.addSublayer(self.detailBtn.layer)
            self.cameraView.layer.addSublayer(self.scanView.layer)
            self.captureSession.startRunning()
        })
    }
    
    // MARK: Image Processing
    fileprivate func prepareImageForCrop (using image: UIImage) -> UIImage {
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(Double.pi)
        }
        
        let imageOrientation = image.imageOrientation
        let degree = image.detectOrientationDegree()
        let cropSize = CGSize(width: 400, height: 110)
        
        //Downscale
        let cgImage = image.cgImage!
        
        let width = cropSize.width
        let height = image.size.height / image.size.width * cropSize.width
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        let bitmapInfo = cgImage.bitmapInfo
        
        let context = CGContext(data: nil,
                                width: Int(width),
                                height: Int(height),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace!,
                                bitmapInfo: bitmapInfo.rawValue)
        
        context!.interpolationQuality = CGInterpolationQuality.none
        // Rotate the image context
        context?.rotate(by: degreesToRadians(degree));
        // Now, draw the rotated/scaled image into the context
        context?.scaleBy(x: -1.0, y: -1.0)
        
        //Crop
        switch imageOrientation {
        case .right, .rightMirrored:
            context?.draw(cgImage, in: CGRect(x: -height, y: 0, width: height, height: width))
        case .left, .leftMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: -width, width: height, height: width))
        case .up, .upMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        case .down, .downMirrored:
            context?.draw(cgImage, in: CGRect(x: -width, y: -height, width: width, height: height))
        }
        
        let calculatedFrame = CGRect(x: 0, y: CGFloat((height - cropSize.height)/2.0), width: cropSize.width, height: cropSize.height)
        let scaledCGImage = context?.makeImage()?.cropping(to: calculatedFrame)
        
        
        return UIImage(cgImage: scaledCGImage!)
    }
    
}
extension ViewController{
    
    
    @objc func animate(){
        
        
        
        UIView.animate(withDuration: 0.5,animations: {
            self.animateLabel.text = "3"
            self.animateLabel.alpha = 1.0
        }, completion: { (true) in
            UIView.animate(withDuration: 0.5, animations: {
                self.animateLabel.alpha = 0
            },completion:{(true)in
                
                self.animateLabel.text = "2"
                UIView.animate(withDuration: 0.5, animations: {
                    self.animateLabel.alpha = 1
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.animateLabel.alpha = 0
                       
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.5, animations: {
                             self.animateLabel.text = "1"
                            self.animateLabel.alpha = 1
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.5, animations: {
                                self.animateLabel.alpha = 0
                            }, completion:{(true) in
                               self.takePhotoButtonPressed(self.recogBtn)
                                self.performOperation(self.addBtn)
                            })
          
                        })
                    })
                })
            })
        })
    
    }
}



