//
//  Point.swift
//  NavSense
//
//  Created by Arjun Srikanth on 9/10/2024.
//

import Foundation

/**
 * Represents a point on the screen.
 */
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
