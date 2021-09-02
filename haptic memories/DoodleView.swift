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
    let threshold: CGFloat = 3.0
    @State private var lastPoint = CGPoint.infinity

    let renderFormat = UIGraphicsImageRendererFormat.default()

    var body: some View {
        let tapDrag =
            DragGesture().onChanged({ drag in
                if lastPoint.isInfinite() {
                    lastPoint = drag.startLocation
                }
                let currentPoint = drag.location
                let distance = lastPoint.dist(currentPoint)

                // TODO: Should the validation for a data query move into the providers?
                if distance <= threshold {
                    return
                }

                // Override them when the input is matched against the data record
                if let tick = self.rhythm.match(distance) {
//                    let hue = match.progress
                    let hour = Calendar.current.component(.hour, from: tick.when)
                    let hue = CGFloat(hour).map(from: 0...24, to: 0...1)
                    let color = UIColor(hue: hue,
                                    saturation: 1,
                                    lightness: 0.5,
                                    alpha: tick.value.map(to: 0.1...0.8))

                    // color = UIColor(white: 1, alpha: match.value)

                    let brushWidth = tick.value.map(to: 1...3.0)
                    
                    self.generator.impactOccurred(intensity: tick.value.map(to: 0.1...4.0))
                    drawLine(from: lastPoint, to: currentPoint, color: color.cgColor, brushWidth: brushWidth)
                }
                
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
