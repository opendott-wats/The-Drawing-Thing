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
}

struct DoodleView<Provider>: View where Provider: RhythmProvider {
    @ObservedObject var rhythm: Provider
    @Binding var drawing: Drawing
    
    @State var frame: CGRect
    @State var size: CGSize
    
    var body: some View {
        let tapDrag =
            DragGesture().onChanged({ drag in
                if lastPoint.isInfinite() {
                    lastPoint = drag.startLocation
                }
                let currentPoint = drag.location
                let distance = Double(hypotf(Float(lastPoint.x - currentPoint.x), Float(lastPoint.y - currentPoint.y)))
                if distance <= threshold {
                    return
                }

                var color = UIColor(white: 0, alpha: 0)
                brushWidth = 1.0
                if let value = self.rhythm.match(distance) {
                    color = UIColor(white: 1, alpha: CGFloat(value))
                    brushWidth = CGFloat(value).map(from: 0.0...1, to: 1...2.0)
                    let intensity = value.map(from: 0.0...1, to: 0.1...4.0)
                    self.generator.impactOccurred(intensity: CGFloat(intensity))
                }

                drawLine(from: lastPoint, to: currentPoint, color: color.cgColor)

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
    
    @State private var lastPoint = CGPoint.infinity

    let generator = UIImpactFeedbackGenerator(style: .rigid)
        
    let threshold = 1.0
    @State var brushWidth: CGFloat = 1.0
    var opacity: CGFloat = 1.0
    var color:UIColor = .white

    let renderFormat = UIGraphicsImageRendererFormat.default()
    
    func drawLine(from: CGPoint, to: CGPoint, color: CGColor) {
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
