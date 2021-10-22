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
    @State var patternColour: UIColor = .clear
    @State var holdPreview = false
    
    func primaryColour(_ img: UIImage) -> UIColor {
        return img.getColors(quality: .lowest)?.background ?? .clear
    }
    
    var body: some View {
        ZStack {
            Cam($snapshot) { img, colours in
//                Color(primaryColour(img))
                VStack {
                Image(uiImage: holdPreview ? snapshot : img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .background(Color.black)
                    .padding()
                    .gesture(TapGesture().onEnded({ () in
                        holdPreview.toggle()
                        if holdPreview {
                            sampledColour = primaryColour(img)
                            self.snapshot = img
                            patternColour = UIColor(patternImage: img)
                        }
                    }))
                HStack {
                    Color(img.averageColor() ?? .clear).padding(5)
                    Color(colours.background).padding(5)
                    Color(colours.primary).padding(5)
                    Color(colours.secondary).padding(5)
                    Color(colours.detail).padding(5)
                }.frame(height: 60)
                }
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
            .simultaneousGesture(DragGesture().onChanged({ drag in
//                guard let colour = snapshot.cgImage?.pixel(
//                    x: Int(drag.location.x),
//                    y: Int(drag.location.y)
//                ) else { return }
                let size = 25.0
                let x = (1 - drag.location.x/UIScreen.main.bounds.width) * (snapshot.size.width-2*size)
                let y = drag.location.y/UIScreen.main.bounds.height * (snapshot.size.height-2*size)
                let location = CGPoint(
                    x: size/2 + x
                    , y: size/2 + y
                )
//                debugPrint(snapshot.size, drag.location, location)

                self.sampledColour = UIColor(ciColor: CIImage(image: snapshot)!.averageColor(at: location, size: CGSize(width: 25, height: 25)) ?? .clear)
//                debugPrint(sampledColour as Any)
            }))
    }
}

struct ColourSampler_Previews: PreviewProvider {
    static var previews: some View {
        ColourSampler()
    }
}
