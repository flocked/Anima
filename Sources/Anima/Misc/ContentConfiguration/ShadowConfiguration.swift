//
//  ShadowConfiguration.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

/// A configuration that specifies the appearance of a shadow.
public struct ShadowConfiguration: Hashable {
    // MARK: - Configurating the shadow

    #if os(macOS)
    /// The color of the shadow.
    public var color: NSColor? = .black
    #else
    /// The color of the shadow.
    public var color: UIColor? = .black
    #endif

    /// The opacity of the shadow.
    public var opacity: CGFloat = 0.3

    /// The blur radius of the shadow.
    public var radius: CGFloat = 2.0

    /// The offset of the shadow.
    public var offset: CGPoint = .init(x: 1.0, y: -1.5)

    /// A Boolean value that indicates whether the shadow is invisible (when the color is `nil`, `clear` or the opacity `0`).
    var isInvisible: Bool {
        (color?.alphaComponent == 0.0 || opacity == 0.0 || color == nil)
    }

    // MARK: - Creating the shadow configuration

    #if os(macOS)
    /**
     Creates a shadow configuration.

     - Parameters:
        - color: The shadow color. The default value is `black`.
        - opacity: The shadow opacity. The default value is `0.3`.
        - radius: The shadow radius. The default value is `2.0`.
        - offset: The shadow offset. The default value is `CGPoint(x: 1.0, y: -1.5)`.
     */
    public init(
        color: NSColor? = .black,
        opacity: CGFloat = 0.3,
        radius: CGFloat = 2.0,
        offset: CGPoint = CGPoint(x: 1.0, y: -1.5)
    ) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }

    /// A colored shadow.
    public static func color(_ color: NSColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }

    /// A shadow with control accent color.
    public static func controlAccent(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { Self(color: .controlAccentColor, opacity: opacity, radius: radius, offset: offset) }
    #else
    /**
     Creates a shadow configuration.

     - Parameters:
        - color: The shadow color. The default value is `black`.
        - opacity: The shadow opacity. The default value is `0.3`.
        - radius: The shadow radius. The default value is `2.0`.
        - offset: The shadow offset. The default value is `CGPoint(x: 1.0, y: -1.5)`.
     */
    public init(
        color: UIColor? = .black,
        opacity: CGFloat = 0.3,
        radius: CGFloat = 2.0,
        offset: CGPoint = CGPoint(x: 1.0, y: -1.5)
    ) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }

    /// A colored shadow.
    public static func color(_ color: UIColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
    #endif

    // MARK: - Built-in shadow configurations

    /// No shadow.
    public static var none: Self { Self(color: nil, opacity: 0.0) }

    /// A black shadow.
    public static func black(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { Self(color: .black, opacity: opacity, radius: radius, offset: offset) }

    func resolved(for view: NSUIView) -> Self {
        var shadow = self
        shadow.color = shadow.color?.resolvedColor(for: view)
        return shadow
    }
}

extension ShadowConfiguration: AnimatableProperty, Animatable {
    public static var zero: ShadowConfiguration {
        .none
    }

    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(color: NSUIColor(.init([animatableData[0], animatableData[1], animatableData[2], animatableData[3], animatableData[4]], .srgb)), opacity: animatableData[5], radius: animatableData[6], offset: .init(animatableData[7], animatableData[8]))
    }

    public var animatableData: AnimatableArray<Double> {
        get { (color ?? .zero).animatableData.elements + [opacity, radius, offset.x, offset.y] }
        set { self = .init(newValue) }
    }
}

extension CALayer {
    /// The shadow of the layer.
    @objc dynamic var shadow: ShadowConfiguration {
        get { .init(color: shadowColor?.nsUIColor, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point) }
        set {
            masksToBounds = false
            shadowColor = newValue.color?.cgColor
            shadowOpacity = Float(newValue.opacity)
            shadowRadius = newValue.radius
            shadowOffset = newValue.offset.size
        }
    }

    /// The inner shadow of the layer.
    @objc dynamic var innerShadow: ShadowConfiguration {
        get { innerShadowLayer?.configuration ?? .none }
        set {
            if newValue.isInvisible {
                innerShadowLayer?.removeFromSuperlayer()
            } else {
                if innerShadowLayer == nil {
                    let innerShadowLayer = InnerShadowLayer()
                    addSublayer(withConstraint: innerShadowLayer)
                    innerShadowLayer.sendToBack()
                    innerShadowLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
                }
                innerShadowLayer?.configuration = newValue
            }
        }
    }

    var innerShadowLayer: InnerShadowLayer? {
        firstSublayer(type: InnerShadowLayer.self)
    }
}

/// The Objective-C class for ``ShadowConfiguration``.
public class __ShadowConfiguration: NSObject, NSCopying {
    let configuration: ShadowConfiguration

    public init(configuration: ShadowConfiguration) {
        self.configuration = configuration
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        __ShadowConfiguration(configuration: configuration)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        configuration == (object as? __ShadowConfiguration)?.configuration
    }
}

extension ShadowConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __ShadowConfiguration

    public func _bridgeToObjectiveC() -> __ShadowConfiguration {
        return __ShadowConfiguration(configuration: self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __ShadowConfiguration, result: inout ShadowConfiguration?) {
        result = source.configuration
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __ShadowConfiguration, result: inout ShadowConfiguration?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __ShadowConfiguration?) -> ShadowConfiguration {
        if let source = source {
            var result: ShadowConfiguration?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return ShadowConfiguration()
    }

    public var description: String {
        "(color: \(color?.description ?? "-"), opacity: \(opacity), radius: \(radius), offset: \(offset))"
    }

    public var debugDescription: String {
        description
    }
}
