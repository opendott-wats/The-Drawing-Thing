//
//  RandomRhythmProvider.swift
//  haptic memories
//
//  Created by jens ewald on 09/02/2021.
//

import Foundation

public class RandomRhythmProvider: RhythmProvider {
    
    override init() {
        super.init()
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            self.progress = Double.random(in: 0.1...0.9)
//        }
    }


    public override func match(_ value: Double) -> Double? {
        return Double.random(in: 0...1)
    }
}

