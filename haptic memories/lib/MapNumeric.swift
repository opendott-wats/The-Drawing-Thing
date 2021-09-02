//
//  common.swift
//  haptic memories
//
//  Created by jens ewald on 09/02/2021.
//

import CoreGraphics

// Mapping Helpers
// Imported from https://gist.github.com/ZevEisenberg/7ababb61eeab2e93a6d9

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
    
    func map(to: ClosedRange<Double>) -> CGFloat {
        return self.map(from: 0...1, to: CGFloat(to.lowerBound)...CGFloat(to.upperBound))
    }
}

extension Double {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Double {
        return Double(CGFloat(self).map(from: from, to: to))
    }
    func map(from: ClosedRange<Double>, to: ClosedRange<Double>) -> Double {
        return ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
    }
}

extension Float {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Float {
        return Float(CGFloat(self).map(from: from, to: to))
    }
}
