//
//  RandomRhythmProvider.swift
//  haptic memories
//
//  Created by jens ewald on 09/02/2021.
//

import UIKit

public class RandomRhythmProvider: RhythmProvider {
    let MAX = 1000.0
    var count = 0.0
        
    public override func reset() {
        super.reset()
        count = 0
    }
    
    public override func match(_ value: CGFloat) -> RhythmTick? {
        let tick = RhythmTick.random(progress: self.progress!)
        self.count += 1
        self.progress = self.count / self.MAX
        return tick
    }
}

