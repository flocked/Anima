//
//  AnimatableProperty.swift
//
//
//  Created by Florian Zand on 12.10.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import Decomposed

/**
 A type that describes an animatable value.
  
 Example usage:
 ```swift
 struct MyStruct {
    let value: Double
    let point: CGPoint
 }
 
 extension MyStruct: AnimatableProperty {
    init(_ animatableData: AnimatableArray<Double>) {
        value = animatableData[0]
        point = CGPoint(x: animatableData[1], y: animatableData[2])
    }
 
    var animatableData: AnimatableArray<Double> {
        [value, point.x, point.y]
    }
 
    static let zero = MyStruct(value: 0, point: .zero)
 }
 ```
 */
public protocol AnimatableProperty: Equatable {
    
    /// The type defining the animatable representation of the value.
    associatedtype AnimatableData: VectorArithmetic
    
    /// The animatable representation of the value.
    var animatableData: AnimatableData { get }
    
    /// Initializes the value with the specified animatable representation of the value.
    init(_ animatableData: AnimatableData)
    
    /// The scaled integral representation of this value.
    var scaledIntegral: Self { get }
    
    /// The zero value.
    static var zero: Self { get }
}

public extension AnimatableProperty {
    var scaledIntegral: Self {
        self
    }
}

extension Optional: AnimatableProperty where Wrapped: AnimatableProperty {
    public var animatableData: Wrapped.AnimatableData {
        self.optional?.animatableData ?? Wrapped.zero.animatableData
    }
    
    public init(_ animatableData: Wrapped.AnimatableData) {
        self = Wrapped.init(animatableData)
    }
    
    public static var zero: Optional<Wrapped> {
        Wrapped.zero
    }
}

extension AnimatableProperty where Self.AnimatableData == Self {
    public var animatableData: Self {
        self
    }
    
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension Float: AnimatableProperty { }
 
extension Double: AnimatableProperty {
    public var animatableData: Self {
        self
    }
    
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension CGFloat: AnimatableProperty {
    public var animatableData: Self {
        self
    }
    
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension AnimatableProperty where Self: NSNumber {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(value: animatableData[0])
    }
}

extension NSNumber: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        [doubleValue]
    }
    
    public static var zero: Self {
        Self(value: 0.0)
    }
}

extension CGPoint: AnimatableProperty {
    public init(_ animatableData: AnimatablePair<CGFloat, CGFloat>) {
        self.init(animatableData.first, animatableData.second)
    }
}

extension CGSize: AnimatableProperty {
    public init(_ animatableData: AnimatablePair<CGFloat, CGFloat>) {
        self.init(width: animatableData.first, height: animatableData.second)
    }
}

extension CGRect: AnimatableProperty {
    public init(_ animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData>) {
        self.init(origin: CGPoint(animatableData.first), size: CGSize(animatableData.second))
    }
}

extension AnimatableProperty where Self: NSUIColor {
    public init(_ animatableData: AnimatableArray<Double>) {
        #if os(macOS)
        self.init(deviceRed: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
        #else
        self.init(red: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
        #endif
    }
}

extension NSUIColor: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        let rgba = self.rgbaComponents()
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
    
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension AnimatableProperty where Self: CGColor {
    public init(_ animatableData: AnimatableArray<Double>) {
        self = NSUIColor(animatableData).cgColor as! Self
    }
}

extension CGColor: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        self.nsUIColor?.animatableData ?? [0,0,0,0]
    }
    
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension CGAffineTransform: AnimatableProperty {
    @inlinable public init(_ animatableData: AnimatableArray<Double>) {
        self.init(animatableData[0], animatableData[1], animatableData[2], animatableData[3], animatableData[4], animatableData[5])
    }
    
    public var animatableData: AnimatableArray<Double> {
        return [a, b, c, d, tx, ty, 0, 0]
    }
    
    public static var zero: CGAffineTransform {
        CGAffineTransform()
    }
}

extension NSDirectionalEdgeInsets: AnimatableProperty {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(top: animatableData[0], leading: animatableData[1], bottom: animatableData[2], trailing: animatableData[3])
    }
    
    public var animatableData: AnimatableArray<Double> {
        [top, bottom, leading, trailing]
    }
}

#if os(macOS)
extension NSEdgeInsets: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        [top, self.left, bottom, self.right]
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(top: animatableData[0], left: animatableData[1], bottom: animatableData[2], right: animatableData[3])
    }
}
#else
extension UIEdgeInsets: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        [top, self.left, bottom, self.right]
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(top: animatableData[0], left: animatableData[1], bottom: animatableData[2], right: animatableData[3])
    }
}
#endif
extension CGVector: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        [dx, dy]
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(dx: animatableData[0], dy: animatableData[1])
    }
}

