//
//  RhythmProviders.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
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
    
    func recompute() {
        
    }
}
