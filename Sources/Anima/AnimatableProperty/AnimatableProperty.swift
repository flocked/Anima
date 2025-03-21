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

// MARK: - AnimatableProperty

/**
 A type that describes an animatable value.

 `Anima` can animate any type conforming to this protocol. It uses `animatableData` to calculate new values in an animation.

 If the type you want to conform has many properties, consider using an array with elements conforming to ``AnimatableProperty`` (e.g. `Double`, `Float` or `CGFloat`).

 Example conformance:
 ```swift
 struct AnimatableStruct {
    let value: Double
    let point: CGPoint
 }

 extension AnimatableStruct: AnimatableProperty {
    init(_ animatableData: [Double]) {
        value = animatableData[0]
        point = CGPoint(x: animatableData[1], y: animatableData[2])
    }

    var animatableData: [Double] {
        [value, point.x, point.y]
    }

    static let zero = AnimatableStruct(value: 0, point: .zero)
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

    /// The scaled integral representation of this value. The default implementation returns the non-integral value.
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
        optional?.animatableData ?? Wrapped.zero.animatableData
    }

    public init(_ animatableData: Wrapped.AnimatableData) {
        self = Wrapped(animatableData)
    }

    public static var zero: Wrapped? {
        Wrapped.zero
    }
}

public extension AnimatableProperty where Self.AnimatableData == Self {
    var animatableData: Self {
        self
    }

    init(_ animatableData: Self) {
        self = animatableData
    }
}

extension Float: AnimatableProperty {
    public var scaledIntegral: Self {
        #if os(macOS)
            let scale = Self(NSScreen.main?.backingScaleFactor ?? 1.0)
        #elseif os(iOS) || os(tvOS)
        let scale = Float(UIScreen.main?.scale ?? 1.0)
        #else
            let scale: Float = 1.0
        #endif
        return rounded(toNearest: 1.0 / scale)
    }
}

extension Double: AnimatableProperty {
    public var animatableData: Self {
        self
    }

    public init(_ animatableData: Self) {
        self = animatableData
    }

    public var scaledIntegral: Self {
        #if os(macOS)
            let scale = Self(NSScreen.main?.backingScaleFactor ?? 1.0)
        #elseif os(iOS) || os(tvOS)
        let scale = UIScreen.main?.scale ?? 1.0
        #else
            let scale = 1.0
        #endif
        return rounded(toNearest: 1.0 / scale)
    }
}

extension CGFloat: AnimatableProperty {
    public var animatableData: Self {
        self
    }

    public init(_ animatableData: Self) {
        self = animatableData
    }

    public var scaledIntegral: Self {
        #if os(macOS)
            let scale = NSScreen.main?.backingScaleFactor ?? 1.0
        #elseif os(iOS) || os(tvOS)
        let scale = UIScreen.main?.scale ?? 1.0
        #else
            let scale = 1.0
        #endif
        return rounded(toNearest: 1.0 / scale)
    }
}

public extension AnimatableProperty where Self: NSNumber {
    init(_ animatableData: AnimatableArray<Double>) {
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

#if os(macOS)
    public extension AnimatableProperty where Self: NSColor {
        init(_ animatableData: AnimatableArray<Double>) {
            #if os(macOS)
                self.init(deviceRed: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
            #else
                self.init(red: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
            #endif
        }
    }

    extension NSColor: AnimatableProperty {
        public var animatableData: AnimatableArray<Double> {
            let rgba = rgbaComponents()
            return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
        }

        public static var zero: Self {
            Self(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }
#else
    public extension AnimatableProperty where Self: UIColor {
        init(_ animatableData: AnimatableArray<Double>) {
            #if os(macOS)
                self.init(deviceRed: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
            #else
                self.init(red: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
            #endif
        }
    }

    extension UIColor: AnimatableProperty {
        public var animatableData: AnimatableArray<Double> {
            let rgba = rgbaComponents()
            return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
        }

        public static var zero: Self {
            Self(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }
#endif

public extension AnimatableProperty where Self: CGColor {
    init(_ animatableData: AnimatableArray<Double>) {
        self = NSUIColor(animatableData).cgColor as! Self
    }
}

extension CGColor: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        nsUIColor?.animatableData ?? [0, 0, 0, 0]
    }

    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension CGAffineTransform: AnimatableProperty, Animatable {
    @inlinable public init(_ animatableData: AnimatableArray<Double>) {
        self.init(animatableData[0], animatableData[1], animatableData[2], animatableData[3], animatableData[4], animatableData[5])
    }

    public var animatableData: AnimatableArray<Double> {
        get { [a, b, c, d, tx, ty, 0, 0] }
        set { self = .init(newValue) }
    }

    public static var zero: CGAffineTransform {
        CGAffineTransform()
    }
}

extension NSDirectionalEdgeInsets: AnimatableProperty, Animatable {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(top: animatableData[0], leading: animatableData[1], bottom: animatableData[2], trailing: animatableData[3])
    }

    public var animatableData: AnimatableArray<Double> {
        get { [top, bottom, leading, trailing] }
        set { self = .init(newValue) }
    }
}

#if os(macOS)
    extension NSEdgeInsets: AnimatableProperty, Animatable {
        public var animatableData: AnimatableArray<Double> {
            get { [top, left, bottom, right] }
            set { self = .init(newValue) }
        }

        public init(_ animatableData: AnimatableArray<Double>) {
            self.init(top: animatableData[0], left: animatableData[1], bottom: animatableData[2], right: animatableData[3])
        }
    }
#else
    extension UIEdgeInsets: AnimatableProperty, Animatable {
        public var animatableData: AnimatableArray<Double> {
            get { [top, left, bottom, right] }
            set { self = .init(newValue) }
        }

        public init(_ animatableData: AnimatableArray<Double>) {
            self.init(top: animatableData[0], left: animatableData[1], bottom: animatableData[2], right: animatableData[3])
        }
    }
#endif

extension CGVector: AnimatableProperty, Animatable {
    public var animatableData: AnimatableArray<Double> {
        get { [dx, dy] }
        set { self = .init(newValue) }
    }

    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(dx: animatableData[0], dy: animatableData[1])
    }
}

extension CATransform3D: AnimatableProperty, Animatable {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(m11: animatableData[0], m12: animatableData[1], m13: animatableData[2], m14: animatableData[3], m21: animatableData[4], m22: animatableData[5], m23: animatableData[6], m24: animatableData[7], m31: animatableData[8], m32: animatableData[9], m33: animatableData[10], m34: animatableData[11], m41: animatableData[12], m42: animatableData[13], m43: animatableData[14], m44: animatableData[15])
    }

    public var animatableData: AnimatableArray<Double> {
        get { [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44] }
        set { self = .init(newValue) }
    }
}

extension CGQuaternion: AnimatableProperty, Animatable {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(angle: animatableData[0], axis: .init(animatableData[1], animatableData[2], animatableData[3]))
    }

    public var animatableData: AnimatableArray<Double> {
        get { [angle, axis.x, axis.y, axis.z] }
        set { self = .init(newValue) }
    }

    public static var zero: CGQuaternion {
        CGQuaternion(angle: 0, axis: .init(0, 0, 0))
    }
}

extension CGVector3: AnimatableProperty, Animatable {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(animatableData[0], animatableData[1], animatableData[2])
    }

    public var animatableData: AnimatableArray<Double> {
        get { [x, y, z] }
        set { self = .init(newValue) }
    }

    public static var zero: CGVector3 {
        CGVector3(0, 0, 0)
    }
}

extension CGVector4: AnimatableProperty, Animatable {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(m14: animatableData[0], m24: animatableData[1], m34: animatableData[2], m44: animatableData[3])
    }

    public var animatableData: AnimatableArray<Double> {
        get { [m14, m24, m34, m44] }
        set { self = .init(newValue) }
    }

    public static var zero: CGVector4 {
        CGVector4(0, 0, 0, 0)
    }
}

extension Array: AnimatableProperty, AdditiveArithmetic, VectorArithmetic where Element: AnimatableProperty {
    public init(_ animatableData: AnimatableArray<Element.AnimatableData>) {
        self.init(animatableData.elements.compactMap { Element($0) })
    }

    public var animatableData: AnimatableArray<Element.AnimatableData> { AnimatableArray<Element.AnimatableData>(compactMap({$0.animatableData})) }

    public static var zero: [Element] {
        Self()
    }
    
    public static func + (lhs: Array, rhs: Array) -> Array {
        .init(lhs.animatableData + rhs.animatableData)
    }
    
    public static func - (lhs: Array, rhs: Array) -> Array {
        .init(lhs.animatableData - rhs.animatableData)
    }
    
    public mutating func scale(by rhs: Double) {
        self = .init(animatableData.scaled(by: rhs))
    }
    
    public var magnitudeSquared: Double {
        self.animatableData.magnitudeSquared
    }
    
    public var scaledIntegral: Array {
        self.compactMap({$0.scaledIntegral})
    }
    
    subscript(safe index: Index) -> Element? {
        get {
            guard !isEmpty, index >= 0, index < count else { return nil }
            return self[index]
        }
        set {
            guard !isEmpty, index >= 0, index < count, let newValue = newValue else { return }
            self[index] = newValue
        }
    }
}

extension Range: AnimatableProperty where Bound: VectorArithmetic {
    public var animatableData: AnimatableArray<Bound> {
        [lowerBound, upperBound]
    }
    
    public init(_ animatableData: AnimatableArray<Bound>) {
        self = animatableData[0]..<animatableData[1]
    }
    
    public static var zero: Range {
        Bound.zero..<Bound.zero
    }
}

extension ClosedRange: AnimatableProperty where Bound: VectorArithmetic {
    public var animatableData: AnimatableArray<Bound> {
        [lowerBound, upperBound]
    }
    
    public init(_ animatableData: AnimatableArray<Bound>) {
        self = animatableData[0]...animatableData[1]
    }
    
    public static var zero: ClosedRange {
        Bound.zero...Bound.zero
    }
}

// MARK: - AnimatableColor

// Updates colors for better interpolation/animations.
protocol AnimatableColor: AnimatableProperty where AnimatableData == AnimatableArray<Double> {
    var alpha: CGFloat { get }
    func animatable(to other: any AnimatableColor) -> Self
}

extension AnimatableColor {
    func animatable(to other: any AnimatableColor) -> Self {
        if alpha == 0.0 {
            var animatableData = other.animatableData
            animatableData[safe: 3] = 0.0
            return Self(animatableData)
        }
        return self
    }
}

extension CGColor: AnimatableColor {}

extension NSUIColor: AnimatableColor {
    var alpha: CGFloat {
        alphaComponent
    }
}

extension Optional: AnimatableColor where Wrapped: AnimatableColor {
    var alpha: CGFloat {
        optional?.alpha ?? 0.0
    }
}

// MARK: - AnimatableConfiguration

// Updates shadows and shadow configuration for better interpolation/animations.
protocol AnimatableConfiguration {
    var color: NSUIColor? { get set }
    func animatable(to other: any AnimatableConfiguration) -> Self
}

extension AnimatableConfiguration {
    func animatable(to other: AnimatableConfiguration) -> Self {
        var configuration = self
        if color == nil || color?.alpha == 0.0, let otherColor = other.color {
            configuration.color = otherColor.withAlphaComponent(0.0)
        }
        return configuration
    }
}

extension ShadowConfiguration: AnimatableConfiguration {}

extension BorderConfiguration: AnimatableConfiguration {}

extension Optional: AnimatableConfiguration where Wrapped: AnimatableConfiguration {
    var color: NSUIColor? {
        get { self?.color }
        set { self?.color = newValue }
    }
}

// MARK: - AnimatableCollection

// Ensures two collections have the same count for animating between them. If a collection is smaller zero values are added.
protocol AnimatableCollection: RangeReplaceableCollection, BidirectionalCollection {
    var count: Int { get }
    func animatable(to collection: any AnimatableCollection) -> Self
}

extension AnimatableArray: AnimatableCollection {
    func animatable(to collection: any AnimatableCollection) -> Self {
        let diff = collection.count - count
        return diff > 0 ? (self + Array(repeating: .zero, count: diff)) : self
    }
}

extension Array: AnimatableCollection where Self: AnimatableProperty {
    func animatable(to collection: any AnimatableCollection) -> Self {
        let diff = collection.count - count
        return diff > 0 ? (self + Array(repeating: .zero, count: diff)) : self
    }
}

typealias AnimatablePairCGFloat = AnimatablePair<CGFloat, CGFloat>
typealias AnimatablePairCGRect = AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>
