//
//  ColourSampler.swift
//  haptic memories
//
//  Created by jens ewald on 14/10/2021.
//

import SwiftUI

/**
 The ColourSampler samples colours ans stores the in the preferences
 */
struct ColourSampler: View {
    @State var takeSnapshot: Bool = false
    @State var snapshot: UIImage = UIImage()
    
    var body: some View {
        ZStack {
            Cam($snapshot) { img in
                Button(action: {
                    self.snapshot = img
                    debugPrint(img)
                }, label: {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.black)
                })
            }
            VStack {
                Spacer()
                Image(uiImage: snapshot)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Color.black)
                    .frame(width: 60, height: 106, alignment: .bottomLeading)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct ColourSampler_Previews: PreviewProvider {
    static var previews: some View {
        ColourSampler()
    }
}
