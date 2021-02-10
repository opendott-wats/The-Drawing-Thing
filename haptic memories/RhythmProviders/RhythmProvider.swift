//
//  RhythmProviders.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
//

import UIKit

//public protocol RhythmProvider: ObservableObject {
//    // value - the distance to the last point drawn, or length of line
//    func match(_ value: Double) -> Double?
//    var progress: Double { get }
//    var ready: Bool { get }
//}


/**
 Default implementation of a RhythmProvider
 */
//extension RhythmProvider {
public class RhythmProvider: ObservableObject {
    func match(_ value: Double) -> Double? {
        return Double.random(in: 0...1)
    }

    @Published var progress: Double? = nil    
    
    @Published var ready: Bool = false
    
    func reset() {}
}

//    var progress: Double {
//        get { 0 }
//        set { }
//    }
//
//    public var ready: Bool {
//        get { true }
//    }
//}
