//
//  Camera.swift
//  haptic memories
//
//  A live camera view for SwiftUI
//
//  Created by jens ewald on 14/10/2021.
//

import SwiftUI
import UIKit
import AVFoundation

struct ColourCamera<Content: View>: View {
    private var content : (CameraSession) -> Content

    @StateObject var session = CameraSession()

    @inlinable public init(@ViewBuilder content: @escaping (CameraSession) -> Content) {
        self.content = content
    }
    
    var body: some View {
        self.content(self.session)
            .onAppear {
                session.start()
            }
            .onDisappear {
                session.stop()
            }
    }
}

/**
 Minimal AVCaptureSession wrapper UIView
 */
class CameraSession: NSObject, ObservableObject {
    var session: AVCaptureSession?
    var permission = false
    
//    @Published var frame : UIImage = UIImage()
//    @Published var colours : UIImageColors = UIImageColors(background: .clear
//                                                           , primary: .clear
//                                                           , secondary: .clear
//                                                           , detail: .clear)
    @Published var avgColour : UIColor = .clear
    
    private let videoOutput = AVCaptureVideoDataOutput()
    
    // For Core Image Processing
    private let context = CIContext()

    override init(){
        super.init()
        self.permission = checkAuthorization()
        self.session = setupSession()
    }
    
    func checkAuthorization() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .denied: return false
        case .restricted: return false
        case .notDetermined:
            let q = DispatchGroup()
            q.enter()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                self.permission = granted
                q.leave()
            }
            q.wait()
            return self.permission
        @unknown default:
            fatalError()
        }
    }
    
    func start() {
        if self.session?.isRunning == false {
            self.session?.startRunning()
        }
    }
    
    func stop() {
        if self.session?.isRunning == true {
            self.session?.stopRunning()
        }
    }

    private func setupSession() -> AVCaptureSession? {
        guard self.permission else {
            print("Could not setup capture session. No permission.")
            return nil
        }
        let session = AVCaptureSession()
        
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(
                    // The `.builtInWideAngleCamera` seems to work on iPhone7
                    .builtInWideAngleCamera,
                    // We need a live view
                    for: .video,
                    // Specifically enable the back facing camera
                    position: .back
                )
        else {
            print("Could not init back camera for video")
            return nil
        }
        
        configureCamera(camera)

        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(cameraInput)
        else {
            print("Error: Could not create AVCaptureDeviceInput or add it")
          return nil
        }
        
        // Phone Screen is 667x375 (retina 1334x750)
        session.sessionPreset = .cif352x288

        session.addInput(cameraInput)

        addVideoOutput(session)
        
        // Commit configuration at the end
        session.commitConfiguration()
        
        return session
    }
    
    func configureCamera(_ camera: AVCaptureDevice) {
        // Configure the camera with very near focus to blur the image
        do {
            // start configuration
            try camera.lockForConfiguration()
            
            // Don't let the focus be changed
            camera.focusMode = .locked
            
            // Enable focus range restriction if possible
            if camera.isAutoFocusRangeRestrictionSupported {
                camera.autoFocusRangeRestriction = .near
            }
            // Set the focus to as near as possible to blur the images as much as possible.
            // Physical change: smear, stick something onto, or sand the lens
            camera.setFocusModeLocked(lensPosition: 0)
            
            // configuration end
            camera.unlockForConfiguration()
        } catch {
            print("Error configuring camera")
        }

    }
}

/**
 Processing Video Stream
 */
