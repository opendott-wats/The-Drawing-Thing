//
//  Colour.swift
//  haptic memories
//
//  Utilities to handle store and retrieve sampled colours
//
//  Created by jens ewald on 26/10/2021.
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

import UIKit
import CoreData
import SwiftUI

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
