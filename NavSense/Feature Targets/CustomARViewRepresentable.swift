//
//  CustomARViewRepresentable.swift
//  NavSense
//
//  Created by Arjun Srikanth on 7/8/2024.
//

import SwiftUI

struct CustomARViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        return CustomARView() // Uses convenience initialiser of class
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

