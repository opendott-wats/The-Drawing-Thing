//
//  ContentView.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 30/11/2020.
//

import SwiftUI

struct ContentView: View {
    @State private var doodleView = DoodleViewController()
    var body: some View {
        DoodleView(doodleView: $doodleView)
        Button("clear", action: tap)
    }
    
    func tap() -> Void {
        doodleView.reset()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
