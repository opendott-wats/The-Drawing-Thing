//
//  OrientationBasedView.swift
//  haptic memories
//
//  Created by jens ewald on 21/10/2021.
//

import SwiftUI
import UIKit

struct OrientationBased<PortraitView: View, LandscapeView: View>: View {
    let portrait : PortraitView
    let landscape: LandscapeView

    @State private var orientation : UIDeviceOrientation = .portrait
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    @inlinable public init(
        portrait: PortraitView,
        landscape: LandscapeView
    ) {
        self.portrait = portrait
        self.landscape = landscape
    }
    
    @ViewBuilder var viewForOrientation : some View {
        if orientation.isLandscape {
            landscape
        } else {
            portrait
        }
    }
    
    var body : some View {
        viewForOrientation
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            self.orientation = UIDevice.current.orientation
        }
            
    }
    
}
