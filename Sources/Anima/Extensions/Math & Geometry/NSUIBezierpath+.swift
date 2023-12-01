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

internal extension NSBezierPath {
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
     Creates and returns a new Bézier path object with a rectangular path with variable rounded corners.
     
     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - topLeft: The top left corner radius.
        - topRight: The top right corner radius.
        - bottomLeft: The bottom left corner radius.
        - bottomRight: The bottom right corner radius.

     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.init()
        var pt = CGPoint.zero
        
        // top-left corner plus top-left radius
        pt.x = topLeft
        pt.y = 0
        self.move(to: pt)
        
        pt.x = rect.maxX - topRight
        pt.y = 0
        // add "top line"
        self.line(to: pt)
        
        pt.x = rect.maxX - topRight
        pt.y = topRight
        // add "top-right corner"
        self.appendArc(withCenter: pt, radius: topRight, startAngle: .pi * 1.5, endAngle: 0, clockwise: true)
        
        pt.x = rect.maxX
        pt.y = rect.maxY - bottomRight
        // add "right-side line"
        self.line(to: pt)
        
        pt.x = rect.maxX - bottomRight
        pt.y = rect.maxY - bottomRight
        // add "bottom-right corner"
        self.appendArc(withCenter: pt, radius: bottomRight, startAngle: 0, endAngle:  .pi * 0.5, clockwise: true)
        
        pt.x = bottomLeft
        pt.y = rect.maxY
        // add "bottom line"
        self.line(to: pt)
        
