//
//  Drawing.swift
//  haptic memories
//
//  Created by jens ewald on 05/10/2021.
//

import UIKit
import SwiftUI

struct Drawing {

    var size: CGSize = UIScreen.main.bounds.size

    @AppStorage("lineWidthMin") var lineWidthMin: Double = 0.3
    @AppStorage("lineWidthMax") var lineWidthMax: Double = 4

    var image = UIImage()
}

extension Drawing: Codable {
    enum CodingKeys: String, CodingKey {
        case image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let string = try container.decode(String.self, forKey: .image)
        guard let data = Data(base64Encoded: string), let image = UIImage(data: data) else {
            print("Decoding of image failed")
            self.image = UIImage()
            return
        }
        self.image = image
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let data = image.pngData() else {
            print("Could not get raw image data")
            return
        }
        try container.encode(data.base64EncodedString(), forKey: CodingKeys.image)
    }
    
    
    var fileURL : URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("stash")
    }
    
    mutating func load() {
        //reading
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let result = try JSONDecoder().decode(Self.self, from: jsonData)
            print("loaded", result)
            self.image = result.image
        }
        catch {/* error handling here */}
    }
    
    func store() {
        do {
            let jsonData = try JSONEncoder().encode(self)
            DispatchQueue.global(qos: .background).async {
                do {
                    try jsonData.write(to: fileURL)
                } catch {
                    print("could not write stahs to disk")
                }
            }
        }
        catch {/* error handling here */}
    }
}



extension Drawing {
    mutating func reset() {
        image = UIImage()
    }
}

// Drawing methods
extension Drawing {
    mutating func layer() {
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = true

        let renderer = UIGraphicsImageRenderer(size: self.size, format: renderFormat)
        
        image = renderer.image { (context) in
            // draw the previous pixels first; always use fixed rectangle to avoid scaling bugs
            image.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .normal, alpha: 0.96)
        }
    }
    
    mutating func line(from: CGPoint, to: CGPoint, tick: RhythmTick) {
        let hour = Calendar.current.component(.hour, from: tick.when)
        let hue = CGFloat(hour).map(from: 0...24, to: 0...1)
        let color = UIColor(hue: hue,
                        saturation: 1,
                        lightness: 0.7,
                        alpha: tick.value.map(to: 0.1...0.8)).cgColor

        let brushWidth = tick.value.map(to: self.lineWidthMin...self.lineWidthMax)
        
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = true

        let renderer = UIGraphicsImageRenderer(size: self.size, format: renderFormat)
        
        image = renderer.image { (context) in
            // draw the previous pixels first; always use fixed rectangle to avoid scaling bugs
            image.draw(in: CGRect(origin: CGPoint.zero, size: size))

            context.cgContext.setBlendMode(.normal)

            context.cgContext.move(to: from)
            context.cgContext.addLine(to: to)
            
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineWidth(brushWidth)

            context.cgContext.setStrokeColor(color)
            context.cgContext.strokePath()
        }
    }
    
    
}
