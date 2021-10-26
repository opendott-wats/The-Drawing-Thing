//
//  ColourSampler.swift
//  haptic memories
//
//  Created by jens ewald on 14/10/2021.
//

import SwiftUI

/// The ColourSampler samples colours ans stores the in the preferences
struct ColourSampler: View {
    @State var sampledColour: UIColor? = nil
    
    let generator = UINotificationFeedbackGenerator()

    var body: some View {
        ColourCamera() { session in
            Color(sampledColour ?? session.avgColour)
                .onLongPressGesture() {
                    guard sampledColour == nil,
                          session.avgColour != .clear else { return }
                    sampledColour = session.avgColour
                    generator.notificationOccurred(.success)
                    record(colour: sampledColour)
                }
        }
    }
    
    /// Stores a UIColor in our record
    /// - Parameter colour: The colour to record
    func record(colour: UIColor?) {
        // WIP
    }
}

struct ColourSampler_Previews: PreviewProvider {
    static var previews: some View {
        ColourSampler()
    }
}
