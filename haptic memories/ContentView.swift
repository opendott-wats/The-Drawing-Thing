//
//  ContentView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var provider: RhythmProvider

    @State var drawing = Drawing()
    
    @State var showActions = false

    var body: some View {
        ZStack {
            // Whole application has a black background
            Color.black.edgesIgnoringSafeArea(.all)

            if !provider.ready {
                ProgressView(value: provider.progress)
                    { Text("loading data ...").colorInvert() }
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .padding(50)
            } else {
                DoodleView(rhythm: provider, drawing: $drawing, showActions: $showActions)
            }
            
            if showActions {
                Actions(
                    provider: provider,
                    drawing: $drawing
                )
            }
        }.gesture(TapGesture(count: 3).onEnded({ _ in
            showActions.toggle()
        }))
    }
}


struct ContentView_Previews: PreviewProvider {
    @StateObject static var provider = RandomRhythmProvider()
    static var previews: some View {
        ContentView(provider: provider)
            .previewDevice("iPhone 8")
    }
}
