//
//  CGPoint+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation
import CoreGraphics

public extension CGPoint {
    /**
     Returns the scaled integral point of the current CGPoint.
     The x and y values are scaled based on the current device's screen scale.
     
     - Returns: The scaled integral CGPoint.
     */
    var scaledIntegral: CGPoint {
        CGPoint(x: x.scaledIntegral, y: y.scaledIntegral)
    }
}

internal extension CGPoint {
    
    /// Creates a point with the specified x and y value.
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }

    /// Creates a point with the specified x and y value.
    init(_ xY: CGFloat) {
        self.init(x: xY, y: xY)
    }
    
    /**
     Returns a new CGPoint by offsetting the current point by the specified offset.
     
     - Parameters:
        - offset: The CGPoint offset to be applied.
     
     - Returns: The new CGPoint obtained by offsetting the current point.
     */
    func offset(by offset: CGPoint) -> CGPoint {
        return CGPoint(x: x + offset.x, y: y + offset.y)
    }
    
    /**
     Returns a new CGPoint by offsetting the current point along the x-axis by the specified value.
     
     - Parameters:
        - x: The value to be added to the x-coordinate of the current point.
     
     - Returns: The new CGPoint obtained by offsetting the current point along the x-axis.
     */
    func offset(x: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: y)
    }
    
    /**
     Returns a new CGPoint by offsetting the current point by the specified values along the x and y axes.
     
     - Parameters:
        - x: The value to be added to the x-coordinate of the current point.
        - y: The value to be added to the y-coordinate of the current point.
     
     - Returns: The new CGPoint obtained by offsetting the current point by the specified values.
     */
    func offset(x: CGFloat = 0, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
    
    /**
     Returns the distance between the current point and the specified point.
     
     - Parameters:
        - point: The target CGPoint.
     
     - Returns: The distance between the current point and the specified point.
     */
    func distance(to point: CGPoint) -> CGFloat {
        let xdst = x - point.x
        let ydst = y - point.y
        return sqrt((xdst * xdst) + (ydst * ydst))
    }
    
    /**
     Returns a new CGPoint with rounded x and y values using the specified rounding rule.
     
     - Parameters:
        - rule: The rounding rule to be applied. The default value is `.toNearestOrAwayFromZero`.
     
     - Returns: The new CGPoint with rounded x and y values.
     */
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGPoint {
        return CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }
    
    /// The point as `CGSize`, using the x-coordinate as width and y-coordinate as height.
    var size: CGSize {
        CGSize(x, y)
    }
}


extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

public extension CGPoint {
    static func + (l: CGPoint, r: CGPoint) -> CGPoint {
        return CGPoint(l.x + r.x, l.y + r.y)
    }

    static func + (l: CGPoint, r: CGFloat) -> CGPoint {
        return CGPoint(l.x + r, l.y + r)
    }

    static func + (l: CGPoint, r: Double) -> CGPoint {
        return CGPoint(l.x + r, l.y + r)
    }

    static func - (l: CGPoint, r: CGPoint) -> CGPoint {
        return CGPoint(l.x - r.x, l.y - r.y)
    }

    static func - (l: CGPoint, r: CGFloat) -> CGPoint {
        return CGPoint(l.x - r, l.y - r)
    }

    static func - (l: CGPoint, r: Double) -> CGPoint {
        return CGPoint(l.x - r, l.y - r)
    }

    static func * (l: CGPoint, r: CGFloat) -> CGPoint {
        return CGPoint(x: l.x * r, y: l.y * r)
    }

    static func * (l: CGFloat, r: CGPoint) -> CGPoint {
        return CGPoint(x: l * r.x, y: l * r.y)
    }

    static func * (l: CGPoint, r: Double) -> CGPoint {
        return CGPoint(x: l.x * CGFloat(r), y: l.y * CGFloat(r))
    }

    static func * (l: Double, r: CGPoint) -> CGPoint {
        return CGPoint(x: CGFloat(l) * r.x, y: CGFloat(l) * r.y)
    }

    static func * (l: CGPoint, r: CGPoint) -> CGFloat {
        return l.x * r.x + l.y * r.y
    }

    static func / (l: CGPoint, r: CGFloat) -> CGPoint {
        return CGPoint(x: l.x / r, y: l.y / r)
    }

    static func / (l: CGPoint, r: Double) -> CGPoint {
        return CGPoint(x: l.x / CGFloat(r), y: l.y / CGFloat(r))
    }

    static func += (l: inout CGPoint, r: CGPoint) {
        l = CGPoint(x: l.x + r.x, y: l.y + r.y)
    }

    static func += (l: inout CGPoint, r: Double) {
        l = CGPoint(x: l.x + r, y: l.y + r)
    }

    static func += (l: inout CGPoint, r: CGFloat) {
        l = CGPoint(x: l.x + r, y: l.y + r)
    }

    static func -= (l: inout CGPoint, r: CGPoint) {
        l = CGPoint(x: l.x - r.x, y: l.y - r.y)
    }

    static func -= (l: inout CGPoint, r: Double) {
        l = CGPoint(x: l.x - r, y: l.y - r)
    }

    static func -= (l: inout CGPoint, r: CGFloat) {
        l = CGPoint(x: l.x - r, y: l.y - r)
    }

    static func *= (l: inout CGPoint, r: CGFloat) {
        l = CGPoint(x: l.x * r, y: l.y * r)
    }

    static func *= (l: inout CGPoint, r: Double) {
        l = CGPoint(x: l.x * CGFloat(r), y: l.y * CGFloat(r))
    }
}
