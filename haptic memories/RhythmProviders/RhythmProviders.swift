//
//  RhythmProviders.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
//

import UIKit

public protocol RhythmProvider {
    // value - the distance to the last point drawn, or length of line
    func match(_ value: Double) -> Double?
    var progress: Double { get set }
}

