//
//  Actions.swift
//  haptic memories
//
//  Created by jens ewald on 10/02/2021.
//

import SwiftUI

struct ActionButton: View {
    let name: String
    let action: () -> Void

    let size : CGFloat = 32

    var label : some View {
        Image(systemName: name)
            .foregroundColor(Color.white)
            .scaleEffect(size * 0.7 / size)
    }

    var body : some View {
        Button(action: action, label: { label })
            .frame(width: size, height: size)
            .background(Color.orange)
            .cornerRadius(size/2)
    }
}


struct Actions<Provider>: View where Provider: RhythmProvider {
    var provider: Provider
    @Binding var drawing : Drawing

    @AppStorage("resetImage") var resetImage = false

    @State private var shared: Drawing?
    @State private var needsReset = false
    @State private var showSettings = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                // Share Button
                ActionButton(name: "square.and.arrow.up", action: {
                    shared = drawing
                })
                    .sheet(item: $shared, onDismiss: {
                        shared = nil
                    }) { value in
                        ShareSheet(activityItems: [value.image.pngData()! as Any])
                    }

                // Reset Button
                ActionButton(name: "arrow.counterclockwise", action: reset)

                // Settings
                ActionButton(name: "gearshape") {
                    self.showSettings.toggle()
                }
                .sheet(isPresented: $showSettings,
                       onDismiss: settingsDismissed,
                       content: { SettingsSheet(needsReset: $needsReset) })
            }
        }
        .padding([.bottom, .trailing], 9.0)
    }
    
    func reset() {
        if resetImage {
            drawing.reset()
        }
        provider.reset()
    }
    
    func settingsDismissed() {
        if self.needsReset {
            reset()
            provider.recompute()
            self.needsReset = false
        }
    }
}


struct Actions_Previews: PreviewProvider {
    @State static var drawing = Drawing()
    static var previews: some View {
        Actions(provider: RandomRhythmProvider(), drawing: $drawing)
            .previewDevice("iPhone 8")
    }
}
