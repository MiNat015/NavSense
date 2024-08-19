//
//  ContentView.swift
//  NavSense
//
//  Created by Arjun Srikanth on 7/8/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var depthPoints: [CGPoint?] = [nil, nil, nil]
    
    var body: some View {
        ZStack {
            CustomARViewRepresentable(depthPoints: $depthPoints)
                .ignoresSafeArea()
                    
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
