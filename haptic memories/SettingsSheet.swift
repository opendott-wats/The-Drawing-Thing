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

            Stepper("Line Width Min:\t\(String(format:"%0.1f",lineWidthMin))", value: $lineWidthMin, in: 0.1...4, step: 0.1)
                .padding(.bottom, 24.0)

            Stepper("Line Width Max:\t\(String(format:"%0.1f",  lineWidthMax))", value: $lineWidthMax, in: 1.0...10, step: 1)
                .padding(.bottom, 24.0)

            Stepper("How many days?\t\(days)", value: $days, in: 1...7)
                .padding(.bottom, 24.0)

            Spacer()
        }.padding(10)
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheet()
            .previewDevice("iPhone 8")
    }
}
