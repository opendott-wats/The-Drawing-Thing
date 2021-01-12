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
}

public class RandomRhythmProvider: RhythmProvider {
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
}

import HealthKit

// Code based on blog post: https://bennett4.medium.com/creating-an-ios-app-to-display-the-number-of-steps-taken-today-1060635e05ae

public class HealthRhythmProvider: RhythmProvider {
    let store = HKHealthStore()
    let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! ]
    var stepsLabel : String = ""

    public init() {
        // Ask for access
        store.requestAuthorization(toShare: [], read: healthKitTypes) { (bool, error) in
            if (bool) {
                // Authorization Successful
                self.getSteps { (result) in
                    DispatchQueue.main.async {
                        let stepCount = String(Int(result))
                        self.stepsLabel = String(stepCount)
                    }
                }
            } // end if
        } // end of checking authorization
    }
    
    // This function is called form other threads…
    func getSteps(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
        let now = Date()

        var components = DateComponents()
        components.day = -1 // since yesterday
        let since = Calendar.current.date(byAdding: components, to: Calendar.current.startOfDay(for: now))!

        var interval = DateComponents()
//        interval.hour = 1
        interval.minute = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                               quantitySamplePredicate: nil,
                                               options: [.cumulativeSum],
                                               anchorDate: since,
                                               intervalComponents: interval)
        
        query.initialResultsHandler = { _, result, error in
            var resultCount = 0.0
            result!.enumerateStatistics(from: since, to: now) { statistics, _ in
                debugPrint(statistics.startDate, statistics.endDate)
                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    resultCount = sum.doubleValue(for: HKUnit.count())
                    print("Initial steps count result", resultCount)
                } // end if

                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let sum = statistics?.sumQuantity() {
                let resultCount = sum.doubleValue(for: HKUnit.count())
                print("Updated steps count result", resultCount)
                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            } // end if
        }
        
        store.execute(query)
    }
    
    public func match(value: Float) -> Bool {
        return true
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
