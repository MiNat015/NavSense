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
    
    func playSoundForDistanceRange(_ range: DistanceRange, objectClass: String) {
        stopAllSounds()  // Stop all sounds before playing the correct one
        
        // Play clip according to range
        switch range {
        case .lessThan0_1Meters:
            speakText("BOOM!")
        case .lessThan0_5Meters:
            if objectClass != "None" {
                speakText(objectClass + " immediately in front")
            } else {
                speakText("Obstruction, immediately in front")
            }
        case .between1And1_5Meters:
            if objectClass != "None" {
                speakText(objectClass + " one step ahead")
            } else {
                speakText("Obstruction, one step ahead")
            }
        case .between1_5And2Meters:
            if objectClass != "None" {
                speakText(objectClass + " two steps ahead")
            } else {
                speakText("Obstruction, two steps ahead")
            }
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
