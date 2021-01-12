//
//  ContentView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

struct ContentView: View {
    @State private var doodleView = DoodleViewController()
    @State private var showShareSheet = false
    @State private var sharedItems : [Any] = []

    var body: some View {
        ZStack {
            DoodleView(doodleView: $doodleView)
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    Button {
                        self.showShareSheet.toggle() // = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 42, height: 40)
                            .padding(.bottom, 2)
                            .foregroundColor(Color.white)
                    }.background(Color.orange)
                    .cornerRadius(21)
                    .padding()
                    .sheet(isPresented: $showShareSheet) {
                        ShareSheet(activityItems: [self.doodleView.export().pngData()! as Any ])
                    }

                    Button {
                        self.doodleView.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 42, height: 40)
                            .padding(.bottom, 2)
                            .foregroundColor(Color.white)
                    }.background(Color.orange)
                    .cornerRadius(21)
                    .padding()
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
