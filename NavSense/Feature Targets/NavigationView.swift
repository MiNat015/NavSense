//
//  NavigationView.swift
//  NavSense
//
//  Created by BnY Innovators
//

import SwiftUI

/**
 UI for Navigation Feature
 */
struct NavigationView: View {
    @Binding var isNavigationOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Spacer()
                Text("Navigation")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Spacer()
            }
            .padding(.bottom, 5)

            HStack {
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.orange)
                Text("Navigate to Kitchen")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Add kitchen navigation action here
                }) {
                    Text("Go")
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack {
                Image(systemName: "bed.double.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.blue)
                Text("Navigate to Bedroom")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Add bedroom navigation action here
                }) {
                    Text("Go")
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack {
                Spacer()
                Button(action: {
                    isNavigationOpen = false
                }) {
                    Text("Close")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                Spacer()
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
