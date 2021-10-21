//
//  OrientationBasedView.swift
//  haptic memories
//
//  Created by jens ewald on 21/10/2021.
//

import SwiftUI
import UIKit

struct OrientationBased<PortraitView: View, LandscapeView: View>: View {
    let inPortrait : PortraitView
    let inLandscape: LandscapeView
    
    private let orientationChange = NotificationCenter
                                        .default
                                        .publisher(for: UIDevice
                                                        .orientationDidChangeNotification)

    @State private var orientation : UIDeviceOrientation = .portrait
    
    func updateOrientation(_ n: Notification) {
        guard let device = n.object as? UIDevice else {
            return
        }
        withAnimation {
            orientation = device.orientation
        }
    }
    
    var body : some View {
        Group {
            if orientation.isLandscape {
                inLandscape
            } else {
                inPortrait
            }
        }
        .onReceive(orientationChange, perform: updateOrientation)
    }
    
}
