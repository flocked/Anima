//
//  NSRectCorner.swift
//
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
import Foundation

/**
 The corners of a rectangle.

 The specified constants reflect the corners of a rectangle that has not been modified by an affine transform and is drawn in the default coordinate system (where the origin is in the upper-left corner and positive values extend down and to the right).
 */
internal struct NSRectCorner: OptionSet, Sendable {
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
