//
//  haptic_memoriesApp.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

@main
struct haptic_memoriesApp: App {
    @State var provider = RandomRhythmProvider() //HealthRhythmProvider()
    var body: some Scene {
        WindowGroup {
            ContentView(provider: $provider)
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
