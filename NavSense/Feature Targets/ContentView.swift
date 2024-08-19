//
//  ContentView.swift
//  NavSense
//
//  Created by Arjun Srikanth on 7/8/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var depthPoint: CGPoint? = nil
    
    var body: some View {
        ZStack {
            CustomARViewRepresentable(depthPoint: $depthPoint)
                .ignoresSafeArea()
                    
            if let point = depthPoint {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .position(point)
                }
        }
    }
}

#Preview {
    ContentView()
}
