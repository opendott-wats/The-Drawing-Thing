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


struct Cam<Content: View>: View {
    private var content : (UIImage) -> Content
    private var snapshot : Binding<UIImage>

    @StateObject var session = CameraSession()

    @inlinable public init(
        _ snapshot: Binding<UIImage>,
        @ViewBuilder content: @escaping (UIImage) -> Content
    ) {
        self.content = content
        self.snapshot = snapshot
//        self.session.delegate = self
    }
    
//    mutating func received(frame: UIImage) {
//        self.snapshot.wrappedValue = frame
//        self.snapshot.update()
//    }
    
    var body: some View {
        ZStack {
            self.content(self.session.frame)
        }
        .onAppear {
            session.start()
        }
        .onDisappear {
            session.stop()
        }
    }
    
}

protocol CameraSessionDelegate {
    mutating func received(frame: UIImage)
}

/**
 Minimal AVCaptureSession wrapper UIView
 */
class CameraSession: NSObject, ObservableObject {
    var session: AVCaptureSession?
    
    var permission = false
    
    var delegate : CameraSessionDelegate? = nil
    
    @Published var frame : UIImage = UIImage()
    
//    private let photoOutput = AVCapturePhotoOutput()
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
        session.sessionPreset = .vga640x480

        session.addInput(cameraInput)

//        guard session.canAddOutput(photoOutput) else { return nil }
//        session.addOutput(photoOutput)

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
 Trying video processing
 */
extension CameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private func addVideoOutput(_ session: AVCaptureSession) {
        self.videoOutput.videoSettings = [:] // Provide an empty dictionary for device native pixel format
        // Dropped frames are ok
        self.videoOutput.alwaysDiscardsLateVideoFrames = true
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
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
        var img = CIImage(cvImageBuffer: frame,
                          options: meta as? [CIImageOption : Any])
                            // Turn 90º clockwise
                            .oriented(.right)
//                            .applyingGaussianBlur(sigma: 10)
        
        img = img.cropped(to: CGRect(
            x: (img.extent.width - 375)/2,
            y: (img.extent.height - 667)/2,
            width: 375,
            height: 665))

        
        let pixelate = CIFilter(name: "CIPixellate")
        pixelate?.setValue(img, forKey: kCIInputImageKey)
        pixelate?.setValue(30, forKey: kCIInputScaleKey)
            
        img = pixelate!.outputImage!
        
        if let cgimg = context.createCGImage(img, from: img.extent) {
            let result = UIImage(cgImage: cgimg)
            DispatchQueue.main.async {
                self.frame = result
            }
        }
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
