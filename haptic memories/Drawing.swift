//
//  Drawing.swift
//  haptic memories
//
//  Created by jens ewald on 05/10/2021.
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
import SwiftUI

struct Drawing: Identifiable {
    var id = UUID()
    
    var empty : Bool = true
    var size: CGSize = UIScreen.main.bounds.size

    @AppStorage("lineWidthMin") var lineWidthMin: Double = 0.3
    @AppStorage("lineWidthMax") var lineWidthMax: Double = 4

    var image = UIImage()
}

extension Drawing {
    mutating func reset() {
        empty = true
        
        // Create a complete black image
        image = UIGraphicsImageRenderer(size: self.size, format: UIGraphicsImageRendererFormat.default()).image { (context) in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: self.size))
        }

    }
}

extension Drawing {
    func sharePng() -> Data {
        guard let png = image.pngData() else {
            return Data()
        }
        return png
    }
}

extension Drawing: Codable {
    enum CodingKeys: String, CodingKey {
        case image
        case empty
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let string = try container.decode(String.self, forKey: .image)
        guard let data = Data(base64Encoded: string),
              let image = UIImage(data: data) else {
            print("Decoding of image failed")
            self.image = UIImage()
            return
        }
        self.empty = try container.decode(Bool.self, forKey: .empty)
        self.image = image
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let data = image.pngData() else {
            print("Could not get raw image data")
            return
        }
        try container.encode(data.base64EncodedString(), forKey: CodingKeys.image)
        try container.encode(self.empty, forKey: CodingKeys.empty)
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

// Drawing methods
extension Drawing {
    mutating func line(from: CGPoint, to: CGPoint, tick: RhythmTick, colour: UIColor, addLayer: Bool = false) {
        let brushColour = colour.withAlphaComponent(tick.value.map(to: 0.1...0.8))

        let brushWidth = tick.value.map(to: self.lineWidthMin...self.lineWidthMax)
        
        let renderer = UIGraphicsImageRenderer(size: self.size, format: UIGraphicsImageRendererFormat.default())

        image = renderer.image { (context) in
            // first, add the current drawing to keep it
            context.cgContext.setBlendMode(.normal)
            // Drawin the image as background to add new strokes onto. Make sure to drawin a rect of drawing size in order to avoid scaling bugs.
            image.draw(in: CGRect(origin: CGPoint.zero, size: self.size))

            if (addLayer) {
                // draw a black overlay on top to avoid the former image to grey out because of colour issues
                context.cgContext.setBlendMode(.darken)
                context.cgContext.setFillColor(UIColor.black.withAlphaComponent(0.04).cgColor)
                context.cgContext.fill([CGRect(origin: CGPoint.zero, size: self.size)])
            }

            // draw the actual line
            context.cgContext.setBlendMode(.normal)

            context.cgContext.move(to: from)
            context.cgContext.addLine(to: to)
            
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineWidth(brushWidth)

            context.cgContext.setStrokeColor(brushColour.cgColor)
            context.cgContext.strokePath()
            
            empty = false
        }
    }
    
    
}
