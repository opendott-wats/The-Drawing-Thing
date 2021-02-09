//
//  ContentView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

struct ContentView: View {
    
//    @StateObject var provider = HealthRhythmProvider()
    @StateObject var provider = RandomRhythmProvider()
    @State private var doodler = DoodleViewController()

    @State private var showShareSheet = false
    @State private var sharedItems: [Any] = []

    var body: some View {
        ZStack {
            DoodleView(controller: $doodler, rhythm: provider)
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    if provider.progress > 0 {
                        ProgressView(value: provider.progress)
                    }

                    Spacer()

                    // Share Button
                    Button {
                        self.showShareSheet.toggle() // = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 42, height: 40)
                            .padding(.bottom, 2)
                            .foregroundColor(Color.white)
                    }.background(Color.orange)
                        .cornerRadius(21)
                        .padding()
                        .sheet(isPresented: $showShareSheet) {
                            ShareSheet(activityItems: [self.doodler.export().pngData()! as Any])
                        }

                    // Reset Button
                    Button {
                        self.doodler.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 42, height: 40)
                            .padding(.bottom, 2)
                            .foregroundColor(Color.white)
                    }.background(Color.orange)
                        .cornerRadius(21)
                        .padding()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
