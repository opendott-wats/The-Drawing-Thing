//
//  RandomRhythmProvider.swift
//  haptic memories
//
//  Created by jens ewald on 09/02/2021.
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

