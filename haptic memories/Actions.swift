//
//  Actions.swift
//  haptic memories
//
//  Created by jens ewald on 10/02/2021.
//

import SwiftUI

struct Actions<Provider>: View where Provider: RhythmProvider {
    @Binding var provider: Provider
    var reset: () -> Void
    var sharing: () -> Data?

    @State private var showShareSheet = false
    @State private var data: Data = Data()

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                // Share Button
                Button {
                    guard let shared = sharing() else {
                        return
                    }
                    data = shared
                    self.showShareSheet.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 42, height: 40)
                        .padding(.bottom, 2)
                        .foregroundColor(Color.white)
                }.background(Color.orange)
                    .cornerRadius(21)
                    .padding()
                    .sheet(isPresented: $showShareSheet) {
                        ShareSheet(activityItems: [data as Any])
                    }

                // Reset Button
                Button {
                    reset()
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

