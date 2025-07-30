//
//  AnimatableArray.swift
//
//
//  Created by Florian Zand on 15.10.21.
//

import Accelerate
import Foundation
import SwiftUI

/**
 An array of animatable values, which is itself animatable.

 It's recommended to use `Double` values for much faster calculation in animations.

 Take a look at ``AnimatableProperty`` for an example implementation of `AnimatableArray`.
 */
public struct AnimatableArray<Element: VectorArithmetic & AdditiveArithmetic> {
    var elements: [Element] = []

    /// Creates a new, empty array.
    public init() {}

    /**
     Creates a new array with the given elements from an array literal.

     - Parameter elements: The elements for the new array..
     */
    public init(arrayLiteral elements: Element...) {
        self.elements = elements
    }

    /**
     Creates a new array containing the elements of a sequence.

     - Parameter elements: The sequence of elements for the new array.
     */
    public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
        self.elements = .init(elements)
    }

    /**
     Creates a new array containing the specified number of a single, repeated value.

     - Parameters
        -  repeatedValue: The element to repeat.
        -  count: The number of times to repeat the value passed in the repeating parameter. count must be zero or greater.
     */
    public init(repeating repeatedValue: Element, count: Int) {
        elements = .init(repeating: repeatedValue, count: count)
    }

    /**
     Accesses the element at the specified position.

     - Parameter index: The position of the element to access. index must be greater than or equal to startIndex and less than endIndex.
     */
    public subscript(index: Int) -> Element {
        get { elements[index] }
        set { elements[index] = newValue }
    }

    /**
     Accesses the element at the specified position safety. Returns `nil` If the index is larger than the array,

     - Parameter index: The position of the element to access.
     */
    public subscript(safe index: Index) -> Element? {
        get {
            guard !isEmpty, index >= 0, index < count else { return nil }
            return self[index]
        }
        set {
            guard !isEmpty, index >= 0, index < count, let newValue = newValue else { return }
            self[index] = newValue
        }
    }

    /**
     Accesses a contiguous subrange of the array’s elements.

     - Parameter bounds: A range of integers. The bounds of the range must be valid indices of the array.
     */
    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        get { elements[bounds] }
        set { elements[bounds] = newValue }
    }

    /// The position of the first element in a nonempty array.
    public var startIndex: Int {
        elements.startIndex
    }

    /// The array’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    public var endIndex: Int {
        elements.endIndex
    }

    /// The number of elements in the array.
    public var count: Int {
        elements.count
    }

    /// A Boolean value indicating whether the collection is empty.
    public var isEmpty: Bool {
        elements.isEmpty
    }

    /// The first element of the collection.
    public var first: Element? {
        elements.first
    }

    /// The last element of the collection.
    public var last: Element? {
        elements.last
    }

    /**
     Replaces the specified subrange of elements with the given collection.

     - Parameters
        -  subrange: The subrange of the collection to replace. The bounds of the range must be valid indices of the collection.
        -  newElements: The new elements to add to the collection.
     */
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound {
        elements.replaceSubrange(subrange, with: newElements)
    }
}

extension AnimatableArray: MutableCollection, RangeReplaceableCollection, RandomAccessCollection, BidirectionalCollection {}
extension AnimatableArray: ExpressibleByArrayLiteral {}
extension AnimatableArray: Sendable where Element: Sendable {}
extension AnimatableArray: Encodable where Element: Encodable {}
extension AnimatableArray: Decodable where Element: Decodable {}

extension AnimatableArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        elements.customMirror
    }

    public var debugDescription: String {
        elements.debugDescription
    }

    public var description: String {
        elements.description
    }
}

extension AnimatableArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }
}

extension AnimatableArray: VectorArithmetic & AdditiveArithmetic {
    public static func + (lhs: AnimatableArray, rhs: AnimatableArray) -> AnimatableArray {
        let count = Swift.min(lhs.count, rhs.count)
        if Element.self == Double.self {
            let lhsD = castDouble(lhs.elements)
            let rhsD = castDouble(rhs.elements)
            return Self(uncastDouble(lhs.count == rhs.count ? vDSP.add(lhsD, rhsD) : vDSP.add(lhsD[0..<count], rhsD[0..<count])))
        }
        var lhs = lhs
        for index in 0..<count {
            lhs[index] += rhs[index]
        }
        return lhs
    }

    public static func - (lhs: AnimatableArray, rhs: AnimatableArray) -> AnimatableArray {
        let count = Swift.min(lhs.count, rhs.count)
        if Element.self == Double.self {
            let lhsD = castDouble(lhs.elements)
            let rhsD = castDouble(rhs.elements)
            return Self(uncastDouble(lhs.count == rhs.count ? vDSP.subtract(lhsD, rhsD) : vDSP.subtract(lhsD[0..<count], rhsD[0..<count])))
        }
        if Element.self == Float.self {
            let lhsD = castFloat(lhs.elements)
            let rhsD = castFloat(rhs.elements)
            return Self(uncastFloat(lhs.count == rhs.count ? vDSP.subtract(lhsD, rhsD) : vDSP.subtract(lhsD[0..<count], rhsD[0..<count])))
        }
        var lhs = lhs
        for index in 0..<count {
            lhs[index] -= rhs[index]
        }
        return lhs
    }

    public mutating func scale(by rhs: Double) {
        if Element.self == Double.self {
            elements = Self.uncastDouble(vDSP.multiply(rhs, Self.castDouble(elements)))
        } else {
            for index in startIndex ..< endIndex {
                self[index].scale(by: rhs)
            }
        }
    }

    public var magnitudeSquared: Double {
        if Element.self == Double.self {
            let elements = Self.castDouble(elements)
            return vDSP.sum(vDSP.multiply(elements, elements))
        }
        return reduce(into: 0.0) { result, new in
            result += new.magnitudeSquared
        }
    }

    public static var zero: Self { .init() }
    
    private static func castDouble(_ elements: [Element]) -> [Double] {
        unsafeBitCast(elements, to: [Double].self)
    }
    
    private static func uncastDouble(_ elements: [Double]) -> [Element] {
        unsafeBitCast(elements, to: [Element].self)
    }
    
    private static func castFloat(_ elements: [Element]) -> [Float] {
        unsafeBitCast(elements, to: [Float].self)
    }
    
    private static func uncastFloat(_ elements: [Float]) -> [Element] {
        unsafeBitCast(elements, to: [Element].self)
    }
}

extension AnimatableArray: ApproximateEquatable where Element: FloatingPointInitializable {
    public func isApproximatelyEqual(to other: Self, epsilon: Element) -> Bool {
        count <= other.count && zip(self, other).allSatisfy({ $0.0.isApproximatelyEqual(to: $0.1, epsilon: epsilon) })
    }
 }
