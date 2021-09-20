//
//  Actions.swift
//  haptic memories
//
//  Created by jens ewald on 10/02/2021.
//

import SwiftUI

struct Actions<Provider>: View where Provider: RhythmProvider {
    @ObservedObject var provider: Provider
    var reset: () -> Void
    var sharing: () -> Data?

    @State private var showShareSheet = false
    @State private var data: Data = Data()

    @State var showSettings = false
    
    let size : CGFloat = 32

    func ActionButton(_ systemName: String, _ action: @escaping () -> Void) -> some View {
        return Button {
            action()
        } label: {
            Image(systemName: systemName)
            .foregroundColor(Color.white)
            .scaleEffect(size * 0.7 / size)
        }
        .frame(width: size, height: size)
        .background(Color.orange)
        .cornerRadius(size/2)
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                // Share Button
                ActionButton("square.and.arrow.up") {
                    if sharing() != nil {
                        self.showShareSheet.toggle()
                    }
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [sharing() as Any])
                }

                // Reset Button
                ActionButton("arrow.counterclockwise", reset)

                // Settings
                ActionButton("gearshape") {
                    self.showSettings.toggle()
                }
                .sheet(isPresented: $showSettings, onDismiss: {
                    reset()
                    provider.recompute()
                }) {
                    SettingsSheet()
                }
                
            }
        }
        .padding([.bottom, .trailing], 9.0)
    }
}


struct Actions_Previews: PreviewProvider {
    static var previews: some View {
        Actions(provider: RandomRhythmProvider(), reset: {
            
        }, sharing: {
            return nil
        })
            .previewDevice("iPhone 8")
    }
}
