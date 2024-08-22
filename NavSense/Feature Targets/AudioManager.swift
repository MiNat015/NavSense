//
//  AudioManager.swift
//  NavSense
//
//  Created by Arjun Srikanth on 21/8/2024.
//

import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    private var playerForLessThan0_1Meters: AVAudioPlayer?
    private var playerForLessThan0_5Meters: AVAudioPlayer?
    private var playerFor1To1_5Meters: AVAudioPlayer?
    private var playerFor1_5To2Meters: AVAudioPlayer?
    
    init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        guard let sound1 = Bundle.main.url(forResource: "two_steps_ahead", withExtension: "mp3"),
              let sound2 = Bundle.main.url(forResource: "one_step", withExtension: "mp3"),
              let sound3 = Bundle.main.url(forResource: "immediately_in_front", withExtension: "mp3"),
              let sound4 = Bundle.main.url(forResource: "damfool", withExtension: "mp3"),
              let sound5 = Bundle.main.url(forResource: "right_two_step", withExtension: "mp3"),
              let sound6 = Bundle.main.url(forResource: "right_one_step", withExtension: "mp3"),
              let sound7 = Bundle.main.url(forResource: "right_immediate", withExtension: "mp3"),
              let sound8 = Bundle.main.url(forResource: "left_two_step", withExtension: "mp3"),
              let sound9 = Bundle.main.url(forResource: "left_one_step", withExtension: "mp3"),
              let sound10 = Bundle.main.url(forResource: "left_immediate", withExtension: "mp3")
        else {
            print("Error: Could not find one or more audio files.")
            return
        }
        
        do {
            playerForLessThan0_1Meters = try AVAudioPlayer(contentsOf: sound4)
            playerForLessThan0_5Meters = try AVAudioPlayer(contentsOf: sound3)
            playerFor1To1_5Meters = try AVAudioPlayer(contentsOf: sound2)
            playerFor1_5To2Meters = try AVAudioPlayer(contentsOf: sound1)
            
            playerForLessThan0_1Meters?.prepareToPlay()
            playerForLessThan0_5Meters?.prepareToPlay()
            playerFor1To1_5Meters?.prepareToPlay()
            playerFor1_5To2Meters?.prepareToPlay()
        } catch {
            print("Error: Could not load the audio files. \(error.localizedDescription)")
        }
    }
    
    func playSoundForDistanceRange(_ range: DistanceRange) {
        stopAllSounds()  // Stop all sounds before playing the correct one
        
        switch range {
        case .lessThan0_1Meters:
            playerForLessThan0_1Meters?.play()
        case .lessThan0_5Meters:
            playerForLessThan0_5Meters?.play()
        case .between1And1_5Meters:
            playerFor1To1_5Meters?.play()
        case .between1_5And2Meters:
            playerFor1_5To2Meters?.play()
        }
    }
    
    func stopAllSounds() {
        playerForLessThan0_1Meters?.stop()
        playerForLessThan0_5Meters?.stop()
        playerFor1To1_5Meters?.stop()
        playerFor1_5To2Meters?.stop()
        
        // Reset the players to the beginning
        playerForLessThan0_1Meters?.currentTime = 0
        playerForLessThan0_5Meters?.currentTime = 0
        playerFor1To1_5Meters?.currentTime = 0
        playerFor1_5To2Meters?.currentTime = 0
    }
}

enum DistanceRange {
    case lessThan0_1Meters
    case lessThan0_5Meters
    case between1And1_5Meters
    case between1_5And2Meters
}
