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
    @Binding var depthPoints: [CGPoint?]
    @ObservedObject var audioManager: AudioManager
    
    func makeUIView(context: Context) -> some UIView {
        let view = CustomARView(audioManager: audioManager) // Uses convenience initialiser of class
        view.onDepthPointsUpdate = { points in
            DispatchQueue.main.async {
                self.depthPoints = points
            }
        }
        
        // Start AR session
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        // Enable mesh construction and classification
        config.sceneReconstruction = .meshWithClassification
        // Smooth depth data measures distance in a more stable manner
        config.frameSemantics = .smoothedSceneDepth
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        
        print("AR session started")

        // Add coaching overlay (optional)
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)
        
        // Set debug options
        #if DEBUG
        /* Uncomment to view planes and anchor points */
        // view.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
        
        /* Uncomment to view meshes */
        view.debugOptions = [.showSceneUnderstanding]
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
        
    class Coordinator: NSObject {
        var representable: CustomARViewRepresentable
            
        init(_ representable: CustomARViewRepresentable) {
            self.representable = representable
        }
    }
}

