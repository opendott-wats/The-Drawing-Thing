//
//  haptic_memoriesApp.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

@main
struct haptic_memoriesApp: App {
    let persistenceController = PersistenceController.shared
    let colourSampling = ColourSamplingController.shared

    #if targetEnvironment(simulator)
    @StateObject var provider = RandomRhythmProvider()
    #else
    @StateObject var provider = HealthRhythmProvider()
    #endif
    
    var body: some Scene {
        WindowGroup {
            OrientationBased(inPortrait:  ContentView(provider: provider),
                             inLandscape: ColourSampler())
                .statusBar(hidden: true)
                .onAppear() {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear() {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
                .environment(\.managedObjectContext,
                    persistenceController.container.viewContext)
        }
    }
}
