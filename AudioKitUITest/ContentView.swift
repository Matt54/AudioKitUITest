//
//  ContentView.swift
//  AudioKitUITest
//
//  Created by Matt Pfeiffer on 1/1/21.
//

import SwiftUI
import AudioKitUI

struct ContentView: View {
    let conductor = Conductor()
    
    var body: some View {
        FFTView(conductor.micMixer)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
