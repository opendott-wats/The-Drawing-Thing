//
//  SettingsPanel.swift
//  haptic memories
//
//  Created by jens ewald on 10/09/2021.
//

import SwiftUI

struct SettingsPanel : View {
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("lineWidthMin") var lineWidthMin: Double = 0.3
    @AppStorage("lineWidthMax") var lineWidthMax: Double = 4
    @AppStorage("days") var days = 7

    var body: some View {
        VStack {
            HStack() {
                Text("Settings").font(.title)
                Spacer()
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
            .padding(.bottom, 12.0)
//            Divider()
            Text("When changing these settings the drawing area will be reset and ink will be regenerated!")
                .multilineTextAlignment(.leading)
                .padding(.bottom, 12.0)
//            Divider()
//            DoubleSlider(
//                value: $lineWidthMin,
//                range: 0.1...4,
//                label: "Line Width (min):")
//            DoubleSlider(
//                value: $lineWidthMax,
//                range: 1.0...10,
//                label: "Line Width (max):")
            Stepper("Line Width Min:\t\(lineWidthMin)", value: $lineWidthMin, in: 0.1...4, step: 0.1)
            Stepper("Line Width Max:\t\(String(format:"%0.1f",  lineWidthMax))", value: $lineWidthMax, in: 1.0...10, step: 1)
//            Text("TODO: Line Preview here")
//            Divider()
            Stepper("How many days?\t\(days)", value: $days, in: 1...30)
        }.padding(10)
    }
}

struct SetingsPanel_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPanel()
            .previewDevice("iPhone 8")
    }
}

struct DoubleSlider: View {
    @Binding var value: Double
    @State var range: ClosedRange<Double>
    @State var label: String

    var body: some View {
        Text("\(label) \(String(format: "%.2f", value))")
        Slider(
            value: $value,
            in: range) {
        }
    }
}
