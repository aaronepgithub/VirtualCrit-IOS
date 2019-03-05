//
//  TextToSpeech.swift
//  VirtualCrit3
//
//  Created by aaronep on 3/5/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import Foundation
import AVFoundation

class Utils: NSObject {
    static let shared = Utils()
    
    let synth = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        
        synth.delegate = self
    }
    
    func say(sentence: String) {
        do {
            
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.spokenAudio, options: AVAudioSession.CategoryOptions.duckOthers)
            } else {
                print("ios9, return")
                return
            }
            
            let utterance = AVSpeechUtterance(string: sentence)
            
            try audioSession.setActive(true)
            
            synth.speak(utterance)
        } catch {
            print("Uh oh!")
        }
    }
}

extension Utils: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        do {
            try audioSession.setActive(false)
        } catch {
            print("Uh oh!")
        }
    }
}
