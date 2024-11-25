//
//  Rotation.swift
//
//
//  Created by Florian Zand on 25.11.24.
//

#if canImport(QuartzCore)
import Foundation

/// Rotation in a three-dimensional space.
public struct Rotation: Hashable, Codable, ExpressibleByFloatLiteral, CustomStringConvertible {

    /// The rotation angle around the x-axis.
    public var x: CGFloat = .zero
    
    /// The rotation angle around the y-axis.
    public var y: CGFloat = .zero
    
    /// The rotation angle around the z-axis.
    public var z: CGFloat = .zero
    
    /// No rotation.
    public static var zero: Rotation = .init()
    
    /**
     Creates a `Rotation` with the specified rotation angles.
     
     - Parameters:
       - x: The rotation angle around the x-axis.
       - y: The rotation angle around the y-axis.
       - z: The rotation angle around the z-axis.
     */
    public init(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a `Rotation` with the specified rotation angles.
     
     - Parameters:
       - x: The rotation angle around the x-axis.
       - y: The rotation angle around the y-axis.
       - z: The rotation angle around the z-axis.
     */
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a `Rotation` with a rotation around the z-axis.
     
     - Parameter z: The rotation angle around the z-axis.
     */
    public init(_ z: CGFloat) {
        self.z = z
    }
    
    /**
     Creates a `Rotation` with a rotation around the z-axis.
     
     - Parameter value: The rotation angle around the z-axis.
     */
    public init(floatLiteral value: Double) {
        self.z = value
    }
    
    public var description: String {
        "Rotation(x: \(x), y: \(y), z: \(z))"
    }
    
    var vector: CGVector3 {
        .init(x, y, z)
    }
}

extension CGVector3 {
    var rotation: Rotation {
        .init(x, y, z)
    }
    
    var degrees: CGVector3 {
        .init(x.radiansToDegrees, y.radiansToDegrees, z.radiansToDegrees)
    }
    
    var radians: CGVector3 {
        .init(x.degreesToRadians, y.degreesToRadians, z.degreesToRadians)
    }
}
#endif
