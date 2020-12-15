//
//  RhythmProviders.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
//

public protocol RhythmProvider {
    func match(value: Float) -> Bool
}

public class RandomRhythmProvider: RhythmProvider {
    public func match(value: Float) -> Bool {
        return Bool.random()
    }
}

