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
    var audioManager: AudioManager
    var lastRange: DistanceRange?
    var lastDistance : Double = 0.0
    private var lastUpdateTime: TimeInterval = 0
    private let updateInterval: TimeInterval = 0.1
    
    required init(frame frameRect: CGRect) {
        self.audioManager = AudioManager()
        super.init(frame: frameRect)
        self.session.delegate = self
        print("CustomARView initialized")
    }
    
    required init(frame frameRect: CGRect, audioManager: AudioManager) {
        self.audioManager = audioManager
        super.init(frame: frameRect)
        self.session.delegate = self
        print("CustomARView initialized")
    }

    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(audioManager: AudioManager) {
        self.init(frame: UIScreen.main.bounds, audioManager: audioManager)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTime = frame.timestamp
        guard abs(currentTime - lastUpdateTime) >= updateInterval else { return }
        lastUpdateTime = currentTime
                
        testDepthData(session, didUpdate: frame)
    }
    
    func testDepthData(_ session: ARSession, didUpdate frame: ARFrame) {
        // Check if ARKit has acquired the mesh
        guard let sceneDepth = frame.smoothedSceneDepth ?? frame.sceneDepth else {
            print("Failed to acquire scene depth.")
            return
        }
        
        let pixelBuffer = sceneDepth.depthMap
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }
        
        // Check for valid pixel base address
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)?.assumingMemoryBound(to: Float32.self) else {
            print("Base address is not valid.")
            return
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        let centerX = width / 2
        let centerY = height / 2
        let topY = centerY / 4
        let bottomY = centerY + (centerY / 2) //+ bottomY
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        let points : [Point]  = [
            Point(x: centerX, y: centerY, row: ScreenRow.MiddleRow), Point(x: centerX, y: bottomY, row: ScreenRow.BottomRow), Point(x: centerX, y: topY, row: ScreenRow.TopRow)
        ]
        
        var minDistance = Double.infinity
        var minPoint : Point
        
        for point in points {
            let idx = Int(point.y) * bytesPerRow / MemoryLayout<Float32>.stride + Int(point.x)
            let depthValue = baseAddress[idx]
            let distanceInMeters = Double(depthValue).rounded(toPlaces: 2)
            point.setPixelIndex(index: idx)
            point.setDistance(distance: distanceInMeters)
            
            if distanceInMeters < minDistance {
                minDistance = distanceInMeters
                minPoint = point
            }
            
            print(point)
        }
        
        var currentRange: DistanceRange?
        
        if minDistance < 0.1 {
            currentRange = .lessThan0_1Meters
        } else if minDistance < 0.5 {
            currentRange = .lessThan0_5Meters
        } else if minDistance < 1.5 {
            currentRange = .between1And1_5Meters
        } else if minDistance < 2.0 {
            currentRange = .between1_5And2Meters
        }
        
        // Only update and play sound if the range has changed
        if (abs(minDistance - lastDistance) >= 0.25) || (currentRange != lastRange) {
            lastRange = currentRange
            lastDistance = minDistance
            if let range = currentRange {
                audioManager.playSoundForDistanceRange(range)
            } else {
                audioManager.stopAllSounds()
            }
        }

        // Convert to screen coordinates
        var cgPoints: [CGPoint] = []
        for point in points {
            cgPoints.append(CGPoint(x: CGFloat(point.x) / CGFloat(width) * bounds.width, y: CGFloat(point.y) / CGFloat(height) * bounds.height))
        }
        
        // Pass the points to the SwiftUI view
        DispatchQueue.main.async {
            self.onDepthPointsUpdate?(cgPoints)
        }
    }
}

class Point : CustomStringConvertible {
    var x : Int
    var y : Int
    var distanceInMeters : Double
    var pixelIndex : Int
    var row : ScreenRow
    
    var description: String {
        if self.row == ScreenRow.BottomRow {
            return "Bottom Row [\(self.x), \(self.y)]: \(self.distanceInMeters)"
        } else if self.row == ScreenRow.TopRow {
            return "Top Row [\(self.x), \(self.y)]: \(self.distanceInMeters)"
        }
        return "Middle Row [\(self.x), \(self.y)]: \(self.distanceInMeters)"
    }
    
    required init(x: Int, y: Int, row: ScreenRow) {
        self.x = x
        self.y = y
        self.distanceInMeters = 0.0
        self.pixelIndex = -1
        self.row = row
    }
    
    func setX(newX: Int) {
        self.x = newX
    }
    
    func setY(newY: Int) {
        self.y = newY
    }

    func setDistance(distance: Double) {
        self.distanceInMeters = distance
    }
    
    func setPixelIndex(index: Int) {
        self.pixelIndex = index
    }
}

enum ScreenRow {
    case TopRow
    case MiddleRow
    case BottomRow
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
