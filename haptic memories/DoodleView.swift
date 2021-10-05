//
//  DoodleView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
//

import SwiftUI

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
    @ObservedObject var rhythm: Provider
    @Binding var drawing: Drawing

    let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    // Drawing properties
    let threshold: CGFloat = 3.0
    @State private var lastPoint = CGPoint.infinity

    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            Image(uiImage: drawing.image)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
            if rhythm.ready {
                VStack {
                    ProgressView(value: rhythm.progress!, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.white))
                        .rotationEffect(Angle(degrees: 180))
                    Spacer()
                }
            }
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
        }
        .onAppear() {
            drawing.load()
        }
    }

    func dragEnded(value: DragGesture.Value) -> Void {
        lastPoint = CGPoint.infinity
    }
    
    func dragChanged(_ drag: DragGesture.Value) -> Void {
        var isFirstStroke = false
        if lastPoint.isInfinite() {
            lastPoint = drag.startLocation
            isFirstStroke = true
        }
        let currentPoint = drag.location
        let distance = lastPoint.dist(currentPoint)

        if let tick = self.rhythm.match(distance) {
            if isFirstStroke {
                drawing.layer()
            }
            // Draw a line when the rhythm finds a match
            drawing.line(from: lastPoint, to: currentPoint, tick: tick)
            // Actuate the haptic feedback device
            self.generator.impactOccurred(intensity: tick.value.map(to: 0.1...4.0))
        }
        
        lastPoint = currentPoint
    }
}

struct DoodleView_Preview: PreviewProvider {
    @State static var drawing = Drawing()
    static var size = CGSize(width: 200, height: 300)

    static var previews: some View {
        DoodleView(rhythm: RandomRhythmProvider(), drawing: $drawing)
            .previewDevice("iPhone 8")
            .statusBar(hidden: true)
    }
}
