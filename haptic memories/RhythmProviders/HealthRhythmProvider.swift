//
//  HealthRhythmProvider.swift
//  haptic memories
//
//  Created by jens ewald on 15/01/2021.
//

import SwiftUI
import UIKit
import HealthKit

public class HealthRhythmProvider: RhythmProvider {
    @AppStorage("days") var days = 7

    let store = HKHealthStore()
    let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! ]

    var data: Array<RhythmTick> = []
    
    var min = 0.0
    var max = 0.0

    public override init() {
        super.init()
        recompute()
    }
    
    override func recompute() {
        self.progress = nil
        self.ready = false
        self.data.removeAll()
        fetchData()
    }

    override func reset() {
//        super.reset()
//        reset1()
        reset2()
    }
    
    func fetchData() {
        // Ask for access
        store.requestAuthorization(toShare: [], read: healthKitTypes) { (success, error) in
            // Authorization Successful

            if success {
                print("Fetching steps")
                self.getSteps { date, result, progress in
                    let tick = RhythmTick(
                        progress: CGFloat(progress),
                        value: CGFloat(result),
                        when: date,
                        min: self.min,
                        max: self.max)
                    self.data.append(tick)
                    self.progress = progress
                    self.ready = self.progress! >= 1.0
                    print("Result", tick, self.ready)
                    if self.ready {
                        print("Data count before filter", self.data.count)
                        // update all min and max values
                        for t in 1...self.data.count {
                            self.data[t-1].min = self.min
                            self.data[t-1].max = self.max
                        }
                        // Remove all 0.0 values
                        var zeroCount = 0
                        self.data = self.data.filter({ v in
                            if Double(v.value) == 0.0 {
                                zeroCount += 1
                            } else {
                                zeroCount = 0
                            }
                            // Allow for N number of consecutive 0s
                            return zeroCount < 60 // the unit depends on the interval of fetching data (e.g. minute)
                        })
                        self.data.sort { a, b in
                            a.when < b.when
                        }
                        print("Data count after filter", self.data.count)
                    }
                }
            }
        }
    }
    
    // This function is called form other threads…
    func getSteps(completion: @escaping (Date, Double, Double) -> Void) {
        // We are looking for step count
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
                    
        let now = Date()

        var captureDuration = DateComponents()
//        captureDuration.day = -1 // since yesterday
//        captureDuration.year = -1 // since one year !! Caution this will cause the app to ru out of memory
        captureDuration.day = -days // capture one full week
        let since = Calendar.current.date(byAdding: captureDuration, to: now)!

        // Pre compute how many entries to expect
        let numDataPoints = Calendar.current.dateComponents([.minute], from: since, to: now).minute!
//        let numDataPoints = Calendar.current.dateComponents([.second], from: since, to: now).second!

        print("Expecting", numDataPoints, "data points")
        self.data = Array<RhythmTick>(repeating: RhythmTick(progress: 0, value: 0, when: Date()), count: numDataPoints)
        
        var count = 0

        // Craete the interval for the statistics
        var interval = DateComponents()
//        interval.hour = 1
        // Split into steps/minute
        interval.minute = 1
//        interval.second = 30 // careful: too fine, too many results
        
        // TODO: filter out "bed time" to avoid long breaks
        
        let predicate = HKQuery.predicateForSamples(withStart: since, end: now, options: [])
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                               quantitySamplePredicate: predicate,
                                               options: [.cumulativeSum],
                                               anchorDate: since,
                                               intervalComponents: interval)
        var min = 0.0
        var max = 0.0
        query.initialResultsHandler = { _, result, error in
            result!.enumerateStatistics(from: since, to: now) { statistics, _ in
                var result = 0.0
                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    result = sum.doubleValue(for: HKUnit.count())
                }
                if result < min {
                    min = result
                }
                if result > max {
                    max = result
                }
                DispatchQueue.main.async {
                    print("min", min, "max", max)
                    self.min = min
                    self.max = max
                    completion(statistics.startDate, result, Double(count) / Double(numDataPoints))
                    count += 1
                }
            }
        }

        store.execute(query)
        
    }
    
    /**
     Response Algorithms
     */
    public override func match(_ value: CGFloat) -> RhythmTick? {
        return match2(value)
    }

    // --------------------------------------------------------------------------
    // Data retrieval method 2
    var pos2: Int = 0
    
    func reset2() {
        pos2 = 0
        progress = 1
    }

    // Consider: Progress through the data set based on the stride width (value)
    func match2(_ value: CGFloat) -> RhythmTick? {
        // 1.1) check if we ran over the available data
        if pos2 >= data.count {
            return nil
        }
        var result = data[pos2] // do it reverse
        print(pos2, result.when)
        pos2 += 1
        // Normalise the value at the current progress
        result.value = result.value.map(from: CGFloat(result.min)...CGFloat(result.max), to: 0.0...1)

        self.progress = 1 - Double(pos2) / Double(data.count)

        return result
    }

    // --------------------------------------------------------------------------
    // Data retrieval method 1
//    var lastPos: Int = 0
//
//    func reset1() {
//        lastPos = 0
//        progress = 1
//    }
//
//    func match1(_ value: CGFloat) -> Double? {
//        // Alg 1:
//        // 1) Take a chunk based on the incoming distance; 1 pixel == 1 element
//        // 2) Compute the avarage
//        // 3) map based on min/max
//
//        // 1) Take a chunk based on the incoming distance; 1 pixel == 1 element
//        let newPos = lastPos + Int(floor(value))
//        print("new pos", newPos, data.count)
//        // 1.1) check if we ran over the available data
//        if newPos >= data.count {
//            return nil
//        }
//
//        let chunk = data[lastPos...newPos]
//        print("using chunk:", chunk)
//
//        // 1.2) Store lastPos
//        lastPos = newPos
//
//        // 2) Compute the avarage
//        let avg = chunk.reduce(0) { (value, current) -> Double in
//            return current + (value * 1/Double(chunk.count))
//        }
//        print(avg)
//
//        let _min = chunk.min() ?? 0 / Double(chunk.count)
//        let _max = chunk.max() ?? 0 / Double(chunk.count)
//
//        print("min/max", _min, _max)
//
//        // 3) map based on min/max
//        let result = avg.map(from: _min..._max, to: 0...1)
//
//        return result
//    }
}
