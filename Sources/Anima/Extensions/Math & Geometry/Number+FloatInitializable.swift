//
//  Number+FloatInitializable.swift
//
//
//  Created by Florian Zand on 27.10.23.
//

import Foundation

/// A floating-point numeric type that can be initialized with a floating-point value.
public protocol FloatingPointInitializable: FloatingPoint & ExpressibleByFloatLiteral & Comparable & Equatable {
    init(_ value: Float)
    init(_ value: Double)
}

extension Float: FloatingPointInitializable { }
extension Double: FloatingPointInitializable { }
extension CGFloat: FloatingPointInitializable { }
