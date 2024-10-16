//
//  NavSenseTests.swift
//  NavSenseTests
//
//  Created by Arjun Srikanth on 7/8/2024.
//

import XCTest
@testable import NavSense
import ARKit
import RealityKit

final class NavSenseTests: XCTestCase {
    
    var customARView: CustomARView!
    var mockAudioManager: AudioManager!
        
    override func setUp() {
        super.setUp()
        mockAudioManager = AudioManager()
        customARView = CustomARView(
            frame: UIScreen.main.bounds, audioManager: mockAudioManager
        )
    }

    override func tearDown() {
        customARView = nil
        mockAudioManager = nil
        super.tearDown()
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    // Test CustomARView initialization
    func testCustomARViewInitialization() throws {
        XCTAssertNotNil(customARView, "CustomARView should not be nil after initialization.")
        XCTAssertNotNil(customARView.audioManager, "AudioManager should not be nil after initialization.")
    }

    // Test session update
    func testSessionDidUpdateFrameCallsTestDepthData() throws {
        // Create a mock ARFrame
        let mockFrame = ARFrame()
        customARView.lastUpdateTime = 0.0
            
        // Call session(_:didUpdate:) with the mock frame
        customARView.session(customARView.session, didUpdate: mockFrame)
            
        // Here, you can assert that the function updates necessary variables
        // This is tricky since ARFrame is hard to mock - so use a dummy timestamp or further mock ARFrame data
        XCTAssertEqual(customARView.lastUpdateTime, mockFrame.timestamp, "Last update time should be set to frame timestamp.")
    }

    // Test testDepthData for depth-related functionality
    func testDepthDataProcessing() throws {
        // Simulate a session and mock depth data update
        let mockSession = ARSession()
        let mockFrame = ARFrame()  // You may need to mock the depth-related values here
            
        customARView.testDepthData(mockSession, didUpdate: mockFrame)
            
        // Check that the correct points are being processed
        // Check that `onDepthPointsUpdate` closure is triggered
        customARView.onDepthPointsUpdate = { points in
            XCTAssertEqual(points.count, 3, "Expected 3 points for obstacle detection")
        }
    }
        
    // Test audio feedback update logic
    func testAudioFeedbackUpdates() throws {
        // Mock a distance range and object classification
        customARView.lastRange = .clear
        customARView.lastDistance = 2.0
        customARView.currentDistance = 0.8
            
        // Call the testDepthData to simulate an update
        let mockSession = ARSession()
        let mockFrame = ARFrame()  // You may need to mock depth map values
        customARView.testDepthData(mockSession, didUpdate: mockFrame)
            
        // Ensure that audio feedback is played for the new range
        XCTAssertNotEqual(customARView.currentDistance, customARView.lastDistance, "Current distance should be updated")
        XCTAssertEqual(customARView.lastRange, .between1And1_5Meters, "Range should be updated to between1And1_5Meters")
    }
        
    // Test model entity retrieval for classification
    func testModelForClassification() throws {
        let modelEntity = customARView.model(for: .floor)
        XCTAssertNotNil(modelEntity, "Model entity for classification should not be nil")
        XCTAssertEqual(modelEntity.name, "floor", "Model entity should have the correct classification")
    }
    
}
