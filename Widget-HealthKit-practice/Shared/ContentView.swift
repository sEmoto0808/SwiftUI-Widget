//
//  ContentView.swift
//  Shared
//
//  Created by Sho Emoto on 2022/06/25.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {

        VStack {
            Text("Hello, world!")
                .padding()

            Button("request Auth", action: { 
                let healthStore = HKHealthStore()

                let readTypes = Set([
                    HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount )!
                ])

                healthStore.requestAuthorization(toShare: [], read: readTypes, completion: {success, error in
                    if success == false {
                        print("データにアクセスできません")
                        return
                    }

                    let calendar = Calendar.current
                    let hkTypeStepCount = HKObjectType.quantityType(forIdentifier: .stepCount)!

                    let today = calendar.dateComponents([.calendar, .year, .month, .day], from: Date())
                    let startDate = DateComponents(year: today.year, month: today.month, day: today.day, hour: 0, minute: 0, second: 0)
                    let endDate = DateComponents(year: today.year, month: today.month, day: today.day, hour: 23, minute: 59, second: 59)

                    let predicate = HKQuery.predicateForSamples(
                        withStart: calendar.date(from: startDate),
                        end: calendar.date(from: endDate)
                    )

                    let query = HKSampleQuery(
                        queryDescriptors: [.init(sampleType: hkTypeStepCount, predicate: predicate)],
                        limit: 10,
                        resultsHandler: { query, samples, error in
                            print("<------ debug ------>")
                            print(samples)
                            print(error)
                            print("<------ debug ------>")
                        })

                    healthStore.execute(query)
                })

            })
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
