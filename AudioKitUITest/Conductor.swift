//
//  Conductor.swift
//  AudioKitUITest
//
//  Created by Matt Pfeiffer on 1/1/21.
//

import AudioKit
import Foundation

/**
 This is the persistent data object that binds to the SwiftUI views.
 You can think of it as the model that holds all of our objects.
 The ChoirEffect class is likely all you need from this project, but the rest of this class should demonstrate how to interface with it functionality.
 */
class Conductor : ObservableObject{
    
    /// Single shared data model
    static let shared = Conductor()
    
    /// Audio engine instance
    let engine = AudioEngine()
        
    /// default microphone
    var mic: AudioEngine.InputNode
    
    /// mixing node for microphone input - routes to plotting and recording paths
    let micMixer : Mixer
    
    /// mixer with no volume so that we don't output audio
    let silentMixer : Mixer
    
    /// tap for the fft data
    var fft : FFTTap!
    
    /// size of fft
    let FFT_SIZE = 512
    
    /// audio sample rate
    let sampleRate : double_t = 44100
    
    /// limiter to prevent excessive volume at the output - just in case, it's the music producer in me :)
    let outputLimiter : PeakLimiter
    
    /// bin amplitude values (range from 0.0 to 1.0)
    @Published var amplitudes : [Double] = Array(repeating: 0.5, count: 50)
    
    init(){
        guard let input = engine.input else {
            fatalError()
        }
        
        // setup mic
        mic = input
        micMixer = Mixer(mic)
        silentMixer = Mixer(micMixer)
        silentMixer.volume = 0.0
        
        // route the silent Mixer to the limiter (you must always route the audio chain to AudioKit.output)
        outputLimiter = PeakLimiter(silentMixer)
        
        // set the limiter as the last node in our audio chain
        engine.output = outputLimiter
        
        // connect the fft tap to the mic mixer and send the fft data to our updateAmplitudes function on callback (when data is available)
        fft = FFTTap(micMixer) { fftData in
            DispatchQueue.main.async {
                self.updateAmplitudes(fftData)
            }
        }
        
        //START AUDIOKIT
        do{
            try engine.start()
            fft.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
    }
    
    /// Analyze fft data and write to our amplitudes array
    func updateAmplitudes(_ fftData: [Float]){
        
        // loop by two through all the fft data
        for i in stride(from: 0, to: self.FFT_SIZE - 1, by: 2) {
            
            // get the real and imaginary parts of the complex number
            let real = fftData[i]
            let imaginary = fftData[i + 1]
            
            let normalizedBinMagnitude = 2.0 * sqrt(real * real + imaginary * imaginary) / Float(self.FFT_SIZE)
            let amplitude = Double(20.0 * log10(normalizedBinMagnitude))
            
            // scale the resulting data
            var scaledAmplitude = (amplitude + 250) / 229.80
            
            // restrict the range to 0.0 - 1.0
            if (scaledAmplitude < 0) {
                scaledAmplitude = 0
            }
            if (scaledAmplitude > 1.0) {
                scaledAmplitude = 1.0
            }
            
            // add the amplitude to our array (further scaling array to look good in visualizer)
            DispatchQueue.main.async {
                if(i/2 < self.amplitudes.count){
                    self.amplitudes[i/2] = self.map(n: scaledAmplitude, start1: 0.3, stop1: 0.9, start2: 0.0, stop2: 1.0)
                }
            }
        }
    }
    
    /// simple mapping function to scale a value to a different range
    func map(n:Double, start1:Double, stop1:Double, start2:Double, stop2:Double) -> Double {
        return ((n-start1)/(stop1-start1))*(stop2-start2)+start2;
    };
    
}
