//
//  haptic_memoriesApp.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

@main
struct haptic_memoriesApp: App {
    #if targetEnvironment(simulator)
    @StateObject var provider = RandomRhythmProvider()
    #else
    @StateObject var provider = HealthRhythmProvider()
    #endif
    
    var body: some Scene {
        WindowGroup {
            OrientationBased(
                portrait: ContentView(provider: provider)
                , landscape: ColourSampler()
            )
                .statusBar(hidden: true)
                .onAppear(perform: {
                    UIApplication.shared.isIdleTimerDisabled = true
                })
                .onDisappear(perform: {
                    UIApplication.shared.isIdleTimerDisabled = false
                })
        }
    }
}
