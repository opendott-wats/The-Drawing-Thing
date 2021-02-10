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

struct ContentView<Provider>: View where Provider: RhythmProvider {
    @Binding var provider: Provider
    @State var drawing = Drawing()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if false {
                ProgressView(value: provider.progress)
                    { Text("loading data ...").colorInvert() }
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
//                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .padding(50)
//                    .onTapGesture(perform: {
//                        debugPrint(provider, provider.progress, provider.ready)
//                    })
            } else {
                GeometryReader { g in
                    DoodleView(rhythm: $provider, drawing: $drawing, frame: g.frame(in: .local), size: g.size)
                }
            }

            Actions(provider: $provider,
                    reset: { drawing = Drawing() },
                    sharing: { drawing.image.pngData() }
            )
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    @State static var provider = RandomRhythmProvider()
    static var previews: some View {
        ContentView(provider: $provider)
    }
}
