//
//  ApproximateEquatable.swift
//
//
//  Created by Florian Zand on 27.10.23.
//

import CoreGraphics
import Foundation
import SwiftUI

/// A type that can be compared for approximate value equality.
protocol ApproximateEquatable {
    associatedtype Epsilon: FloatingPointInitializable
    /**
     A Boolean value that indicates whether `self` and the specified `other` value are approximately equal.

     - Parameters:
        - other: The value to compare.
        - epsilon: The margin by which both values can differ and still be considered the same value.
     */
    func isApproximatelyEqual(to: Self, epsilon: Epsilon) -> Bool
}

extension Float: ApproximateEquatable {
    public func isApproximatelyEqual(to other: Float, epsilon: Float = 0.001) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
    }
}

extension Double: ApproximateEquatable {
    public func isApproximatelyEqual(to other: Double, epsilon: Double = 0.001) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
    }
}

extension CGFloat: ApproximateEquatable {
    public func isApproximatelyEqual(to other: CGFloat, epsilon: CGFloat = 0.001) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
    }
}

extension Array: ApproximateEquatable where Element: FloatingPointInitializable {
    public func isApproximatelyEqual(to other: Self, epsilon: Element) -> Bool {
        for i in 0 ..< indices.count {
            if !self[i].isApproximatelyEqual(to: other[i], absoluteTolerance: epsilon) {
                return false
            }
        }
        return true
    }
}

extension Set: ApproximateEquatable where Element: FloatingPointInitializable {
    public func isApproximatelyEqual(to other: Self, epsilon: Element) -> Bool {
        let check = Array(self)
        let other = Array(other)

        for i in 0 ..< indices.count {
            if !check[i].isApproximatelyEqual(to: other[i], absoluteTolerance: epsilon) {
                return false
            }
        }
        return true
    }
}

extension AnimatablePair: ApproximateEquatable where First: ApproximateEquatable, Second: ApproximateEquatable {
    func isApproximatelyEqual(to other: AnimatablePair<First, Second>, epsilon: Double) -> Bool {
        first.isApproximatelyEqual(to: other.first, epsilon: First.Epsilon(epsilon)) && second.isApproximatelyEqual(to: other.second, epsilon: Second.Epsilon(epsilon))
    }
}

extension Numeric where Magnitude: FloatingPoint {
    /**
     A Boolean value that indicates whether the value and the specified `other` value are approximately equal.

     - Parameters:
        - other: The value to which `self` is compared.
        - relativeTolerance: The tolerance to use in the comparison. Defaults to `.ulpOfOne.squareRoot()`.
        - norm: The norm to use for the comparison. Defaults to `\.magnitude`.
     */
    func isApproximatelyEqual(to other: Self, relativeTolerance: Magnitude = Magnitude.ulpOfOne.squareRoot(), norm: (Self) -> Magnitude = \.magnitude) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: relativeTolerance * Magnitude.leastNormalMagnitude, relativeTolerance: relativeTolerance, norm: norm)
    }

    /**
     A Boolean value that indicates whether the value and the specified `other` value are approximately equal.

     - Parameters:
        - other: The value to which `self` is compared.
        - absoluteTolerance: The absolute tolerance to use in the comparison.
        - relativeTolerance: The relative tolerance to use in the comparison. Defaults to `0`.
        - norm: The norm to use for the comparison. Defaults to `\.magnitude`.
     */
    @inlinable @inline(__always)
    func isApproximatelyEqual(to other: Self, 
                              absoluteTolerance: Magnitude,
                              relativeTolerance: Magnitude = 0) -> Bool {
        isApproximatelyEqual(
            to: other,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            norm: \.magnitude
        )
    }
    
    /**
     A Boolean value that indicates whether `self` and the specified `other` value are approximately equal.

     - Parameters:
        - other: The value to compare.
        - epsilon: The margin by which both values can differ and still be considered the same value.
     */
    @inlinable @inline(__always)
    func isApproximatelyEqual(to other: Self, 
                              epsilon: Magnitude) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
    }
}

extension AdditiveArithmetic {
    /**
     A Boolean value that indicates whether the value and the specified `other` value are approximately equal.

     - Parameters:
     - other: The value to which `self` is compared.
     - absoluteTolerance: The absolute tolerance to use in the comparison.
     - relativeTolerance: The relative tolerance to use in the comparison. Defaults to `0`.
     - norm: The norm to use for the comparison. Defaults is `\.magnitude`.
     */
    @inlinable
    func isApproximatelyEqual<Magnitude>(
        to other: Self,
        absoluteTolerance: Magnitude,
        relativeTolerance: Magnitude = 0,
        norm: (Self) -> Magnitude
    ) -> Bool where Magnitude: FloatingPoint {
        assert(
            absoluteTolerance >= 0 && absoluteTolerance.isFinite,
            "absoluteTolerance should be non-negative and finite, " +
                "but is \(absoluteTolerance)."
        )
        assert(
            relativeTolerance >= 0 && relativeTolerance <= 1,
            "relativeTolerance should be non-negative and <= 1, " +
                "but is \(relativeTolerance)."
        )
        if self == other { return true }
        let delta = norm(self - other)
        let scale = max(norm(self), norm(other))
        let bound = max(absoluteTolerance, scale * relativeTolerance)
        return delta.isFinite && delta <= bound
    }
}

extension ApproximateEquatable {
    func isApproximatelyEqual(toAny other: any ApproximateEquatable, epsilon: Double) -> Bool {
        guard let other = other as? Self else { return false }
        return self.isApproximatelyEqual(to: other, epsilon: Epsilon(epsilon))
    }
    
    func isApproximatelyEqual(toAny other: any ApproximateEquatable, epsilon: Float) -> Bool {
        guard let other = other as? Self else { return false }
        return self.isApproximatelyEqual(to: other, epsilon: Epsilon(epsilon))
    }
    
    func isApproximatelyEqual(toAny other: any ApproximateEquatable, epsilon: CGFloat) -> Bool {
        guard let other = other as? Self else { return false }
        return self.isApproximatelyEqual(to: other, epsilon: Epsilon(epsilon))
    }
}
