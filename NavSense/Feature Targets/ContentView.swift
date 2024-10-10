//
//  ContentView.swift
//  NavSense
//
//  Created by BnY Innovators
//

import SwiftUI

struct ContentView: View {
    @State private var depthPoints: [CGPoint?] = [nil, nil, nil] // Store all depth points
    @StateObject private var audioManager = AudioManager()
    @StateObject private var speechManager = SpeechManager() // Use SpeechManager
    @State private var isSettingsOpen = false
    @State private var isNavigationOpen = false
    @State private var brightness: CGFloat = 0.5
    @State private var volume: CGFloat = 0.5

    var body: some View {
        ZStack {
            CustomARViewRepresentable(depthPoints: $depthPoints, audioManager: audioManager)
                .ignoresSafeArea()
                .brightness(Double(brightness - 0.5)) // Adjust brightness

                // Iterate over the depth points and draw it on the screen
                ForEach(depthPoints.indices, id: \.self) { index in
                    if let point = depthPoints[index] {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .position(point)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Button(action: {
                                isSettingsOpen.toggle()
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            Button(action: {
                                isNavigationOpen.toggle()
                            }) {
                                Image(systemName: "location.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        Spacer()
                    }
                }

                if isSettingsOpen {
                    SettingsView(brightness: $brightness, isSettingsOpen: $isSettingsOpen, volume: $volume)
                        .frame(width: 300, height: 250)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                        .position(x: UIScreen.main.bounds.width / 2, y: 200)
                }

                if isNavigationOpen {
                    NavigationView(isNavigationOpen: $isNavigationOpen)
                        .frame(width: 300, height: 150)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                        .position(x: UIScreen.main.bounds.width / 2, y: 400)
                }

                // Add a button for controlling the mic
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            audioManager.stopAllSounds()
                            if speechManager.isListening {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    speechManager.stopListening()
                                    audioManager.speakText("Mic off")
                                }
                            } else {
                                audioManager.speakText("Mic on")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    speechManager.startListening(audioManager: audioManager)
                                }
                            }
                      
                        }) {
                            Image(systemName: speechManager.isListening ? "mic.fill" : "mic.slash.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                speechManager.requestSpeechAuthorization()
                speechManager.onCommandRecognized = { command in
                    if command == "toggleSettings" {
                        isSettingsOpen = !isSettingsOpen
                    } else if command == "toggleNavigation" {
                        isNavigationOpen = !isNavigationOpen
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
