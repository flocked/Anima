//
//  CGFloatVectorTypes.swift
//  
//
//  Created by Adam Bell on 5/18/20.
//

import Foundation
import simd
import QuartzCore

public typealias Translation = CGVector3
// public typealias Scale = CGVector3
public typealias Perspective = CGVector4
public typealias Skew = CGVector3

fileprivate let accuracy: Double = 0.0001

// MARK: - CGVector3

public struct CGVector3 {
    
    internal var storage: simd_double3
    
    public var x: CGFloat {
        get { return CGFloat(storage.x) }
        set { storage.x = Double(newValue) }
    }
    
    public var y: CGFloat {
        get { return CGFloat(storage.y) }
        set { storage.y = Double(newValue) }
    }
    
    public var z: CGFloat {
        get { return CGFloat(storage.z) }
        set { storage.z = Double(newValue) }
    }
    
    public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) {
        self.init(simd_double3(Double(x), Double(y), Double(z)))
    }
    
    public init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0) {
        self.init(simd_double3(x, y, z))
    }
    
    public init(x: Float = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) {
        self.init(simd_double3(Double(x), Double(y), Double(z)))
    }
    
    public init(_ vector: simd_double3) {
        self.storage = vector
    }
    
    public init(_ vector: simd_float3) {
        self.init(simd_double3(vector))
    }
}

extension CGVector3: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return abs(rhs.storage[0] - lhs.storage[0]) < accuracy &&
        abs(rhs.storage[1] - lhs.storage[1]) < accuracy &&
        abs(rhs.storage[2] - lhs.storage[2]) < accuracy
    }
}

extension CGVector3: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        self.init(x: elements[0], y: elements[1], z: elements[2])
    }
    
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.init(x: x, y: y, z: z)
    }
}

public extension CGVector3 {
    var xy: CGFloat {
        get { return CGFloat(self.storage[0]) }
        set { self.storage[0] = Double(newValue) }
    }
    
    var xz: CGFloat {
        get { return CGFloat(self.storage[1]) }
        set { self.storage[1] = Double(newValue) }
    }
    
    var yz: CGFloat {
        get { return CGFloat(self.storage[2]) }
        set { self.storage[2] = Double(newValue) }
    }
    
    init(xy: CGFloat = 0.0, xz: CGFloat = 0.0, yz: CGFloat = 0.0) {
        self.init(xy, xz, yz)
    }
    
    init(xy: Double = 0.0, xz: Double = 0.0, yz: Double = 0.0) {
        self.init(CGFloat(xy), CGFloat(xz), CGFloat(yz))
    }
    
    init(xy: Float = 0.0, xz: Float = 0.0, yz: Float = 0.0) {
        self.init(CGFloat(xy), CGFloat(xz), CGFloat(yz))
    }
}

public extension simd_double3 {
    init(_ vector: CGVector3) {
        self.init(Double(vector.x), Double(vector.y), Double(vector.z))
    }
}

public extension simd_float3 {
    init(_ vector: CGVector3) {
        self.init(Float(vector.x), Float(vector.y), Float(vector.z))
    }
}

// MARK: - CGVector4

public struct CGVector4 {
    
    internal var storage: simd_double4
    
    var x: CGFloat {
        get { return CGFloat(storage.x) }
        set { storage.x = Double(newValue) }
    }
    
    var y: CGFloat {
        get { return CGFloat(storage.y) }
        set { storage.y = Double(newValue) }
    }
    
    var z: CGFloat {
        get { return CGFloat(storage.z) }
        set { storage.z = Double(newValue) }
    }
    
    var w: CGFloat {
        get { return CGFloat(storage.w) }
        set { storage.w = Double(newValue) }
    }
    
    public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0, w: CGFloat = 0.0) {
        self.init(simd_double4(Double(x), Double(y), Double(z), Double(w)))
    }
    
    public init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0, w: Double = 0.0) {
        self.init(simd_double4(x, y, z, w))
    }
    
    public init(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0, w: Float = 0.0) {
        self.init(simd_double4(Double(x), Double(y), Double(z), Double(w)))
    }
    
    public init(_ vector: simd_double4) {
        self.storage = vector
    }
    
    public init(_ vector: simd_float4) {
        self.init(simd_double4(vector))
    }
}

