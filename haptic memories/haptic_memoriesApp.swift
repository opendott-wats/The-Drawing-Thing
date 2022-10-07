//
//  haptic_memoriesApp.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//
//  Copyright (C) 2021  jens alexander ewald <jens@poetic.systems>
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//  
//  ------
//  
//  This project has received funding from the European Union’s Horizon 2020
//  research and innovation programme under the Marie Skłodowska-Curie grant
//  agreement No. 813508.
// 

import SwiftUI

@main
struct haptic_memoriesApp: App {
    let persistenceController = PersistenceController.shared
    let colourSampling = ColourSampler.shared

    #if targetEnvironment(simulator)
    @StateObject var provider = RandomRhythmProvider()
    #else
    @StateObject var provider = HealthRhythmProvider()
    #endif
    
    var body: some Scene {
        WindowGroup {
            // Whole application has a black background
            ZStack {
                Color.black
                OrientationBased(inPortrait:  ContentView(provider: provider),
                                 inLandscape: ColourSamplerView())
                .statusBar(hidden: true)
                .onAppear() {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear() {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
            }.ignoresSafeArea()
        }
    }
}
