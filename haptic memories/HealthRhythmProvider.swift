//
//  HealthRhythmProvider.swift
//  haptic memories
//
//  Created by jens ewald on 15/01/2021.
//

import HealthKit

// Code based on blog post: https://bennett4.medium.com/creating-an-ios-app-to-display-the-number-of-steps-taken-today-1060635e05ae

public class HealthRhythmProvider: RhythmProvider, ObservableObject {
    let store = HKHealthStore()
    let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! ]
    var stepsLabel : String = ""
    var data: Array<Double> = []

    public init() {
        // Ask for access
        store.requestAuthorization(toShare: [], read: healthKitTypes) { (bool, error) in
            if (bool) {
                debugPrint("Fetching steps")
                // Authorization Successful
                self.data.removeAll()
                self.getSteps { date, result in
                    DispatchQueue.main.async {
                        print("new steps", date, result)
                        let stepCount = result
                        self.stepsLabel = String(stepCount)
                        self.data.append(stepCount)
                    }
                }
            } // end if
        } // end of checking authorization
    }
    
    @Published public var progress: Double = 0.0
    
    func setProgress(_ value: Int, max: Int?) {
        guard let max = max else {
            return
        }
        DispatchQueue.main.async {
            self.progress = Double(value) / Double(max)
        }
    }
    
    // This function is called form other threads…
    func getSteps(completion: @escaping (Date, Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
                    
        let now = Date()

        var components = DateComponents()
//        components.day = -1 // since yesterday
//        components.year = -1
        components.weekday = -7
        
        let since = Calendar.current.date(byAdding: components, to: Calendar.current.startOfDay(for: now))!
        let numDataPoints = Calendar.current.dateComponents([.minute], from: since, to: now).minute!
//        print(numDatPoints)
        self.data = Array<Double>(repeating: 0.0, count: numDataPoints)
        setProgress(0, max: numDataPoints)
        
        var count = 0
//        return

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
            result!.enumerateStatistics(from: since, to: now) { statistics, _ in
                var resultCount = 0.0
//                debugPrint(statistics.startDate, statistics.endDate)
                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    print("summing successful")
                    resultCount = sum.doubleValue(for: HKUnit.count())
                }
                self.setProgress(count, max: numDataPoints)
                if (count == numDataPoints) {
                    print(statistics.startDate, "--------- DONE ---------")
                    print(self.data)
                }
                count += 1
                debugPrint("Initial steps count result", count, self.progress, statistics.startDate, resultCount)

                DispatchQueue.main.async {
                    completion(statistics.startDate, resultCount)
                }
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            if let sum = statistics?.sumQuantity() {
                let startDate = statistics?.startDate
                let resultCount = sum.doubleValue(for: HKUnit.count())
                debugPrint("Updated steps count result", startDate!, resultCount)
                DispatchQueue.main.async {
                    completion(startDate!, resultCount)
                }
            }
        }
                
        store.execute(query)
    }
    
    public func match(value: Float) -> Bool {
        return true
    }
}