        pt.x = bottomLeft
        pt.y = rect.maxY - bottomLeft
        // add "bottom-left corner"
        self.appendArc(withCenter: pt, radius: bottomLeft, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
        
        pt.x = 0
        pt.y = topLeft
        // add "left-side line"
        self.line(to: pt)
        
        pt.x = topLeft
        pt.y = topLeft
        // add "top-left corner"
        self.appendArc(withCenter: pt, radius: topLeft, startAngle: .pi , endAngle:  .pi * 1.5, clockwise: true)
        
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
     Creates and returns a new Bézier path object with the contents of a Core Graphics path.
     
     - Parameters cgPath: The Core Graphics path from which to obtain the initial path information. If this parameter is nil, the method raises an exception.
     - Returns: A new path object with the specified path information.
     */
    convenience init(cgPath: CGPath) {
        self.init()
        cgPath.applyWithBlock { elementPointer in
            let element: CGPathElement = elementPointer.pointee
            let point: CGPoint = element.points.pointee
            switch element.type {
            case .moveToPoint:
                move(to: point)
            case .addLineToPoint:
                line(to: point)
            case .addQuadCurveToPoint:
                let currentPoint: CGPoint = cgPath.currentPoint
                // TODO: - Double check `/ 3`
                let x: CGFloat = (currentPoint.x + 2 * point.x) / 3
                let y: CGFloat = (currentPoint.y + 2 * point.y) / 3
                let interpolatedPoint = CGPoint(x: x, y: y)
                let endPoint: CGPoint = element.points.successor().pointee
                curve(to: endPoint,
                      controlPoint1: interpolatedPoint,
                      controlPoint2: interpolatedPoint)
            case .addCurveToPoint:
                let midPoint: CGPoint = element.points.successor().pointee
                let endPoint: CGPoint = element.points.successor().successor().pointee
                curve(to: endPoint,
                      controlPoint1: point,
                      controlPoint2: midPoint)
            case .closeSubpath:
                close()
            default:
                break
            }
        }
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
    
    /**
     Returns a new Bézier path object with a rounded rectangular path.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
     
     - Returns: A new path object with the rounded rectangular path.
     */
    static func superellipse(in rect: CGRect, cornerRadius: Double) -> Self {
        let minSide = min(rect.width, rect.height)
        let radius = min(cornerRadius, minSide / 2)
        
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        // Top side (clockwise)
        let point1 = CGPoint(x: rect.minX + radius, y: rect.minY)
        let point2 = CGPoint(x: rect.maxX - radius, y: rect.minY)
        
        // Right side (clockwise)
        let point3 = CGPoint(x: rect.maxX, y: rect.minY + radius)
        let point4 = CGPoint(x: rect.maxX, y: rect.maxY - radius)
        
        // Bottom side (clockwise)
        let point5 = CGPoint(x: rect.maxX - radius, y: rect.maxY)
        let point6 = CGPoint(x: rect.minX + radius, y: rect.maxY)
        
        // Left side (clockwise)
        let point7 = CGPoint(x: rect.minX, y: rect.maxY - radius)
        let point8 = CGPoint(x: rect.minX, y: rect.minY + radius)
        
        let path = self.init()
        path.move(to: point1)
        path.line(to: point2)
        path.curve(to: point3, controlPoint1: topRight, controlPoint2: topRight)
        path.line(to: point4)
        path.curve(to: point5, controlPoint1: bottomRight, controlPoint2: bottomRight)
        path.line(to: point6)
        path.curve(to: point7, controlPoint1: bottomLeft, controlPoint2: bottomLeft)
        path.line(to: point8)
        path.curve(to: point1, controlPoint1: topLeft, controlPoint2: topLeft)
        return path
    }
    
    /**
     Returns a new Bézier path object with a squircle rectangular path.
     
     - Parameters rect: The rectangle that defines the basic shape of the path.
     - Returns: A new path object with the squircle rectangular path.
     */
    static func squircle(rect: CGRect) -> Self {
        assert(rect.width == rect.height)
        return superellipse(in: rect, cornerRadius: rect.width / 2)
    }
    
    func rotationTransform(byRadians radians: Double, centerPoint point: CGPoint) -> AffineTransform {
        var transform = AffineTransform()
        transform.translate(x: point.x, y: point.y)
        transform.rotate(byRadians: radians)
        transform.translate(x: -point.x, y: -point.y)
        return transform
    }
    
    /**
     Returns a new path which is rotated by the specified radians.
     
     - Parameters:
        - radians: The radians of rotation.
        - centerPoint: The center point of the rotation.
     - Returns: A new path rotated path.
     */
    func rotating(byRadians radians: Double, centerPoint point: CGPoint) -> Self {
        let path = self.copy() as! Self
        
        guard radians != 0 else {
            return path
        }
        
        let transform = rotationTransform(byRadians: radians, centerPoint: point)
        path.transform(using: transform)
        return path
    }
}
#endif

#if canImport(UIKit)
internal extension NSUIBezierPath {
    /**
     Creates and returns a new Bézier path object with a rectangular path rounded at the specified corners.
     
     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - corners: A bitmask value that identifies the corners that you want rounded. You can use this parameter to round only a subset of the corners of the rectangle.
        - cornerRadius: The radius of each corner oval. A value of 0 results in a rectangle without rounded corners. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
     
     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: NSUIRectCorner, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    }
    
    /**
     Creates and returns a new Bézier path object with a rectangular path with variable rounded corners.
     
     This method creates a closed subpath, proceeding in a clockwise direction (relative to the default coordinate system) as it creates the necessary line and curve segments.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - topLeft: The top left corner radius.
        - topRight: The top right corner radius.
        - bottomLeft: The bottom left corner radius.
        - bottomRight: The bottom right corner radius.

     - Returns: A new path object with the rounded rectangular path.
     */
    convenience init(roundedRect rect: CGRect, topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.init()
        
        var pt = CGPoint.zero
                        
            // top-left corner plus top-left radius
            pt.x = topLeft
            pt.y = 0
            
            self.move(to: pt)
            
            pt.x = bounds.maxX - topRight
            pt.y = 0
            
            // add "top line"
        self.addLine(to: pt)
            
            pt.x = bounds.maxX - topRight
            pt.y = topRight

            // add "top-right corner"
        self.addArc(withCenter: pt, radius: topRight, startAngle: .pi * 1.5, endAngle: 0, clockwise: true)
            
            pt.x = bounds.maxX
            pt.y = bounds.maxY - bottomRight
            
            // add "right-side line"
        self.addLine(to: pt)
            
            pt.x = bounds.maxX - bottomRight
            pt.y = bounds.maxY - bottomRight
            
            // add "bottom-right corner"
        self.addArc(withCenter: pt, radius: bottomRight, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
            
            pt.x = bottomLeft
            pt.y = bounds.maxY
            
            // add "bottom line"
        self.addLine(to: pt)
            
            pt.x = bottomLeft
            pt.y = bounds.maxY - bottomLeft
            
            // add "bottom-left corner"
        self.addArc(withCenter: pt, radius: bottomLeft, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
            
            pt.x = 0
            pt.y = topLeft
            
            // add "left-side line"
        self.addLine(to: pt)
            
            pt.x = topLeft
            pt.y = topLeft
            
            // add "top-left corner"
        self.addArc(withCenter: pt, radius: topLeft, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
            
        self.close()
    }
}
#endif

#if os(macOS) || os(iOS) || os(tvOS)
internal extension NSUIRectCorner {
    init(_ cornerMask: CACornerMask) {
        var corner = NSUIRectCorner()
        if cornerMask.contains(.bottomLeft) {
            corner.insert(.bottomLeft)
        }
        if cornerMask.contains(.bottomRight) {
            corner.insert(.bottomRight)
        }
        if cornerMask.contains(.topLeft) {
            corner.insert(.topLeft)
        }
        if cornerMask.contains(.topRight) {
            corner.insert(.topRight)
        }
        self.init(rawValue: corner.rawValue)
    }
    
    var caCornerMask: CACornerMask {
        var cornerMask = CACornerMask()
        if contains(.bottomLeft) {
            cornerMask.insert(.bottomLeft)
        }
        if contains(.bottomRight) {
            cornerMask.insert(.bottomRight)
        }
        if contains(.topLeft) {
            cornerMask.insert(.topLeft)
        }
        if contains(.topRight) {
            cornerMask.insert(.topRight)
        }
        return cornerMask
    }
}
#endif

#if os(macOS)
internal extension NSBezierPath {
    /**
     Creates and returns a new Bézier path object for a contact shadow with the specified shadow size and distance.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - shadowSize: The size of the shadow.
        - shadowDistance: The distance of the shadow.
     
     - Returns: A new path object for a contact shadow.
     */
    static func contactShadow(rect: CGRect, shadowSize: CGFloat = 20, shadowDistance: CGFloat = 0) -> NSBezierPath {
        let contactRect = CGRect(x: -shadowSize, y: (rect.height - (shadowSize * 0.4)) + shadowDistance, width: rect.width + shadowSize * 2, height: shadowSize)
        return NSBezierPath(ovalIn: contactRect)
    }
    
    /**
     Creates and returns a new Bézier path object for a depth shadow with the specified shadow size and distance.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - shadowSize: The size of the shadow.
        - shadowDistance: The distance of the shadow.
     
     - Returns: A new path object for a depth shadow.
     */
    static func depthShadow(rect: CGRect, shadowWidth: CGFloat = 1.2, shadowHeight: CGFloat = 0.5, shadowRadius: CGFloat = 5, shadowOffsetX: CGFloat = 0) -> NSBezierPath {
        let shadowPath = NSBezierPath()
        shadowPath.move(to: CGPoint(x: shadowRadius / 2, y: rect.height - shadowRadius / 2))
        shadowPath.line(to: CGPoint(x: rect.width, y: rect.height - shadowRadius / 2))
        shadowPath.line(to: CGPoint(x: rect.width * shadowWidth + shadowOffsetX, y: rect.height + (rect.height * shadowHeight)))
        shadowPath.line(to: CGPoint(x: rect.width * -(shadowWidth - 1) + shadowOffsetX, y: rect.height + (rect.height * shadowHeight)))
        return shadowPath
    }
    
    /**
     Creates and returns a new Bézier path object for a flat shadow with the specified shadow size and distance.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - shadowSize: The size of the shadow.
        - shadowDistance: The distance of the shadow.
     
     - Returns: A new path object for a flat shadow.
     */
    static func flatShadow(rect: CGRect, shadowOffsetX: CGFloat = 2000) -> NSBezierPath {
        // how far the bottom of the shadow should be offset
        let shadowPath = NSBezierPath()
        shadowPath.move(to: CGPoint(x: 0, y: rect.height))
        shadowPath.line(to: CGPoint(x: rect.width, y: rect.height))
        
        // make the bottom of the shadow finish a long way away, and pushed by our X offset
        shadowPath.line(to: CGPoint(x: rect.width + shadowOffsetX, y: 2000))
        shadowPath.line(to: CGPoint(x: shadowOffsetX, y: 2000))
        return shadowPath
    }
    
    /**
     Creates and returns a new Bézier path object for a flat behind shadow with the specified shadow size and distance.
     
     - Parameters:
        - rect: The rectangle that defines the basic shape of the path.
        - shadowSize: The size of the shadow.
        - shadowDistance: The distance of the shadow.
     
     - Returns: A new path object for a flat behind shadow.
     */
    static func flatShadowBehind(rect: CGRect, shadowOffsetX: CGFloat = 2000) -> NSBezierPath {
        // how far the bottom of the shadow should be offset
        let shadowPath = NSBezierPath()
        shadowPath.move(to: CGPoint(x: 0, y: rect.height))
        shadowPath.line(to: CGPoint(x: rect.width, y: 0))
        shadowPath.line(to: CGPoint(x: rect.width + shadowOffsetX, y: 2000))
        shadowPath.line(to: CGPoint(x: shadowOffsetX, y: 2000))
        return shadowPath
    }
}
#endif
