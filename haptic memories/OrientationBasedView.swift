//
//  OrientationBasedView.swift
//  haptic memories
//
//  Created by jens ewald on 21/10/2021.
//
//  Copyright (C) 2021  jens alexander ewald <jens@poetic.systems>
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//  
//  ------
//  
//  This project has received funding from the European Union’s Horizon 2020
//  research and innovation programme under the Marie Skłodowska-Curie grant
//  agreement No. 813508.
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
