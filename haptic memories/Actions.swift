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

    private let size : CGFloat = 32

    private var label : some View {
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

    @State private var needsReset = false
    @State private var showSettings = false
    @State private var showShare = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.clear
            HStack(alignment: .bottom, spacing: 10) {
                // Share Button
                ActionButton(name: "square.and.arrow.up", action: shareDrawing)
                    .disabled(drawing.empty)
                    .opacity(drawing.empty ? 0.5 : 1.0)
                // Reset Button
                ActionButton(name: "arrow.counterclockwise", action: reset)
                // Settings
                ActionButton(name: "gearshape", action: toggleSettings)
            }.padding([.bottom, .trailing], 9.0)
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(activityItems: [drawing.sharePng() as Any])
        }
        .sheet(isPresented: $showSettings, onDismiss: settingsDismissed) {
            SettingsSheet(needsReset: $needsReset)
        }
    }
    
    func toggleSettings()  {
        self.showSettings.toggle()
    }
    
    func shareDrawing() {
        showShare = true
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
