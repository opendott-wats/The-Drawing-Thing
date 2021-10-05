//
//  SettingsPanel.swift
//  haptic memories
//
//  Created by jens ewald on 10/09/2021.
//

import SwiftUI

struct SettingsSheet : View {
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("lineWidthMin") var lineWidthMin: Double = 0.3
    @AppStorage("lineWidthMax") var lineWidthMax: Double = 4
    @AppStorage("days") var days = 7
    @AppStorage("resetImage") var resetImage = false

    @Binding var needsReset : Bool

    func setChanged(_ value : Bool) {
        self.needsReset = true
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack() {
                Text("Settings").font(.title)
                Spacer()
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
            .padding(.bottom, 24.0)

            Text("When changing these settings the drawing area will be reset and ink will be regenerated!")
                .multilineTextAlignment(.leading)
                .padding(.bottom, 24.0)

            Stepper("Line Width Min:\t\(String(format:"%0.1f",lineWidthMin))",
                    value: $lineWidthMin,
                    in: 0.1...10,
                    step: 0.1,
                    onEditingChanged: self.setChanged)
                .padding(.bottom, 24.0)

            Stepper("Line Width Max:\t\(String(format:"%0.1f",  lineWidthMax))",
                    value: $lineWidthMax,
                    in: 1.0...42,
                    step: 1,
                    onEditingChanged: self.setChanged)
                .padding(.bottom, 24.0)

            Stepper("How many days?\t\(days)",
                    value: $days,
                    in: 1...7,
                    step: 1,
                    onEditingChanged: self.setChanged)
                .padding(.bottom, 24.0)
            
            Toggle("Reset drawing on manual reset", isOn: $resetImage)

            Spacer()
        }.padding(10)
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    @State static var needsReset = false
    static var previews: some View {
        SettingsSheet(needsReset: $needsReset)
            .previewDevice("iPhone 8")
    }
}
