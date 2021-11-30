//
//  SettingsPanel.swift
//  haptic memories
//
//  Created by jens ewald on 10/09/2021.
//
//  Copyright (C) 2021  jens alexander ewald <jens@poetic.systems>
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//  
//  ------
//  
//  This project has received funding from the European Union’s Horizon 2020
//  research and innovation programme under the Marie Skłodowska-Curie grant
//  agreement No. 813508.
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
