//
//  Conductor.swift
//  AudioKitUITest
//
//  Created by Matt Pfeiffer on 1/1/21.
//

import AudioKit
import Foundation

class Conductor : ObservableObject{
    
    /// Audio engine instance
    let engine = AudioEngine()
        
    /// default microphone
    var mic: AudioEngine.InputNode
    
    /// mixing node for microphone input - routes to plotting and recording paths
    let micMixer : Mixer
    
    /// mixer with no volume so that we don't output audio
    let silentMixer : Mixer
    
    /// limiter to prevent excessive volume at the output - just in case, it's the music producer in me :)
    let outputLimiter : PeakLimiter
    
    init(){
        guard let input = engine.input else {
            fatalError()
        }
        
        // setup mic
        mic = input
        micMixer = Mixer(mic)
        silentMixer = Mixer(micMixer)
        
        // route the silent Mixer to the limiter (you must always route the audio chain to AudioKit.output)
        outputLimiter = PeakLimiter(silentMixer)
        
        // set the limiter as the last node in our audio chain
        engine.output = outputLimiter
        
        //START AUDIOKIT
        do{
            try engine.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        // mixer volume can only be set when its attached to the engine
        silentMixer.volume = 0.0
        
    }
    
}
