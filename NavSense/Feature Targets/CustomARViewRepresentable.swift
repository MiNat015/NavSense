//
//  CustomARViewRepresentable.swift
//  NavSense - Wrapper struct for CustomARView
//
//  Created by Arjun Srikanth on 7/8/2024.
//

import SwiftUI
import RealityKit
import ARKit

struct CustomARViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = CustomARView() // Uses convenience initialiser of class
        
        // Start AR session
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        // Add coaching overlay (optional)
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)
        
        // Set debug options
        #if DEBUG
        view.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

