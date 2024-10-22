//
//  HapticManager.swift
//  NavSense
//
//  Created by Arjun Srikanth on 22/10/2024.
//

import Foundation
import UIKit

class HapticManager {
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    init() {
        // Prepare the haptic generators
        lightImpact.prepare()
        heavyImpact.prepare()
    }
    
    func triggerLightImpact() {
        lightImpact.impactOccurred()
    }
    
    func triggerHeavyImpact() {
        heavyImpact.impactOccurred()
    }
}
