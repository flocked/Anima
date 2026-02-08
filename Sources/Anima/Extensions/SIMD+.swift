//
//  SIMD+.swift
//  Anima
//
//  Created by Florian Zand on 08.02.26.
//

import Foundation
import SwiftUI
import simd

public extension SIMD {
    /// Returns a new vector by applying the given transform to each element.
    func map<E>(_ transform: (Scalar) throws(E) -> Scalar) throws(E) -> Self where E : Error {
        Self(try scalars.map(transform))
    }
}

public extension SIMDStorage {
    /// The scalars of the vector.
    var scalars: [Scalar] {
        get { Self.indices.map({ self[$0] }) }
    }
    
    /// The valid indices for subscripting the vector.
    static var indices: Range<Int> { 0..<scalarCount }
}

public extension SIMD4 {
    var scalars: [Scalar] { [x, y, z, w] }
}

/*
extension SIMD2: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD3: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD4: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD8: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }

extension SIMD2: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        simd_length_squared(self)
    }
}

extension SIMD3: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        simd_length_squared(self)
    }
}

extension SIMD4: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        simd_length_squared(self)
    }
}

extension SIMD8: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        simd_length_squared(self)
    }
}
*/
