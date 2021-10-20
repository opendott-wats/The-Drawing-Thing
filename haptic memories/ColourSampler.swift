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
    @State var snapshot: UIImage = UIImage()
    @State var sampledColour: UIColor = .clear
    @State var holdPreview = false
    
    func primaryColour(_ img: UIImage) -> UIColor {
        return img.getColors(quality: .lowest)?.background ?? .black
    }
    
    var body: some View {
        ZStack {
            Cam($snapshot) { img in
                Color(primaryColour(img))
//                Image(uiImage: holdPreview ? snapshot : img)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(Color.black)
                    .gesture(TapGesture().onEnded({ () in
                        holdPreview.toggle()
                        if holdPreview {
                            sampledColour = primaryColour(img)
                            self.snapshot = img
                        }
                    }))
//                Button(action: {
//                    holdPreview.toggle()
//                    if holdPreview {
//                        self.snapshot = img
//    //                    debugPrint(img.averageColor())
//                        // TODO: Store the colour sample
//                    }
//                }, label: {
//                    Image(uiImage: holdPreview ? snapshot : img)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .background(Color.black)
//                })
            }
            VStack {
                Image(uiImage: snapshot)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Color.black)
                    .frame(width: 60, height: 106, alignment: .bottomLeading)
                    .padding(.bottom, 20)
                Spacer()
                Color(sampledColour)
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 20)
            }
        }
//            .simultaneousGesture(DragGesture().onChanged({ drag in
//                debugPrint(drag.location)
//                guard let colour = snapshot.cgImage?.pixel(
//                    x: Int(drag.location.x),
//                    y: Int(drag.location.y)
//                ) else { return }
//
//                debugPrint(colour as Any)
//                self.sampledColour = UIColor(red: colour.r, green: colour.g, blue: colour.b, alpha: colour.a)
//                    debugPrint(self.sampledColour)
//            }))
    }
}

struct ColourSampler_Previews: PreviewProvider {
    static var previews: some View {
        ColourSampler()
    }
}