extension CATransform3D: AnimatableProperty {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(m11: animatableData[0], m12: animatableData[1], m13: animatableData[2], m14: animatableData[3], m21: animatableData[4], m22: animatableData[5], m23: animatableData[6], m24: animatableData[7], m31: animatableData[8], m32: animatableData[9], m33: animatableData[10], m34: animatableData[11], m41: animatableData[12], m42: animatableData[13], m43: animatableData[14], m44: animatableData[15])
    }
    
    public var animatableData: AnimatableArray<Double> {
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
    }
}

extension CGQuaternion: AnimatableProperty {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(angle: animatableData[0], axis: .init(animatableData[1], animatableData[2], animatableData[3]))
    }
    
    public var animatableData: AnimatableArray<Double> {
        [self.angle, self.axis.x, self.axis.y, self.axis.z]
    }
    
    public static var zero: CGQuaternion {
        CGQuaternion.init(angle: 0, axis: .init(0, 0, 0))
    }
}

extension ContentConfiguration.Shadow: AnimatableProperty, Animatable {
    public static var zero: ContentConfiguration.Shadow {
        .none()
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(color: .init([animatableData[0], animatableData[1], animatableData[2], animatableData[3]]), opacity: animatableData[4], radius: animatableData[5], offset: .init(animatableData[6], animatableData[7]))
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { (self.color ?? .zero).animatableData + [opacity, radius, offset.x, offset.y] }
        set { self = .init(newValue) }
    }
}

extension ContentConfiguration.InnerShadow: AnimatableProperty, Animatable {
    public static var zero: ContentConfiguration.InnerShadow {
        .none()
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(color: .init([animatableData[0], animatableData[1], animatableData[2], animatableData[3]]), opacity: animatableData[4], radius: animatableData[5], offset: .init(animatableData[6], animatableData[7]))
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { (self.color ?? .zero).animatableData + [opacity, radius, offset.x, offset.y] }
        set { self = .init(newValue) }
    }
}

// Ensures that two collections have the same amount of values for animating between them. If a collection is smaller than the other zero values are added.
internal protocol AnimatableCollection: RangeReplaceableCollection, BidirectionalCollection {
    var count: Int { get }
    // Ensures both collections have the same amount of values for animating between them.
    func animatable(to collection: any AnimatableCollection) -> Self
}

public protocol AnimatableColor: AnimatableProperty where AnimatableData == AnimatableArray<Double> {
    var alpha: CGFloat { get }
    func animatable(to other: any AnimatableColor) -> Self
}

public extension AnimatableColor {
    func animatable(to other: any AnimatableColor) -> Self {
        if self.alpha == 0.0 {
            var animatableData = other.animatableData
            animatableData[safe: 3] = 0.0
            return Self(animatableData)
        }
        return self
    }
}

extension CGColor: AnimatableColor { }

extension NSUIColor: AnimatableColor {
    public var alpha: CGFloat {
        return alphaComponent
    }
}

extension Optional: AnimatableColor where Wrapped: AnimatableColor {
    public var alpha: CGFloat {
        self.optional?.alpha ?? 0.0
    }
}

/*
internal extension CGColor {
    func animatable(to other: CGColor) -> CGColor {
        self.alpha == 0 ? other.copy(alpha: 0.0) ?? self : self
    }
}

internal extension NSUIColor {
    func animatable(to other: NSUIColor) -> NSUIColor {
        self.alphaComponent == 0 ? other.withAlphaComponent(0.0) : self
    }
}
 */

extension Array: AnimatableProperty, AnimatableCollection where Element: AnimatableProperty {
    public init(_ animatableData: AnimatableArray<Element.AnimatableData>) {
        self.init(animatableData.elements.compactMap({Element($0)}))
    }
    
    public var animatableData: AnimatableArray<Element.AnimatableData> {
        get { AnimatableArray<Element.AnimatableData>(self.compactMap({$0.animatableData})) }
    }
    
    public static var zero: Array<Element> {
        Self.init()
    }

    internal func animatable(to collection: any AnimatableCollection) -> Self {
        let diff = collection.count - self.count
        return diff > 0 ? (self + Array(repeating: .zero, count: diff)) : self
    }
}

extension AnimatableArray: AnimatableCollection {
    internal func animatable(to collection: any AnimatableCollection) -> Self {
        let diff = collection.count - self.count
        return diff > 0 ? (self + Array(repeating: .zero, count: diff)) : self
    }
}

extension Array: Animatable where Element: Animatable { }
