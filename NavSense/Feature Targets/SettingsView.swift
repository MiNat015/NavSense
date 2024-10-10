//
//  SettingsView.swift
//  NavSense
//
//  Created by BnY Innovators
//

import SwiftUI
import AVFoundation
import UIKit

/**
 UI for Settings
 */
struct SettingsView: View {
    @Binding var brightness: CGFloat
    @Binding var isSettingsOpen: Bool
    @Binding var volume: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Spacer()
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.bottom, 5)

            HStack {
                Image(systemName: "sun.max.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.yellow)
                Text("Brightness")
                    .font(.headline)
                Spacer()
                Slider(value: $brightness, in: 0...1, onEditingChanged: { _ in
                    UIScreen.main.brightness = brightness
                })
                    .accentColor(.yellow)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack {
                Image(systemName: "speaker.wave.3.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.green)
                Text("Volume")
                    .font(.headline)
                Spacer()
                Slider(value: $volume, in: 0...1)
                    .accentColor(.green)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack {
                Spacer()
                Button(action: {
                    isSettingsOpen = false
                }) {
                    Text("Close")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                Spacer()
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear {
            brightness = UIScreen.main.brightness
        }
    }
}
