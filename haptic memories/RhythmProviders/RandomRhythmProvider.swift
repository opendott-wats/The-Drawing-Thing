//
//  RandomRhythmProvider.swift
//  haptic memories
//
//  Created by jens ewald on 09/02/2021.
//

import Foundation

public class RandomRhythmProvider: RhythmProvider, ObservableObject {
    public func match(_ value: Double) -> Double? {
        return Double.random(in: 0...1)
    }
    
    public var progress: Double {
        get {
            return Double.random(in: 0.2...0.8)
        }
    }
}

