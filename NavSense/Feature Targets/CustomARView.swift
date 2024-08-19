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
    var onDepthPointsUpdate: (([CGPoint?]) -> Void)?
    
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
        let leftX = centerX / 4
        let rightX = centerX + (centerX / 2) + leftX

        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        let centerPixelIndex = Int(centerY) * bytesPerRow / MemoryLayout<Float32>.stride + Int(centerX)
        let leftPixelIndex = Int(centerY) * bytesPerRow / MemoryLayout<Float32>.stride + Int(leftX)
        let rightPixelIndex = Int(centerY) * bytesPerRow / MemoryLayout<Float32>.stride + Int(rightX)

        let centerDepthValue = baseAddress[centerPixelIndex]
        let leftDepthValue = baseAddress[leftPixelIndex]
        let rightDepthValue = baseAddress[rightPixelIndex]
        
        let centerDistanceInMeters = Double(centerDepthValue)
        let leftDistanceInMeters = Double(leftDepthValue)
        let rightDistanceInMeters = Double(rightDepthValue)
        print("Distance to center point: \(centerDistanceInMeters) meters")
        print("Distance to left point: \(leftDistanceInMeters) meters")
        print("Distance to right point: \(rightDistanceInMeters) meters")

        // Convert to screen coordinates
        let centerPoint = CGPoint(x: CGFloat(centerX) / CGFloat(width) * bounds.width, y: CGFloat(centerY) / CGFloat(height) * bounds.height)
        let leftPoint = CGPoint(x: CGFloat(leftX) / CGFloat(width) * bounds.width, y: CGFloat(centerY) / CGFloat(height) * bounds.height)
        let rightPoint = CGPoint(x: CGFloat(rightX) / CGFloat(width) * bounds.width, y: CGFloat(centerY) / CGFloat(height) * bounds.height)

        // Pass the points to the SwiftUI view
        DispatchQueue.main.async {
            self.onDepthPointsUpdate?([centerPoint, leftPoint, rightPoint])
        }
    }
}
