//
//  Colour.swift
//  haptic memories
//
//  Utilities to handle store and retrieve sampled colours
//
//  Created by jens ewald on 26/10/2021.
//

import UIKit

struct ColourSampler {
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

}
