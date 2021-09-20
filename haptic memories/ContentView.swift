//
//  ContentView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

struct Drawing {
    var image = UIImage()
}

struct ContentView: View {
    @ObservedObject var provider: RhythmProvider
    @State var drawing = Drawing()
    
    init(_ provider: RhythmProvider) {
        self.provider = provider
    }
    
    let progressStyle = CircularProgressViewStyle(tint: Color.white)
    
    var body: some View {
        ZStack {
            // Whole application has a black background
            Color.black.edgesIgnoringSafeArea(.all)

            if !provider.ready {
                ProgressView(value: provider.progress)
                    { Text("loading data ...").colorInvert() }
                    .progressViewStyle(progressStyle)
                    .padding(50)
            } else {
                GeometryReader { g in
                    DoodleView(rhythm: provider, drawing: $drawing, size: g.size)
                }
            }
            
            Actions(
                provider: provider,
                reset: {
                    drawing = Drawing()
                    provider.reset()
                },
                sharing: {
                    guard let data = drawing.image.pngData() else {
                        return nil
                    }
                    return data
                }
            )
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    @StateObject static var provider = RandomRhythmProvider()
    static var previews: some View {
        ContentView(provider)
            .previewDevice("iPhone 8")
    }
}
