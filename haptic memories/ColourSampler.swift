//
//  ColourSampler.swift
//  haptic memories
//
//  Created by jens ewald on 14/10/2021.
//

import SwiftUI

/// The ColourSampler samples colours ans stores the in the preferences
struct ColourSampler: View {
    @Environment(\.managedObjectContext) private var viewContext
    let colourSampler = ColourSamplingController.shared

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
        guard let colour = colour else { return }
        
        let newColour = Colour(context: viewContext)
        newColour.time = Date()
        newColour.hue = Float(colour.hue)

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ColourSampler_Previews: PreviewProvider {
    static var previews: some View {
        ColourSampler()
    }
}
