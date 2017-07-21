//
//  Decoder.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

//import AVFoundation

// You can use an enum so you don't have to manually type out character strings. Look them up once and stick them in an enum. From there, you set the language with your enum rather than typing out the string.
//enum Language: String {
//    case english = "en-US"
//    case arabic = "ar-SA"
//}
//
//class Speaker: NSObject {
//    
//    let synth = AVSpeechSynthesizer()
//    
//    override init() {
//        super.init()
//        synth.delegate = self
//    }
//    
//    func speak(_ announcement: String, in language: String) {
//        print("speak announcement in language \(language) called")
//        prepareAudioSession()
//        let utterance = AVSpeechUtterance(string: announcement.lowercased())
//        utterance.voice = AVSpeechSynthesisVoice(language: language)
//        synth.speak(utterance)
//    }
//    
//    private func prepareAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, with: .mixWithOthers)
//        } catch {
//            print(error)
//        }
//        
//        do {
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print(error)
//        }
//    }
//    
//    func stop() {
//        if synth.isSpeaking {
//            synth.stopSpeaking(at: .immediate)
//        }
//    }
//}
//
//extension Speaker: AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        print("Speaker class started")
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("Speaker class finished")
//    }
//}
