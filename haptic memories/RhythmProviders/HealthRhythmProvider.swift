//
//  HealthRhythmProvider.swift
//  haptic memories
//
//  Created by jens ewald on 15/01/2021.
//

import HealthKit

public class HealthRhythmProvider: RhythmProvider, ObservableObject {
    let store = HKHealthStore()
    let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! ]

    var data: Array<Double> = []

    @Published public var progress: Double = 0.0
    @Published public var ready: Bool = false

    public init() {
        // Ask for access
        store.requestAuthorization(toShare: [], read: healthKitTypes) { (success, error) in
            // Authorization Successful

            if success {
                debugPrint("Fetching steps")
                self.progress = 0.0
                self.ready = false
                self.data.removeAll()
                self.getSteps { date, result, progress in
                    self.data.append(result)
                    self.progress = progress
                    self.ready = self.progress >= 1.0
                    print("Result", date, result, self.progress, self.ready)
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
//        components.day = -1 // since yesterday
//        components.year = -1 // since one year !! Caution this will cause the app to ru out of memory
        captureDuration.weekday = -7 // capture one full week
        
        let since = Calendar.current.date(byAdding: captureDuration, to: now)!

        // Pre compute how many entries to expect
        let numDataPoints = Calendar.current.dateComponents([.minute], from: since, to: now).minute!

        print("Expecting", numDataPoints, "data points")
        self.data = Array<Double>(repeating: 0.0, count: numDataPoints)
        
        var count = 0

        // Craete the interval for the statistics
        var interval = DateComponents()
//        interval.hour = 1
        interval.minute = 1
//        interval.second = 1 // to fine, too many results
        
        // TODO: filter out "bed time" to avoid long breaks
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                               quantitySamplePredicate: nil,
                                               options: [.cumulativeSum],
                                               anchorDate: since,
                                               intervalComponents: interval)
        
        query.initialResultsHandler = { _, result, error in
//            print("Initial result count", result!.statistics().count, numDataPoints)
            result!.enumerateStatistics(from: since, to: now) { statistics, _ in
                var result = 0.0
//                debugPrint(statistics.startDate, statistics.endDate)
                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    result = sum.doubleValue(for: HKUnit.count())
                }
                
//                print("Result:", statistics.startDate, count, result)

                DispatchQueue.main.async { completion(statistics.startDate, result, Double(count) / Double(numDataPoints)) }
                count += 1
            }
        }
        
        // This is optional as the use case is very likely not to occur during activity generating steps
//        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
//            if let sum = statistics?.sumQuantity() {
//                let startDate = statistics?.startDate
//                let resultCount = sum.doubleValue(for: HKUnit.count())
//                debugPrint("Updated steps count result", startDate!, resultCount)
////                DispatchQueue.main.async {
////                    completion(startDate!, resultCount)
////                }
//            }
//        }
                
        store.execute(query)
    }
    
    /**
     Response Algorithms
     */
    
    public func match(_ value: Double) -> Double? {
        return match1(value)
    }
    
    var lastPos: Int = 0
    func match1(_ value: Double) -> Double? {
        // Alg 1:
        // 1) Take a chunk based on the incoming distance; 1 pixel == 1 element
        // 2) Compute the avarage
        // 3) map based on min/max

        // 1) Take a chunk based on the incoming distance; 1 pixel == 1 element
        let newPos = lastPos + Int(floor(value))
        print("new pos", newPos, data.count)
        // 1.1) check if we ran over the available data
        if newPos >= data.count {
            return nil
        }

        let chunk = data[lastPos...newPos]
        print("using chunk:", chunk)
        
        // 1.2) Store lastPos
        lastPos = newPos

        // 2) Compute the avarage
        let avg = chunk.reduce(0) { (value, current) -> Double in
            return current + (value * 1/Double(chunk.count))
        }
        print(avg)
        
        let _min = chunk.min() ?? 0 / Double(chunk.count)
        let _max = chunk.max() ?? 0 / Double(chunk.count)
        
        print("min/max", _min, _max)
        
        // 3) map based on min/max
        let result = avg.map(from: _min..._max, to: 0...1)
        
        return result
    }
}
