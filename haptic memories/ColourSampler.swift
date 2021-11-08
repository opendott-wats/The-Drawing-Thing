//
//  Colour.swift
//  haptic memories
//
//  Utilities to handle store and retrieve sampled colours
//
//  Created by jens ewald on 26/10/2021.
//

import UIKit
import CoreData
import SwiftUI

struct ColourSampler {
    // The settings of days is needed to generate the backing data array with the same structure.
    @AppStorage("days") var days = 7

    static let shared = ColourSampler()

    private let persistenceController = PersistenceController.shared
    private let context = PersistenceController.shared.container.viewContext
    
    static func colourToFloat(_ colour: UIColor) -> String {
        return colour.ciColor.stringRepresentation
    }
    
    static func stringToColour(_ string: String) -> UIColor {
        return UIColor(ciColor: CIColor(string: string))
    }

    /// Stores a UIColor in our record
    /// - Parameter colour: The colour to record
    func record(colour: UIColor?) {
        guard let colour = colour else { return }
        
        let newColour = Colour(context: context)
        newColour.time = Date()
        newColour.hue = Float(colour.hue)

        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Colour.time, ascending: true)],
        animation: .default)
    private var colours: FetchedResults<Colour>


    //    storing the colours is the easy bit; retrieving the colours is harder to make meaningful:
    //    how to we treat the request for the first colour.should that be the timestamp when the change is released?
    //    since which timestamp do we map/lerp the colour value?
    //    it inevitably needs the ink to be limited to what is available, or the hue will turn the brightness back up
    //    it shows that a more complex data point such as colours is not as easy to
    //    include meaningfully. when the relationship of represenation distances further
    //    and becomes more abstract the implementaion becomes more difficult to become
    //    meaningful.
    //    these are just notes within the code while the code is written.
    //    Going with the option of putting in manual limits:
    //    - a colour starts at white
    //    - the camera should make sure the sampled colour does not become to dark to be visible in the drawing (going with a 0.25 lightness value)
    //    - it takes 24h to fade back into white unless another colour is sampled
    //      - all sampled colours loaded in an array to be RAM backed in the sampler
    //        - structure the array such that while drawing the increments are the same; reulsts in: create an array with the same shape as the computed steps, but put the colours in; needs the computed steps first
        func loadColours() {
            
            print("Stored colours ============================")
            for colour in colours {
                debugPrint(colour.time, colour.hue)
            }
            print("===========================================")
        }

}
