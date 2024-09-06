//
//  AudioManager.swift
//  NavSense
//
//  Created by Arjun Srikanth on 21/8/2024.
//

import AVFoundation
import SwiftUI

/*
 * The AudioManager class stores and manages all audio feedback clips
 */
class AudioManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {}
    
    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func playSoundForDistanceRange(_ range: DistanceRange) {
        stopAllSounds()  // Stop all sounds before playing the correct one
        
        // Play clip according to range
        switch range {
        case .lessThan0_1Meters:
            speakText("BOOM!")
        case .lessThan0_5Meters:
            speakText("Danger, immediately in front")
        case .between1And1_5Meters:
            speakText("Danger, one step ahead")
        case .between1_5And2Meters:
            speakText("Danger, two steps ahead")
        }
    }
    
    func stopAllSounds() {
        // Stop all clips
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

enum DistanceRange {
    case lessThan0_1Meters
    case lessThan0_5Meters
    case between1And1_5Meters
    case between1_5And2Meters
}
