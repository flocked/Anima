//
//  Number+FloatInitializable.swift
//
//
//  Created by Florian Zand on 27.10.23.
//

import Foundation

/// A floating-point numeric type that can be initialized with a floating-point value.
public protocol FloatingPointInitializable: FloatingPoint & ExpressibleByFloatLiteral & Comparable & Equatable {
    /// Creates a new value from a `Float`.
    init(_ value: Float)

    /// Creates a new value from a `Double`.
    init(_ value: Double)
}

extension Float: FloatingPointInitializable { }
extension Double: FloatingPointInitializable { }
extension CGFloat: FloatingPointInitializable { }

extension BinaryFloatingPoint {
    /// Converts the value from degrees to radians.
    var degreesToRadians: Self {
        return Self.pi * self / 180.0
    }

    /// Converts the value from radians to degress.
    var radiansToDegrees: Self {
        return self * 180 / Self.pi
    }
}

extension Float {
    func rounded(toNearest roundingFactor: Self) -> Self {
        (self / roundingFactor).rounded(.up) * roundingFactor
    }
}

extension Double {
    func rounded(toNearest roundingFactor: Self) -> Self {
        (self / roundingFactor).rounded(.up) * roundingFactor
    }
}

extension CGFloat {
    func rounded(toNearest roundingFactor: Self) -> Self {
        (self / roundingFactor).rounded(.up) * roundingFactor
    }
}
