//
//  DoodleView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
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
import CoreData

extension CGPoint {
    static let infinity = CGPoint(x: CGFloat.infinity, y: CGFloat.infinity)
    
    func isInfinite() -> Bool {
        return self == CGPoint.infinity
    }
    
    func dist(_ b: CGPoint) -> CGFloat {
        return CGFloat(
            hypotf(
                Float(self.x - b.x),
                Float(self.y - b.y)
            )
        )
    }
}

struct DoodleView<Provider>: View where Provider: RhythmProvider {
//    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var rhythm: Provider
    @Binding var drawing: Drawing

    let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    // Drawing properties
    let threshold: CGFloat = 3.0
    @State private var lastPoint = CGPoint.infinity

    @Environment(\.scenePhase) private var scenePhase
    @Binding var showActions : Bool

    var body: some View {
        ZStack {
            Image(uiImage: drawing.image)
                // Make sure the image is drawn full screen.
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
        }
        .background(Color.black)
        .gesture(DragGesture()
                    .onChanged(self.dragChanged)
                    .onEnded(self.dragEnded))
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                // load image
                print("load stored image")
                drawing.load()
            }
            if phase == .background {
                // store drawing
                print("store drawing")
                drawing.store()
            }
            if phase == .inactive {
                // store drawing
                print("store drawing")
                drawing.store()
            }
        }
        .onAppear() {
            // load the sampled colours from CoreData
            loadColours()
            
            // load the stashed drawing
            drawing.load()
        }
    }

    func dragEnded(value: DragGesture.Value) -> Void {
        lastPoint = CGPoint.infinity
        drawing.store()
    }
    
    func dragChanged(_ drag: DragGesture.Value) -> Void {
        let gestureBegins = lastPoint.isInfinite()
        if gestureBegins {
            lastPoint = drag.startLocation
        }
        let currentPoint = drag.location
        let distance = lastPoint.dist(currentPoint)

        if let tick = self.rhythm.match(distance) {
            // Retrieve the colour
            let colour = colourFor(time: tick.when)
            
            // Notes on fading layers:
            // - layer could fade according to a jump in time, eg. set amount of minutes, hours, etc
            //   - would need to store a reference of data date of last layer
            // - layer is drawn on start of gesture making each stroke the content between the fades
            // There is a minimum of opacity the drawing must make to have an effect,
            // e.g. 0.001955 had no effect whereas 0.00196 had profound effect
            // this leaves the question: after how many lines to apply the fade layer?
            
            // Draw a line when the rhythm finds a match
            drawing.line(from: lastPoint, to: currentPoint, tick: tick, colour: colour, addLayer: gestureBegins)
            // Actuate the haptic feedback device
            self.generator.impactOccurred(intensity: tick.value.map(to: 0.1...4.0))
        }
        
        lastPoint = currentPoint
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Colour.time, ascending: true)],
        animation: .default)
    private var storedColours: FetchedResults<Colour>

    @State private var colours : Array<(time: Date, value: UIColor)> = []
    
    /// Loads all sampled colours into an array for quick access
    func loadColours() {
        colours.removeAll()
        for colour in storedColours {
            colours.append((time: colour.time!, value: UIColor(hue: CGFloat(colour.hue), saturation: 1, lightness: 0.7, alpha: 1)))
        }
    }
     
    
    /// Picks the correspondong colour sample from the stored time series
    /// - Parameter time: Date time predicate
    /// - Returns: Matching colour or default
    func colourFor(time: Date) -> UIColor {
        let defaultColour = UIColor(hue: 0, saturation: 1, lightness: 0.7, alpha: 1)

        // Safe guard for an empty list of stored colours
        if storedColours.isEmpty {
            return defaultColour
        }

        // Go through the stored colours and find the closest one in the past
        // `previous` keeps track of the most recent colour
        var previous = (time: Date(timeIntervalSince1970: 0), value: defaultColour)
//        debugPrint("---------")
        for colour in colours {
//            debugPrint("time vs colour time time:", time, colour.time)
            // A match is when the current iteratation's time is greater AND the previous is smaller, then return the smaller one
            if colour.time > time && previous.time <= time {
//                debugPrint("**** colour match", previous.value)
                return previous.value
            }
            // track the previous iteration for comparison
            previous = colour
        }
//        debugPrint("---------")
        // If there is no match found use the most recent one
        return previous.value
    }
}

struct DoodleView_Preview: PreviewProvider {
    @State static var drawing = Drawing()
    @State static var showActions = false

    static var previews: some View {
        DoodleView(rhythm: RandomRhythmProvider(), drawing: $drawing, showActions: $showActions)
            .previewDevice("iPhone 8")
            .statusBar(hidden: true)
    }
}
