//
//  RhythmProviders.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
//

import UIKit

public protocol RhythmProvider {
    // value - the distance to the last point drawn, or length of line
    func match(value: Float) -> Bool
    var progress: Double { get set }
}

public class RandomRhythmProvider: RhythmProvider, ObservableObject {
    let generator = UIImpactFeedbackGenerator(style: .rigid)

    public func match(value: Float) -> Bool {
        let state = Bool.random()
        if state {
            let intensity = CGFloat(value).map(from: 0.0...36, to: 0.3...4.0)
//            print(value, intensity)
            self.generator.impactOccurred(intensity: intensity)
        }
        return state
    }
    
    public var progress: Double {
        get {
            return 0
        }
        set {
           return
        }
    }
}


// Mapping Helpers
// Imported from https://gist.github.com/ZevEisenberg/7ababb61eeab2e93a6d9

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}

extension Double {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Double {
        return Double(CGFloat(self).map(from: from, to: to))
    }
}

extension Float {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Float {
        return Float(CGFloat(self).map(from: from, to: to))
    }
}
