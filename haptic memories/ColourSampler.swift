//
//  ColourSampler.swift
//  haptic memories
//
//  Created by jens ewald on 14/10/2021.
//

import SwiftUI

/**
 The ColourSampler samples colours ans stores the in the preferences
 */
struct ColourSampler: View {
    @State var takeSnapshot: Bool = false
    @State var snapshot: UIImage = UIImage()
    
    var body: some View {
        ZStack {
            VStack {
                Cam($snapshot) { img in
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.yellow)
                }
//                Cam() { Img, image in Img
//                    Img
//                }
//                .aspectRatio(CGSize(width: 1280, height: 720), contentMode: .fit)
//                .frame(height: 250)
            }
//            if self.snapshot != nil {
//                Image(uiImage: self.snapshot!)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                Button("retake") {
//                    self.takeSnapshot = false
//                }
//            } else {
//                Camera(takeSnapshot: self.$takeSnapshot, snapshot: self.$snapshot)
//                Button("snap") {
//                    self.takeSnapshot = true
//                }
//            }
        }
    }
}

struct ColourSampler_Previews: PreviewProvider {
    static var previews: some View {
        ColourSampler()
    }
}
