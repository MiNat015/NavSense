//
//  CustomARView.swift
//  NavSense
//
//  Created by Arjun Srikanth on 7/8/2024.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

class CustomARView: ARView, ARSessionDelegate {
    var onDepthPointUpdate: ((CGPoint?) -> Void)?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.session.delegate = self
        print("CustomARView initialized")
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        print("AR session did update")
        testDepthData(session, didUpdate: frame)
    }
    
    func testDepthData(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let sceneDepth = frame.smoothedSceneDepth ?? frame.sceneDepth else {
                print("Failed to acquire scene depth.")
                return
        }
            
        let pixelBuffer = sceneDepth.depthMap
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }
            
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)?.assumingMemoryBound(to: Float32.self) else {
                print("Base address is not valid.")
                return
            }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
                            
        let centerX = width / 2
        let centerY = height / 2

        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let pixelIndex = Int(centerY) * bytesPerRow / MemoryLayout<Float32>.stride + Int(centerX)
                            
        let depthValue = baseAddress[pixelIndex]
                            
        let distanceInMeters = Double(depthValue)
        print("Distance to center point: \(distanceInMeters) meters")
        
        // Convert to screen coordinates
        let depthPoint = CGPoint(x: CGFloat(centerX) / CGFloat(width) * bounds.width,
                                y: CGFloat(centerY) / CGFloat(height) * bounds.height)
        
        DispatchQueue.main.async {
            self.onDepthPointUpdate?(depthPoint)
        }
    }
}
