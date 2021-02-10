//
//  ContentView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

struct ContentView<Provider>: View where Provider: RhythmProvider {
    @Binding var provider: Provider
//    @State private var doodler = DoodleViewController<Provider>()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if !provider.ready {
                ProgressView(value: provider.progress)
                    { Text("loading data ...").colorInvert() }
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
//                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .padding(50)
                    .onTapGesture(perform: {
                        debugPrint(provider, provider.progress, provider.ready)
                    })
            } else {
                DoodleView(controller: $doodler, rhythm: provider)
            }

            Actions(provider: $provider, reset: { doodler.reset() }, share: { [self.doodler.export().pngData()! as Any] })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var provider = RandomRhythmProvider()
    static var previews: some View {
        ContentView(provider: $provider)
    }
}
