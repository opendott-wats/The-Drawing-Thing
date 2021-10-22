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
    @State var sampledColour: UIColor = .clear
    @State var holdPreview = false
    
    let generator = UINotificationFeedbackGenerator()

    var body: some View {
        ColourCamera() { session in
            Button(action: sampleAndHold(session), label: {
                Color(holdPreview ? sampledColour : session.avgColour)
            })
        }
    }
    
    func sampleAndHold(_ session: CameraSession) -> () -> Void {
        return {
            holdPreview.toggle()
            if holdPreview {
                sampledColour = session.avgColour
                generator.notificationOccurred(.success)
            } else {
                generator.notificationOccurred(.error)
            }
        }
    }
}

struct ColourSampler_Previews: PreviewProvider {
    static var previews: some View {
        ColourSampler()
    }
}