extension CGVector4: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return abs(rhs.storage[0] - lhs.storage[0]) < accuracy &&
        abs(rhs.storage[1] - lhs.storage[1]) < accuracy &&
        abs(rhs.storage[2] - lhs.storage[2]) < accuracy &&
        abs(rhs.storage[3] - lhs.storage[3]) < accuracy
    }
}

// MARK: - ExpressibleByArrayLiteral

extension CGVector4: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        self.init(x: elements[0], y: elements[1], z: elements[2], w: elements[3])
    }
    
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat, _ w: CGFloat) {
        self.init(x: x, y: y, z: z, w: w)
    }
}

public extension CGVector4 {
    var m14: CGFloat {
        get { return CGFloat(self.storage[0]) }
        set { self.storage[0] = Double(newValue) }
    }
    
    var m24: CGFloat {
        get { return CGFloat(self.storage[1]) }
        set { self.storage[1] = Double(newValue) }
    }
    
    var m34: CGFloat {
        get { return CGFloat(self.storage[2]) }
        set { self.storage[2] = Double(newValue) }
    }
    
    var m44: CGFloat {
        get { return CGFloat(self.storage[3]) }
        set { self.storage[3] = Double(newValue) }
    }
    
    init(m14: CGFloat = 0.0, m24: CGFloat = 0.0, m34: CGFloat = 0.0, m44: CGFloat = 1.0) {
        self.init(m14, m24, m34, m44)
    }
    
    init(m14: Double = 0.0, m24: Double = 0.0, m34: Double = 0.0, m44: Double = 1.0) {
        self.init(CGFloat(m14), CGFloat(m24), CGFloat(m34), CGFloat(m44))
    }
    
    init(m14: Float = 0.0, m24: Float = 0.0, m34: Float = 0.0, m44: Float = 1.0) {
        self.init(CGFloat(m14), CGFloat(m24), CGFloat(m34), CGFloat(m34))
    }
}

public extension simd_double4 {
    init(_ vector: CGVector4) {
        self.init(Double(vector.x), Double(vector.y), Double(vector.z), Double(vector.w))
    }
}

public extension simd_float4 {
    init(_ vector: CGVector4) {
        self.init(Float(vector.x), Float(vector.y), Float(vector.z), Float(vector.w))
    }
}

// MARK: - CGQuaternion

public struct CGQuaternion {
    
    internal var storage: simd_quatd
    
    public var axis: CGVector3 {
        get { return CGVector3(storage.axis) }
        set { self.storage = simd_quatd(angle: storage.angle, axis: normalize(simd_double3(newValue))) }
    }
    
    public var angle: CGFloat {
        get { return CGFloat(storage.angle) }
        set { self.storage = simd_quatd(angle: Double(newValue), axis: storage.axis) }
    }
    
    /**
     Default initializer.
     
     - Parameter angle: The angle of rotation (specified in radians).
     - Parameter axis: The axis of rotation (this will be normalized automatically)
     */
    public init(angle: CGFloat, axis: CGVector3) {
        self.storage = simd_quatd(angle: Double(angle), axis: normalize(simd_double3(axis)))
    }
    
    public init(_ quaternion: simd_quatd) {
        self.storage = quaternion
    }
}

extension CGQuaternion: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.axis == rhs.axis &&
        abs(rhs.storage.angle - lhs.storage.angle) < accuracy
    }
}

public extension simd_quatd {
    init(_ quaternion: CGQuaternion) {
        self.init(angle: Double(quaternion.angle), axis: simd_double3(quaternion.axis))
    }
}

public extension simd_quatf {
    init(_ quaternion: CGQuaternion) {
        self.init(angle: Float(quaternion.angle), axis: simd_float3(quaternion.axis))
    }
}
