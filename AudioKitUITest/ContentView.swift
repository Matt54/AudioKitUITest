//
//  ContentView.swift
//  AudioKitUITest
//
//  Created by Matt Pfeiffer on 1/1/21.
//

import SwiftUI
import AudioKitUI

struct ContentView: View {
    @EnvironmentObject var conductor: Conductor
    
    var body: some View {
        FFTView(conductor.micMixer)
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Conductor.shared)
    }
}
