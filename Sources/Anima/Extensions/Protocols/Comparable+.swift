//
//  Comparable+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation


internal extension Comparable {
    /**
     Returns a Boolean value indicating whether the value is less than another value.
     
     - Parameters other: A value conforming to Comparable.
     - Returns: Returns true if the value is less than the other value; or false if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThan(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }

    /**
     Returns a Boolean value indicating whether the value is less than another value.
     
     - Parameters other: A value conforming to Comparable.
     - Returns: Returns true if the value is less than the other value; or false if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThan(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }
    
    /**
     Returns a Boolean value indicating whether the value is less or equal to another value.
     
     - Parameters other: A value conforming to Comparable.
     - Returns: Returns true if the value is less than or equal to the other value; or false if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self <= other
    }
    
    /**
     Returns a Boolean value indicating whether the value is less or equal to another value.
     
     - Parameters other: A value conforming to Comparable.
     - Returns: Returns true if the value is less than or equal to the other value; or false if it isn't or if the other value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self <= other
    }

    static func < (lhs: Self, other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return lhs < other
    }

    static func < (lhs: Self, other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return lhs < other
    }
}

internal extension Comparable {
    /// Returns `true` if value is in the provided closed range.
    ///
    ///     1.isBetween(5...7) // false
    ///     7.isBetween(6...12) // true
    ///     "c".isBetween("a"..."d") // true
    ///     0.32.isBetween(0.31...0.33) // true
    ///
    /// - Parameter range: Closed range against which the value is checked to be included.
    func isBetween(_ range: ClosedRange<Self>) -> Bool { range ~= self }
    
    /// Returns `true` if value is in the provided range.
    ///
    ///     1.isBetween(5..<7) // false
    ///     7.isBetween(6..<12) // true
    ///     "c".isBetween("a"..<"d") // true
    ///     0.32.isBetween(0.31..<0.33) // true
    ///
    /// - Parameter range: Closed range against which the value is checked to be included.
    func isBetween(_ range: Range<Self>) -> Bool { range ~= self }
}


internal extension PartialKeyPath {
    /**
     Returns a Boolean value indicating whether the keypath's value is less than another keypath's value.
     
     - Parameters keyPath: The keypath for comparing it's value.
     - Returns: Returns true if the keypath's value is less than the other keypath's value; or false if it isn't or if the other keypath's value isn't the same Comparable type.
     */
    func isLessThan(_ keyPath: PartialKeyPath<Root>) -> Bool {
        guard let b = keyPath as? any Comparable else { return true }
        guard let a = self as? any Comparable else { return false }
        return a.isLessThan(b)
    }
    
    /**
     Returns a Boolean value indicating whether the keypath's value is less than or equal to another keypath's value.
     
     - Parameters keyPath: The keypath for comparing it's value.
     - Returns: Returns true if the keypath's value is less than or equal to the other keypath's value; or false if it isn't or if the other keypath's value isn't the same Comparable type.
     */
    func isLessThanOrEqual(_ keyPath: PartialKeyPath<Root>) -> Bool {
        guard let b = keyPath as? any Comparable else { return true }
        guard let a = self as? any Comparable else { return false }
        return a.isLessThanOrEqual(b)
    }
}