extension CameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private func addVideoOutput(_ session: AVCaptureSession) {
        self.videoOutput.videoSettings = [:] // Provide an empty dictionary for device native pixel format
        // Dropped frames are ok
        self.videoOutput.alwaysDiscardsLateVideoFrames = true
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video.processing"))
        guard session.canAddOutput(self.videoOutput) else {
            fatalError()
        }
        session.addOutput(self.videoOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        
        let meta = CMCopyDictionaryOfAttachments(
            allocator: kCFAllocatorDefault,
            target: sampleBuffer,
            attachmentMode: kCMAttachmentMode_ShouldPropagate)
        
        let scaleAdjustment = 1.0
        
        var img = CIImage(cvImageBuffer: frame,
                          options: meta as? [CIImageOption : Any])
                            // Turn 90º clockwise
                            .oriented(.right)
                            .transformed(by: CGAffineTransform(scaleX: scaleAdjustment, y: scaleAdjustment))
                            .applyingGaussianBlur(sigma: 2)
//                            .transformed(by: CGAffineTransform(
//                                scaleX: 375/720*scaleAdjustment,
//                                y: 665/1280*scaleAdjustment))

        // This can be 25 or 75
        let pixelSize = 5
//
        let pixelate = CIFilter(name: "CIPixellate")
        pixelate?.setValue(img, forKey: kCIInputImageKey)
        pixelate?.setValue(pixelSize, forKey: kCIInputScaleKey)
        img = pixelate!.outputImage!
                        
//        let region = CGRect(
//            x: pixelSize, // move one pixel size in to skip blurred frame
//            y: pixelSize + 10, // move one pixel size in to skip blurred frame + 10 to account for the multiple
//            width: 375,
//            height: 665)

        let region = CGRect(
            x: 0,
            y: 0,
            width:  288 * scaleAdjustment,
            height: 352 * scaleAdjustment
        )
        
        let avgColour = img.averageColor(
            // Sample at the center
            at: CGPoint(x: region.width/2, y: region.height/2),
            // zoom in for colour sampling
            size: CGSize(width: region.width/2, height: region.height/2),
            // reuse the CGContext
            context: self.context)

        DispatchQueue.main.async {
            self.avgColour = (avgColour ?? .clear).fromHueOnly()
        }

//        if let cgimg = context.createCGImage(img, from: region) {
//            let colours = cgimg.extractColours()
//            let result = UIImage(cgImage: cgimg)
//            
//            DispatchQueue.main.async {
//                self.frame = result
//                self.colours = colours!
//            }
//        }
    }
}

/**
 Based on https://stackoverflow.com/a/48441178
 */
extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { renderer in
            self.setFill()
            renderer.fill(CGRect(origin: .zero, size: size))
        }
    }
}

/**
    Colour utilities
 */
extension UIColor {
    
    /// A convenience coputed proerty to retrieve just the hue value
    var hue : CGFloat {
        var (hue, saturation, brightness, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return hue
    }
    
    
    /// Creates a UIColor based on the RGBA components of the given CIColor
    /// - Parameter ciColor: CIColor as source of components
    convenience init(componentsOf ciColor: CIColor) {
        self.init(red: ciColor.red, green: ciColor.green, blue: ciColor.blue, alpha: ciColor.alpha)
    }
}

extension CIColor {
    /// Creates a new UIColor based on the hue value
    /// - Returns: UIColor
    func fromHueOnly(saturation: CGFloat = 1.0, lightness: CGFloat = 0.5) -> UIColor {
        return UIColor(
                   hue: UIColor(componentsOf: self).hue,
            saturation: saturation,
             lightness: lightness,
                 alpha: self.alpha)
    }
}



func imageWith(text: String?) -> UIImage? {
     let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
     let nameLabel = UILabel(frame: frame)
     nameLabel.textAlignment = .center
     nameLabel.backgroundColor = .lightGray
     nameLabel.textColor = .white
     nameLabel.font = UIFont.boldSystemFont(ofSize: 40)
     nameLabel.text = text
     UIGraphicsBeginImageContext(frame.size)
      if let currentContext = UIGraphicsGetCurrentContext() {
         nameLabel.layer.render(in: currentContext)
         let nameImage = UIGraphicsGetImageFromCurrentImageContext()
         return nameImage
      }
      return nil
}

// Extract colour from pixel at position
// Based on https://stackoverflow.com/questions/3284185/get-pixel-color-of-uiimage
extension CGImage {
    func pixel(x: Int, y: Int) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? { // swiftlint:disable:this large_tuple
        guard let pixelData = dataProvider?.data,
            let data = CFDataGetBytePtr(pixelData) else { return nil }

        let pixelInfo = ((width  * y) + x ) * 4

        let red = CGFloat(data[pixelInfo])         // If you need this info, enable it
        let green = CGFloat(data[(pixelInfo + 1)]) // If you need this info, enable it
        let blue = CGFloat(data[pixelInfo + 2])    // If you need this info, enable it
        let alpha = CGFloat(data[pixelInfo + 3])   // I need only this info for my maze game

        return (red/255.0, green/255.0, blue/255.0, alpha/255.0)
    }
}
