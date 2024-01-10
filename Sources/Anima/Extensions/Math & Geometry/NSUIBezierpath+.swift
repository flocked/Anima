//
//  NSUIBezierpath+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if os(macOS)

extension NSBezierPath {
    /**
     Creates and returns a new Bézier path object with a rectangular path rounded at the specified corners.
     
     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - corners: A bitmask value that identifies the corners that you want rounded. You can use this parameter to round only a subset of the corners of the rectangle.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
     
     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSRectCorner, cornerRadius radius: CGFloat) {

        self.init()

        let radius = radius.clamped(to: 0...(min(rect.width, rect.height) / 2))

        let topLeft = NSPoint(x: rect.minX, y: rect.minY)
        let topRight = NSPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = NSPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = NSPoint(x: rect.minX, y: rect.maxY)
        self.move(to: topLeft.offset(x: 0, y: radius))
        self.appendArc(from: topLeft, to: topRight, radius: corners.contains(.topLeft) ? radius : 0)
        self.appendArc(from: topRight, to: bottomRight, radius: corners.contains(.topRight) ? radius : 0)
        self.appendArc(from: bottomRight, to: bottomLeft, radius: corners.contains(.bottomRight) ? radius : 0)
        self.appendArc(from: bottomLeft, to: topLeft, radius: corners.contains(.bottomLeft) ? radius : 0)
        self.close()
    }

    /**
     Creates and returns a new Bézier path object with a rounded rectangular path.
     
     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
     
     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadius: cornerRadius)
    }

    /**
     The Core Graphics representation of the path.
     
     This property contains a snapshot of the path at any given point in time. Getting this property returns an immutable path object that you can pass to Core Graphics functions. The path object itself is owned by the `NSBezierPath` object and is valid only until you make further modifications to the path.
     
     You can set the value of this property to a path you built using the functions of the Core Graphics framework. When setting a new path, this method makes a copy of the path you provide.
     */
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            case .lineTo:
                path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
            case .curveTo:
                path.addCurve(
                    to: CGPoint(x: points[2].x, y: points[2].y),
                    control1: CGPoint(x: points[0].x, y: points[0].y),
                    control2: CGPoint(x: points[1].x, y: points[1].y)
                )
            case .closePath:
                path.closeSubpath()
            default:
                break
            }
        }
        return path
    }
}

/**
 The corners of a rectangle.

 The specified constants reflect the corners of a rectangle that has not been modified by an affine transform and is drawn in the default coordinate system (where the origin is in the upper-left corner and positive values extend down and to the right).
 */
struct NSRectCorner: OptionSet, Sendable {
    public let rawValue: UInt
    /// The top-left corner of the rectangle.
    public static let topLeft = NSRectCorner(rawValue: 1 << 0)
    /// The top-right corner of the rectangle.
    public static let topRight = NSRectCorner(rawValue: 1 << 1)
    /// The bottom-left corner of the rectangle.
    public static let bottomLeft = NSRectCorner(rawValue: 1 << 2)
    /// The bottom-right corner of the rectangle.
    public static let bottomRight = NSRectCorner(rawValue: 1 << 3)
    /// All corners of the rectangle.
    public static var allCorners: NSRectCorner {
        return [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    /// Creates a structure that represents the corners of a rectangle.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}
#endif
