//
//  ColourSampler.swift
//  haptic memories
//
//  Created by jens ewald on 14/10/2021.
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
