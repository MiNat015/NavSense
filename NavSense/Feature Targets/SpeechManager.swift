//
//  SpeechManager.swift
//  NavSense
//
//  Created by BnY Innovators
//

import Foundation
import Speech
import AVFoundation
import UIKit

/**
 Handles microphone controls and voice commands
 */
class SpeechManager: ObservableObject {
    @Published var isListening = false
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-AU"))
    private let audioEngine = AVAudioEngine()
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    var onCommandRecognized: ((String) -> Void)?

    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.isListening = false
                case .denied, .restricted, .notDetermined:
                    self.isListening = false
                @unknown default:
                    self.isListening = false
                }
            }
        }
    }

    func toggleListening(audioManager: AudioManager) {
        if isListening {
            stopListening()
        } else {
            startListening(audioManager: audioManager)
        }
    }

    func startListening(audioManager: AudioManager) {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try audioSession.setMode(.measurement) // Use a mode that reduces audio interference
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session category: \(error)")
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine couldn't start: \(error)")
        }

        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            guard let result = result else {
                if let error = error {
                    print("Recognition error: \(error)")
                }
                return
            }

            let spokenText = result.bestTranscription.formattedString.lowercased()
            self.handleVoiceCommand(command: spokenText)
        }

        isListening = true
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil

        resetAudioSession() // Reset audio session to use main speaker
        isListening = false
    }

    private func resetAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to reset audio session: \(error)")
        }
    }

    func handleVoiceCommand(command: String) {
        DispatchQueue.main.async {
            if command.contains("settings") {
                self.onCommandRecognized?("toggleSettings")
            } else if command.contains("navigation") {
                self.onCommandRecognized?("toggleNavigation")
            }
        }
    }
}
