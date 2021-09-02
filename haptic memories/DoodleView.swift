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
    
    @State var frame: CGRect
    @State var size: CGSize

    let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    // Drawing properties
    let threshold: CGFloat = 1.0
    @State private var lastPoint = CGPoint.infinity

    var opacity: CGFloat = 1.0

    let renderFormat = UIGraphicsImageRendererFormat.default()

    var body: some View {
        let tapDrag =
            DragGesture().onChanged({ drag in
                if lastPoint.isInfinite() {
                    lastPoint = drag.startLocation
                }
                let currentPoint = drag.location
                let distance = lastPoint.dist(currentPoint)

                if distance <= threshold {
                    return
                }
                
                // Default drawing parameters
                var color = UIColor(white: 0, alpha: 0)
                var brushWidth: CGFloat = 1.0

                // Override them when the input is matched against the data record
                if let match = self.rhythm.match(distance) {
                    let hue = match.progress
                    color = UIColor(hue: hue,
                                    saturation: 1,
                                    lightness: 0.5,
                                    alpha: CGFloat(match.value))
                    // color = UIColor(white: 1, alpha: CGFloat(value))

                    brushWidth = match.value.map(from: 0.0...1, to: 1...2.0)
                    
                    self.generator.impactOccurred(
                        intensity: match.value.map(from: 0.0...1, to: 0.1...4.0)
                    )
                }

                drawLine(from: lastPoint, to: currentPoint, color: color.cgColor, brushWidth: brushWidth)

                lastPoint = currentPoint
            })
            .onEnded({ (value) in
                lastPoint = CGPoint.infinity
            })

        return
            ZStack {
                Color.black // Fill with a background color
                Image(uiImage: drawing.image)
                VStack {
                    ProgressView(value: rhythm.progress!, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.white))
                    Spacer()
                }
            }
            .gesture(tapDrag)
            .onAppear(perform: {
                print(self.frame, self.size, self.drawing.image.size)
            })
    }
    
    func drawLine(from: CGPoint, to: CGPoint, color: CGColor, brushWidth: CGFloat) {
        renderFormat.opaque = true
        let renderer = UIGraphicsImageRenderer(size: self.size, format: renderFormat)

        drawing.image = renderer.image { (context) in
            drawing.image.draw(in: self.frame)
            
            context.cgContext.move(to: from)
            context.cgContext.addLine(to: to)
            
            context.cgContext.setLineCap(.round)
            context.cgContext.setBlendMode(.normal)
            context.cgContext.setLineWidth(brushWidth)
            context.cgContext.setStrokeColor(color)
            
            context.cgContext.strokePath()
        }
    }
    
}
