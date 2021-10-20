//
//  UIImageAvarageColour.swift
//  haptic memories
//
//  Created by jens ewald on 19/10/2021.
//
// Based on this Gist: https://gist.github.com/bbaars/0851c25df14941becc7a0307e41cf716#file-average-color-002-swift
//

import UIKit

extension UIImage {
    /// Average color of the image, nil if it cannot be found
    func averageColor(context: CIContext = CIContext(options: [.workingColorSpace: kCFNull!])) -> UIColor? {
        // convert our image to a Core Image Image
        guard let inputImage = CIImage(image: self),
              let color = inputImage.averageColor()
            else { return nil }
        return UIColor(ciColor: color)
    }
}

extension UIColor {
    convenience init?(averageFrom: CIImage) {
        guard let colour = averageFrom.averageColor() else {
            self.init()
            return nil
        }
        self.init(ciColor: colour)
    }
}

extension CIImage {
    func averageColor(context: CIContext = CIContext(options: [.workingColorSpace: kCFNull!])) -> CIColor? {
        return averageColor(at: self.extent.origin, size: self.extent.size, context: context)
    }
    
    func averageColor(at: CGPoint, context: CIContext = CIContext(options: [.workingColorSpace: kCFNull!])) -> CIColor? {
        return averageColor(at: self.extent.origin, size: CGSize(width: 25, height: 25), context: context)
    }

    func averageColor(at: CGPoint, size: CGSize, context: CIContext = CIContext(options: [.workingColorSpace: kCFNull!])) -> CIColor? {
        // Create an extent vector (a frame with width and height of our current input image)
        let extentVector = CIVector(x: at.x,
                                    y: at.y,
                                    z: size.width,
                                    w: size.height)

        // create a CIAreaAverage filter, this will allow us to pull the average color from the image later on
        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: self, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        // A bitmap consisting of (r, g, b, a) value
        var bitmap = [UInt8](repeating: 0, count: 4)

        // Render our output image into a 1 by 1 image supplying it our bitmap to update the values of (i.e the rgba of the 1 by 1 image will fill out bitmap array
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        // Convert our bitmap images of r, g, b, a to a UIColor
        return CIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
    
}


