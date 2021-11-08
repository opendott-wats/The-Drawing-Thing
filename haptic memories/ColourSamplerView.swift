//
//  ColourSampler.swift
//  haptic memories
//
//  Created by jens ewald on 14/10/2021.
//

import SwiftUI


/// The ColourSampler samples colours ans stores the in the preferences
struct ColourSamplerView: View {
//    @Environment(\.managedObjectContext) private var viewContext
    let colourSampler = ColourSampler.shared

    @State var sampledColour: UIColor? = nil
    
    let generator = UINotificationFeedbackGenerator()

    var body: some View {
        ColourCamera() { session in
            Color(sampledColour ?? session.avgColour)
                .onLongPressGesture() {
                    guard sampledColour == nil,
                          session.avgColour != .clear else { return }
                    sampledColour = session.avgColour
                    colourSampler.record(colour: sampledColour)
                    generator.notificationOccurred(.success)
                }
        }
    }
    
}

struct ColourSampler_Previews: PreviewProvider {
    static var previews: some View {
        ColourSamplerView()
    }
}
