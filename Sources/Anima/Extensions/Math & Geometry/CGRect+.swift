//
//  CGRect+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation
import CoreGraphics

public extension CGRect {
    /**
      Returns the scaled integral rect based on the current rect.
      The origin and size values are scaled based on the current device's screen scale.
      
      - Returns: The scaled integral rect.
      */
    var scaledIntegral: CGRect {
        CGRect(
            x: origin.x.scaledIntegral,
            y: origin.y.scaledIntegral,
            width: size.width.scaledIntegral,
            height: size.height.scaledIntegral
        )
    }
}

internal extension CGRect {
    /// Creates a rect with the specified values.
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }

    /// Creates a rect with the specified origin and size.
    init(_ origin: CGPoint, _ size: CGSize) {
        self.init(origin: origin, size: size)
    }

    /// Creates a rect with the specified size.
    init(size: CGSize) {
        self.init(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    /// Creates a rect with the specified size.
    init(size: CGFloat) {
        self.init(x: 0, y: 0, width: size, height: size)
    }

    /**
     Initializes a CGRect with the specified point and size.
     
     - Parameters:
        - point: The center point of the rectangle.
        - size: The size of the rectangle.
        - integralized: A Boolean value indicating whether the resulting CGRect should have integral values. The default value is `false`.
     
     - Returns: A new CGRect initialized with the specified parameters.
     */
    init(aroundPoint point: CGPoint, size: CGSize, integralized: Bool = false) {
        let unintegralizedRect = CGRect(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0, width: size.width, height: size.height)
        let result = integralized ? unintegralizedRect.scaledIntegral : unintegralizedRect
        self.init(x: result.origin.x, y: result.origin.y, width: result.size.width, height: result.size.height)
    }
    
    /// The x-coordinate of the origin of the rectangle.
    var x: CGFloat {
        get { origin.x }
        set {
            var origin = self.origin
            origin.x = newValue
            self.origin = origin
        }
    }

    /// The y-coordinate of the origin of the rectangle.
    var y: CGFloat {
        get { origin.y }
        set {
            var origin = self.origin
            origin.y = newValue
            self.origin = origin
        }
    }
    
    /// A size centered that specifies the height and width of the rectangle. Changing this value keeps the rectangle centered.
    var sizeCentered: CGSize {
        get { size }
        set { 
            let old = self
            size = newValue
            self.center = old.center
        }
    }
    
    /// The left edge of the rectangle.
    var left: CGFloat {
        get {return origin.x}
        set {origin.x = newValue}
    }
    /// The right edge of the rectangle.
    var right: CGFloat {
        get {return x + width}
        set {x = newValue - width}
    }

    #if canImport(UIKit)
    /// The top edge of the rectangle.
    var top: CGFloat {
        get {return y}
        set {y = newValue}
    }
    /// The bottom edge of the rectangle.
    var bottom: CGFloat {
        get {return y + height}
        set {y = newValue - height}
    }
    #else
    /// The top edge of the rectangle.
    var top: CGFloat {
        get {return y + height}
        set {y = newValue - height}
    }
    /// The bottom edge of the rectangle.
    var bottom: CGFloat {
        get {return y}
        set {y = newValue}
    }
    #endif

    /// The top-left point of the rectangle.
    var topLeft: CGPoint {
        get {return CGPoint(x: left, y: top)}
        set {left = newValue.x; top = newValue.y}
    }
    
    /// The top-center point of the rectangle.
    var topCenter: CGPoint {
        get {return CGPoint(x: centerX, y: top)}
        set {centerX = newValue.x; top = newValue.y}
    }

    /// The top-right point of the rectangle.
    var topRight: CGPoint {
        get {return CGPoint(x: right, y: top)}
        set {right = newValue.x; top = newValue.y}
    }
    
    /// The center-left point of the rectangle.
    var centerLeft: CGPoint {
        get {return CGPoint(x: left, y: centerY)}
        set {left = newValue.x; centerY = newValue.y}
    }
    
    /// The center point of the rectangle.
    var center: CGPoint {
        get { return CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }
    
    /// The center-right point of the rectangle.
    var centerRight: CGPoint {
        get {return CGPoint(x: right, y: centerY)}
        set {right = newValue.x; centerY = newValue.y}
    }
    
    /// The bottom-left point of the rectangle.
    var bottomLeft: CGPoint {
        get {return CGPoint(x: left, y: bottom)}
        set {left = newValue.x; bottom = newValue.y}
    }
    
    /// The bottom-center point of the rectangle.
    var bottomCenter: CGPoint {
        get {return CGPoint(x: centerX, y: bottom)}
        set {centerX = newValue.x; bottom = newValue.y}
    }
    
    /// The bottom-right point of the rectangle.
    var bottomRight: CGPoint {
        get {return CGPoint(x: right, y: bottom)}
        set {right = newValue.x; bottom = newValue.y}
    }
    
    /// The horizontal center of the rectangle.
    var centerX: CGFloat {
        get { return midX }
        set { origin.x = newValue - width * 0.5 }
    }

    /// The vertical center of the rectangle.
    var centerY: CGFloat {
        get { return midY }
        set { origin.y = newValue - height * 0.5 }
    }

    /// The edge direction used for expanding a rect.
    enum ExpandEdge {
        case minXEdge
        case maxXEdge
        case minYEdge
        case maxYEdge
        case centerWidth
        case centerHeight
        case center
    }

    /**
     Returns a new rect expanded by the specified amount in the given edge direction.
     
     - Parameters:
        - amount: The amount by which to expand the rect.
        - edge: The edge direction in which to expand the rect.
     
     - Returns: A new rect expanded by the specified amount in the given edge direction.
     */
    func expanded(_ amount: CGFloat, edge: ExpandEdge) -> CGRect {
        switch edge {
        case .minXEdge:
            return CGRect(x: minX - amount, y: minY, width: width + amount, height: height)
        case .maxXEdge:
            return CGRect(x: minX, y: minY, width: width + amount, height: height)
        case .minYEdge:
            return CGRect(x: minX, y: minY - amount, width: width, height: height + amount)
        case .maxYEdge:
            return CGRect(x: minX, y: minY, width: width, height: height + amount)
        case .center:
            let widthAmount = amount / 2.0
            let heightAmount = amount / 2.0
            return CGRect(x: minX - widthAmount, y: minY - heightAmount, width: width + widthAmount, height: height + heightAmount)
        case .centerWidth:
            let widthAmount = amount / 2.0
            return CGRect(x: minX - widthAmount, y: minY, width: width + widthAmount, height: height)
        case .centerHeight:
            let heightAmount = amount / 2.0
            return CGRect(x: minX, y: minY - heightAmount, width: width, height: height + heightAmount)
        }
    }

    /**
     Returns a new rect scaled by the specified factor.
     
     - Parameters:
        - factor: The scaling factor to apply to the rect.
        - centered: A Boolean value indicating whether the scaling should be centered around the CGRect's center point. The default value is `true`.
     
     - Returns: A new rect scaled by the specified factor.
     */
    func scaled(byFactor factor: CGFloat, centered: Bool = true) -> CGRect {
        var rect = self
        rect.size = rect.size.scaled(byFactor: factor)
        if centered {
            rect.center = center
        }
        return rect
    }

    /**
     Returns a new rect scaled to the specified size, anchored at the specified point.
     
     - Parameters:
        - size: The target size for scaling the rect.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to the specified size, anchored at the specified point.
     */
    func scaled(to size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = CGSize(width: size.width - width, height: size.height - height)
        return CGRect(origin: CGPoint(x: minX - sizeDelta.width * anchor.x,
                                      y: minY - sizeDelta.height * anchor.y),
                      size: size)
    }

    /**
     Returns a new rect scaled to fit the specified size, anchored at the specified point.
     
     - Parameters:
        - size: The target size for scaling the rect to fit.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to fit the specified size, anchored at the specified point.
     */
    func scaled(toFit size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = self.size.scaled(toFit: size)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
      Returns a new rect scaled to fill the specified size, anchored at the specified point.
      
      - Parameters:
         - size: The target size for scaling the rect to fill.
         - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
      
      - Returns: A new rect scaled to fill the specified size, anchored at the specified point.
      */
    func scaled(toFill size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = self.size.scaled(toFill: size)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rect scaled to the specified width, anchored at the specified point.
     
     - Parameters:
        - width: The target width for scaling the rect.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to the specified width, anchored at the specified point.
     */
    func scaled(toWidth width: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(toWidth: width)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rect scaled to the specified height, anchored at the specified point.
     
     - Parameters:
        - height: The target height for scaling the rect.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to the specified height, anchored at the specified point.
     */
    func scaled(toHeight height: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(toHeight: height)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rect scaled by the specified factor, anchored at the specified point.
     
     - Parameters:
        - factor: The scaling factor to apply to the rect.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled by the specified factor, anchored at the specified point.
     */
    func scaled(byFactor factor: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(byFactor: factor)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rect with rounded coordinates according to the specified rounding rule.
     
     - Parameters:
        - rule: The rounding rule to apply to the coordinates. The default value is `.toNearestOrAwayFromZero`.
     
     - Returns: A new rect with rounded coordinates according to the specified rounding rule.
     */
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect {
        return CGRect(x: x.rounded(rule), y: y.rounded(rule), width: width.rounded(rule), height: height.rounded(rule))
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(size)
        hasher.combine(origin)
    }
}

extension Collection where Element == CGRect {
    /// The union of all rectangles in the collection.
    internal func union() -> CGRect {
        var unionRect = CGRect.zero
        for rect in self {
            unionRect.origin.x = Swift.min(rect.origin.x, unionRect.origin.x)
            unionRect.origin.y = Swift.min(rect.origin.y, unionRect.origin.y)
            unionRect.size.width = Swift.max(rect.origin.x.sign == .minus ? rect.size.width-rect.origin.x : rect.size.width, unionRect.size.width)
            unionRect.size.height = Swift.max(rect.origin.y.sign == .minus ? rect.size.height-rect.origin.y : rect.size.height, unionRect.size.height)
        }
        return unionRect
    }
}
