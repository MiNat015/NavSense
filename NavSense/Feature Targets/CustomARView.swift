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

class CustomARView: ARView {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
}
