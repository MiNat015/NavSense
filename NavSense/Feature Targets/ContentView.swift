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

    
    var body: some View {
        ZStack {
            CustomARViewRepresentable(depthPoints: $depthPoints, audioManager: audioManager)
                .ignoresSafeArea()
                    
            // Iterate over the depth points and draw it on the screen
            ForEach(depthPoints.indices, id: \.self) { index in
                if let point = depthPoints[index] {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .position(point)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
