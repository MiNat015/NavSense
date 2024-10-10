//
//  CustomARView.swift
//  NavSense
//
//  Created by BnY Innovators
//

import ARKit
import Combine
import RealityKit
import SwiftUI

class CustomARView: ARView, ARSessionDelegate {
    var onDepthPointsUpdate: (([CGPoint?]) -> Void)?
    var modelsForClassification: [ARMeshClassification: ModelEntity] = [:]
    var audioManager: AudioManager
    var lastRange: DistanceRange?
    var lastDistance : Double = 0.0
    var currentDistance : Double = 0.0
    private let distanceDelta : Double = 0.5
    private var lastUpdateTime: TimeInterval = 0
    private let updateInterval: TimeInterval = 0.3
    
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
        let updateTime = (abs(currentTime - lastUpdateTime) >= updateInterval)
        let updateDistance = (abs(currentDistance - lastDistance) >= distanceDelta)
        
        if (updateTime || updateDistance) {
            lastUpdateTime = currentTime
            testDepthData(session, didUpdate: frame)
        }
        
        return
        
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
        
        // Get height and width of the screen
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        let centerX = width / 2
        let centerY = height / 2
        let topY = centerY / 4
        let bottomY = centerY + (centerY / 2) //+ bottomY
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        // Initialize points on the screen to retrieve distance and class data
        // Current point resolution: 3
        let points : [Point]  = [
            Point(x: centerX, y: centerY, row: ScreenRow.MiddleRow), Point(x: centerX, y: bottomY, row: ScreenRow.BottomRow), Point(x: centerX, y: topY, row: ScreenRow.TopRow)
        ]
        
        // -- OBSTACLE DETECTION --
        
        var minDistance = Double.infinity
        // Initialize minPoint to be the middle Point on the screen
        var minPoint : Point = points[0]
        
        // Retrieve distances for each point of the screen
        for point in points {
            let idx = Int(point.y) * bytesPerRow / MemoryLayout<Float32>.stride + Int(point.x)
            let depthValue = baseAddress[idx]
            let distanceInMeters = Double(depthValue).rounded(toPlaces: 2)
            point.setPixelIndex(index: idx)
            point.setDistance(distance: distanceInMeters)
            
            // Set minPoint to equal the closest point
            if distanceInMeters < minDistance {
                minDistance = distanceInMeters
                minPoint = point
            }
            print(point)
        }
        
        // Convert to screen coordinates
        var cgPoints: [CGPoint] = []
        for point in points {
            cgPoints.append(CGPoint(x: CGFloat(point.x) / CGFloat(width) * bounds.width, y: CGFloat(point.y) / CGFloat(height) * bounds.height))
        }
        let minCGPoint = CGPoint(x: CGFloat(minPoint.x) / CGFloat(width) * bounds.width, y: CGFloat(minPoint.y) / CGFloat(height) * bounds.height)
        
        // -- OBSTACLE CLASSIFICATION --
        
        var objectClass: String = "None"
        // Classify object at the closest point on the mesh
        if let result = self.raycast(from: minCGPoint, allowing: .estimatedPlane, alignment: .any).first {
            
            var meshClassification: ARMeshClassification? = nil

            nearbyFaceWithClassification(to: result.worldTransform.position) { (centerOfFace, classification) in
                // ...
                print("Class:", classification.description)
                meshClassification = classification
                objectClass = meshClassification?.description ?? "None"
                
                // -- Assign a range to the point --
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
                
                // -- AUDIO FEEDBACK --
                
                // Only update and play sound if the range has changed
                if (abs(minDistance - self.lastDistance) >= 0.25) || (currentRange != self.lastRange) {
                    self.lastRange = currentRange
                    self.lastDistance = self.currentDistance
                    self.currentDistance = minDistance
                    if let range = currentRange {
                        self.audioManager.playSoundForDistanceRange(range, objectClass: objectClass)
                    } else {
                        self.audioManager.stopAllSounds()
                    }
                }

            }
        } else {
            print("Raycast Error")
        }
        
        // Pass the points to the SwiftUI view
        DispatchQueue.main.async {
            self.onDepthPointsUpdate?(cgPoints)
        }
    }
    
    /**
     * Function to classify point on the mesh.
     */
    func model(for classification: ARMeshClassification) -> ModelEntity {
                // Return cached model if available
        if let model = modelsForClassification[classification] {
            model.transform = .identity
            return model.clone(recursive: true)
        }
        
        // Generate 3D text for the classification
        let lineHeight: CGFloat = 0.05
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(classification.description, extrusionDepth: Float(lineHeight * 0.1), font: font)
        let textMaterial = SimpleMaterial(color: classification.color, isMetallic: true)
        let model = ModelEntity(mesh: textMesh, materials: [textMaterial])
        // Move text geometry to the left so that its local origin is in the center
        model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
        // Add model to cache
        modelsForClassification[classification] = model
        return model
    }
    
    /**
     * Function to classify faces near a point on the mesh.
     */
    func nearbyFaceWithClassification(to location: SIMD3<Float>, completionBlock: @escaping (SIMD3<Float>?, ARMeshClassification) -> Void) {
        guard let frame = self.session.currentFrame else {
            completionBlock(nil, .none)
            return
        }
    
        var meshAnchors = frame.anchors.compactMap({ $0 as? ARMeshAnchor })
        
        // Sort the mesh anchors by distance to the given location and filter out
        // any anchors that are too far away (4 meters is a safe upper limit).
        let cutoffDistance: Float = 4.0
        meshAnchors.removeAll { distance($0.transform.position, location) > cutoffDistance }
        meshAnchors.sort { distance($0.transform.position, location) < distance($1.transform.position, location) }

        // Perform the search asynchronously in order not to stall rendering.
        DispatchQueue.global().async {
            for anchor in meshAnchors {
                for index in 0..<anchor.geometry.faces.count {
                    // Get the center of the face so that we can compare it to the given location.
                    let geometricCenterOfFace = anchor.geometry.centerOf(faceWithIndex: index)
                    
                    // Convert the face's center to world coordinates.
                    var centerLocalTransform = matrix_identity_float4x4
                    centerLocalTransform.columns.3 = SIMD4<Float>(geometricCenterOfFace.0, geometricCenterOfFace.1, geometricCenterOfFace.2, 1)
                    let centerWorldPosition = (anchor.transform * centerLocalTransform).position
                     
                    // We're interested in a classification that is sufficiently close to the given location––within 5 cm.
                    let distanceToFace = distance(centerWorldPosition, location)
                    if distanceToFace <= 0.05 {
                        // Get the semantic classification of the face and finish the search.
                        let classification: ARMeshClassification = anchor.geometry.classificationOf(faceWithIndex: index)
                        completionBlock(centerWorldPosition, classification)
                        return
                    }
                }
            }
            
            // Let the completion block know that no result was found.
            completionBlock(nil, .none)
        }
    }
}
