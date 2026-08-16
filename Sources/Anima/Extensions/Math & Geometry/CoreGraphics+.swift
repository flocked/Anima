//
//  CoreGraphics+.swift
//
//
//  Created by Florian Zand on 01.12.23.
//

import CoreGraphics
import Foundation

extension CGPoint {
    /// Creates a point with the specified x and y value.
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }

    /**
     Returns a new CGPoint by offsetting the current point by the specified values along the x and y axes.

     - Parameters:
        - x: The value to be added to the x-coordinate of the current point.
        - y: The value to be added to the y-coordinate of the current point.

     - Returns: The new CGPoint obtained by offsetting the current point by the specified values.
     */
    func offset(x: CGFloat = 0, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
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

extension CGSize {
    /// Creates a size with the specified width and height.
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }

    /// The size as `CGPoint`, using the width as x-coordinate and height as y-coordinate.
    var point: CGPoint {
        CGPoint(width, height)
    }
}

extension CGRect {
    /// The center point of the rectangle.
    var center: CGPoint {
        get { CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }

    /// The horizontal center of the rectangle.
    var centerX: CGFloat {
        get { midX }
        set { origin.x = newValue - width * 0.5 }
    }

    /// The vertical center of the rectangle.
    var centerY: CGFloat {
        get { midY }
        set { origin.y = newValue - height * 0.5 }
    }

    /// A size centered that specifies the height and width of the rectangle. Changing this value keeps the rectangle centered.
    var sizeCentered: CGSize {
        get { size }
        set {
            guard size != newValue else { return }
            let previousCenter = center
            size = newValue
            center = previousCenter
        }
    }
}
