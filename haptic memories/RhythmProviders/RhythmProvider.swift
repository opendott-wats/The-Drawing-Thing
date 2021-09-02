//
//  RhythmProviders.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
//

import UIKit

public struct RhythmTick {
    var progress: CGFloat
    var value: CGFloat
    var when: Date
    var min: Double = 0.0
    var max: Double = 1.0
}

extension RhythmTick {
    static func random(progress: Double?) -> RhythmTick {
        return RhythmTick(
            progress: CGFloat(progress ?? 0),
            value: CGFloat.random(in: 0...1),
            when: Date()
        )
    }
}
/**
 Default implementation of a RhythmProvider
 */
public class RhythmProvider: ObservableObject {
    @Published var progress: Double? = nil
    @Published var ready: Bool = false
    
    init() {
        self.reset()
    }
    
    func match(_ value: CGFloat) -> RhythmTick? {
        return RhythmTick.random(progress: self.progress!)
    }

    func reset() {
        self.progress = 0
        self.ready = true
    }
}
