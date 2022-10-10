//
//  ContentView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
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

struct ContentView: View {
    @ObservedObject var provider: RhythmProvider

    @State var drawing = Drawing()
    
    @State var showActions = false

    var body: some View {
        ZStack {
            if !provider.ready {
                ProgressView(value: provider.progress)
                    { Text("loading data ...").colorInvert() }
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .padding(50)
            } else {
                DoodleView(rhythm: provider, drawing: $drawing, showActions: $showActions)
            }
            
            if showActions {
                VStack {
                    ProgressView(value: provider.progress!, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.white))
                        .rotationEffect(Angle(degrees: 180))
                    Spacer()
                    Actions(
                        provider: provider,
                        drawing: $drawing
                    )
                }
                .padding([.top], (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? .zero))
                .padding([.bottom], (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? .zero))
            }
        }.gesture(TapGesture(count: 3).onEnded({ _ in
            showActions.toggle()
        }))
    }
}


struct ContentView_Previews: PreviewProvider {
    @StateObject static var provider = RandomRhythmProvider()
    static var previews: some View {
        ContentView(provider: provider)
            .previewDevice("iPhone 8")
    }
}
