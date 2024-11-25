//
//  Scale.swift
//
//
//  Created by Florian Zand on 25.11.24.
//

#if canImport(QuartzCore)
import Foundation

/// Scaling in a three-dimensional space.
public struct Scale: Hashable, Codable, ExpressibleByFloatLiteral, CustomStringConvertible {

    /// The scaling on the x-axis.
    public var x: CGFloat = 1
    
    /// The scaling on the y-axis.
    public var y: CGFloat = 1
    
    /// The scaling on the z-axis.
    public var z: CGFloat = 1
    
    /// Zero.
    public static var zero: Scale = .init(0, 0, 0)
    
    /// No scaling.
    public static var none: Scale = .init()
    
    /**
     Creates a `Scale` with the specified scaling values.
     
     - Parameters:
       - x: The scaling on the x-axis.
       - y: The scaling on the y-axis.
       - z: The scaling on the z-axis.
     */
    public init(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a `Scale` with the specified scaling values.

     - Parameters:
       - x: The scaling on the x-axis.
       - y: The scaling on the y-axis.
       - z: The scaling on the z-axis.
     */
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a `Scale` with the specified scaling on the x- and y-axis.
     
     - Parameters:
       - x: The scaling on the x-axis.
       - y: The scaling on the y-axis.
     */
    public init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a `Scale` with the specified scaling on the x- and y-axis.
     
     - Parameter xy: The scaling on the x- and y-axis.
     */
    public init(_ xy: CGFloat) {
        self.x = xy
        self.y = xy
    }
    
    /**
     Creates a `Scale` with the specified scaling on the x- and y-axis.

     - Parameter value: The scale on the x- and y-axis.
     */
    public init(floatLiteral value: Double) {
        self.x = value
        self.y = value
    }
    
    public var description: String {
        "Scale(x: \(x), y: \(y), z: \(z))"
    }
    
    var vector: CGVector3 {
        .init(x, y, z)
    }
}

extension CGVector3 {
    var scale: Scale {
        .init(x, y, z)
    }
}
#endif
