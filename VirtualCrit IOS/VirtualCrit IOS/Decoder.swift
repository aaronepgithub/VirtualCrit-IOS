//
//  Decoder.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation
import AVFoundation

class TextToSpeechUtils: NSObject, AVSpeechSynthesizerDelegate {
    
    let synthesizer = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()
    let defaultLanguage = "en-US"
    var lastPlayingUtterance: AVSpeechUtterance?
    
    public func synthesizeSpeech(forText text: String) {
        
        if Settings.enableAudio == true {
            
            if (text.isEmpty) { return }
            
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.duckOthers])
                try audioSession.setActive(true)
            } catch {
                return
            }
            
            let utterance = AVSpeechUtterance(string:text)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.volume = 0.9
            utterance.voice = AVSpeechSynthesisVoice(language: defaultLanguage)
            self.synthesizer.speak(utterance)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                do {
                    try self.audioSession.setActive(false)
                } catch {
                    print("err closing audio session")
                }
            })
            
            self.lastPlayingUtterance = utterance
            
        }
        
        
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if (synthesizer == self.synthesizer && self.lastPlayingUtterance == utterance) {
            do {
                // after last utterance has played - deactivate the audio session
                try self.audioSession.setActive(false);
            } catch {
                return
            }
        }
    }
    
    private func detectLanguageFromText(_ text: String) -> String {
        let tagger = NSLinguisticTagger.init(tagSchemes: [NSLinguisticTagScheme.language], options: 0)
        tagger.string = text
        let textLanguage = tagger.tag(at: 0, scheme: NSLinguisticTagScheme.language, tokenRange: nil, sentenceRange: nil)
        var detectedLanguage: String?
        for installedLanguage in AVSpeechSynthesisVoice.speechVoices() {
            let languageStringParts = installedLanguage.language.components(separatedBy: "-")
            if (languageStringParts.count > 0 && languageStringParts[0] == textLanguage!.rawValue) {
                detectedLanguage = installedLanguage.language
                break
            }
        }
        
        // if language could not be detected return default language
        return detectedLanguage ?? defaultLanguage
    }
}
