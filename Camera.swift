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

/**
 SwiftUI wrapper struct
 */
struct Camera<Content>: UIViewRepresentable where Content : View  {
    typealias UIViewType = UICameraView
    
    private var newFrameReceived: ((UIImage) -> Content)

    init(@ViewBuilder content: @escaping (UIImage) -> Content) {
        self.newFrameReceived = content
    }
    
//    @Binding var takeSnapshot: Bool
//    @Binding var snapshot: UIImage

    func makeUIView(context: Context) -> UICameraView {
        return UICameraView() { frame in newFrameReceived(frame) }
    }
    
    func updateUIView(_ uiView: UICameraView, context: Context) {
//        print("updates")
//        DispatchQueue.main.async {
//            self.snapshot = uiView.capture
//        }
//        if self.takeSnapshot {
//            uiView.snapshot()
//        } else {
//            DispatchQueue.main.async {
//                self.snapshot = nil
//            }
//        }
    }
}

/**
 Just a dummy preview for SwiftUI; camera hardware cannot be accessed in preview mode.
 */
struct Camera_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            Text("Cannot view camera in XCode or Preview Canvas")
                .padding(5.0)
                .colorInvert()
            Spacer()
        }.background(Color.black)
    }
}


/**
 Minimal AVCaptureSession wrapper UIView
 */
class UICameraView: UIView {
    var session: AVCaptureSession?
    
    var notifyNewFrame : ((UIImage) -> Void)
    
    var permission = false
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()

    required init?(coder: NSCoder) {
        self.notifyNewFrame = { _ in }
        super.init(coder: coder)
    }

    init(frameNotifier: @escaping ((UIImage) -> Void)) {
//        self.image = image
        self.notifyNewFrame = frameNotifier
        
        super.init(frame: .zero)

        self.permission = false

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.permission = true
            return
        case .denied: return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                self.permission = granted
            }
            break
        case .restricted: return
        @unknown default:
            fatalError()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            guard let session = self.setupSession() else {
                return
            }
            self.session = session
            self.previewLayer.session = self.session
            self.previewLayer.videoGravity = .resizeAspectFill
            self.session?.startRunning()
        } else {
            if let session = self.session {
                session.stopRunning()
                self.session = nil
            }
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

extension UICameraView: AVCapturePhotoCaptureDelegate {
    func snapshot() {
        let settings = AVCapturePhotoSettings()
        self.photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let err = error {
            print("Failed to take photo", err)
            return
        }
        let imageData = photo.fileDataRepresentation()
        DispatchQueue.main.async {
//            self.capture = UIImage(data: imageData!)
        }
    }

}


/**
 Trying video processing
 */
extension UICameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private func addVideoOutput(_ session: AVCaptureSession) {
        self.videoOutput.videoSettings = [
            (kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)
        ] as [String : Any]
        self.videoOutput.alwaysDiscardsLateVideoFrames = true
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        guard session.canAddOutput(self.videoOutput) else {
            fatalError()
        }
        session.addOutput(self.videoOutput)
    }
    
//    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
////        print("frame dropped")
//    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        
//        debugPrint("did receive image frame", frame)

//        let meta = CMCopyDictionaryOfAttachments(
//            allocator: kCFAllocatorDefault,
//            target: sampleBuffer,
//            attachmentMode: kCMAttachmentMode_ShouldPropagate)
//        let img = CIImage(cvImageBuffer: frame,
//                          options: meta as? [CIImageOption : Any])
        let img = CIImage(cvImageBuffer: frame)

        let uiimg = UIImage(ciImage: img)

        //        debugPrint(uiimg)
        // process image here
        DispatchQueue.main.async {
            self.notifyNewFrame(uiimg)
        }
    }
}
