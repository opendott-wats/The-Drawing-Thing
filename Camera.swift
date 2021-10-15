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


struct Cam<Content: View> : View {
    private var content : (UIImage) -> Content

    @StateObject var session = CameraSession()

    init(@ViewBuilder content: @escaping (UIImage) -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Color.blue
            self.content(session.frame)
        }
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
    
//    var target : CaptureTarget? = nil
    
    @Published var frame : UIImage = UIImage()
    
//    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()

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
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        if self.superview != nil {
//            guard let session = self.setupSession() else {
//                return
//            }
//            self.session = session
//            self.previewLayer.session = self.session
//            self.previewLayer.videoGravity = .resizeAspectFill
//            self.session?.startRunning()
//        } else {
//            if let session = self.session {
//                session.stopRunning()
//                self.session = nil
//            }
//        }
//    }
    
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
        
        session.sessionPreset = .hd1280x720

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
        self.videoOutput.videoSettings = [
            (kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32ARGB)
        ] as [String : Any]
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
        let img = CIImage(cvImageBuffer: frame,
                          options: meta as? [CIImageOption : Any])
//        let img = CIImage(cvImageBuffer: frame)

        let result = UIImage(ciImage: img, scale: 1, orientation: .right)

        debugPrint(result, meta)

        DispatchQueue.main.async {
            self.frame = result //imageWith(text: "\(Int.random(in: 0...200))")!
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
