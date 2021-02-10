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
            Color.black.edgesIgnoringSafeArea(.all)

            if !provider.ready {
                ProgressView(value: provider.progress)
                    { Text("loading data ...").colorInvert() }
                    .progressViewStyle(progressStyle)
                    .padding(50)
            } else {
                GeometryReader { g in
                    DoodleView(rhythm: provider, drawing: $drawing, frame: g.frame(in: .local), size: g.size)
                }
            }

            Actions(provider: provider,
                    reset: {
                        drawing = Drawing()
                        provider.reset()
                    },
                    sharing: { drawing.image.pngData() }
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
