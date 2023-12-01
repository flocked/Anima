//
//  CACornerMask+.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

#if canImport(QuartzCore)
import QuartzCore.CoreAnimation

internal extension CACornerMask {
    /// All corners.
    static let all: CACornerMask = [.bottomLeft, .bottomRight, .topLeft, .topRight]
    /// No ocrners.
    static let none: CACornerMask = []

    #if os(macOS)
    /// The bottom left corner.
    static let bottomLeft = CACornerMask.layerMinXMinYCorner
    /// The bottom right corner.
    static let bottomRight = CACornerMask.layerMaxXMinYCorner
    /// The top left corner.
    static let topLeft = CACornerMask.layerMinXMaxYCorner
    /// The top right corner.
    static let topRight = CACornerMask.layerMaxXMaxYCorner

    /// Bottom corners.
    static let bottomCorners: CACornerMask = [
        .layerMaxXMinYCorner,
        .layerMinXMinYCorner,
    ]

    /// Top corners.
    static let topCorners: CACornerMask = [
        .layerMinXMaxYCorner,
        .layerMaxXMaxYCorner,
    ]
    #elseif canImport(UIKit)
    /// The bottom left corner.
    static let bottomLeft = CACornerMask.layerMinXMaxYCorner
    /// The bottom right corner.
    static let bottomRight = CACornerMask.layerMaxXMaxYCorner
    /// The top left corner.
    static let topLeft = CACornerMask.layerMinXMinYCorner
    /// The top right corner.
    static let topRight = CACornerMask.layerMaxXMinYCorner

    /// Bottom corners.
    static let bottomCorners: CACornerMask = [
        .layerMaxXMaxYCorner,
        .layerMinXMaxYCorner,
    ]

    /// Top corners.
    static let topCorners: CACornerMask = [
        .layerMinXMinYCorner,
        .layerMaxXMinYCorner,
    ]
    #endif

    /// Left corners.
    static let leftCorners: CACornerMask = [
        .layerMinXMinYCorner,
        .layerMinXMaxYCorner,
    ]

    /// Right corners.
    static let rightCorners: CACornerMask = [
        .layerMaxXMinYCorner,
        .layerMaxXMaxYCorner,
    ]
}

extension CACornerMask: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
#endif
