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
        return (color?.alphaComponent == 0.0 || opacity == 0.0 || color == nil)
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
        offset: CGPoint = CGPoint(x: 1.0, y: -1.5))
    {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }
    
    /// A colored shadow.
    public static func color(_ color: NSColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        return Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
    
    /// A shadow with control accent color.
    public static func controlAccent(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { return Self(color: .controlAccentColor, opacity: opacity, radius: radius, offset: offset) }
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
        offset: CGPoint = CGPoint(x: 1.0, y: -1.5))
    {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }
    
    /// A colored shadow.
    public static func color(_ color: UIColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        return Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
    #endif
    
    // MARK: - Built-in shadow configurations

    /// No shadow.
    public static var none: Self { Self(color: nil, opacity: 0.0) }
    
    /// A black shadow.
    public static func black(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { return Self(color: .black, opacity: opacity, radius: radius, offset: offset) }
}

extension ShadowConfiguration: AnimatableProperty, Animatable {
    public static var zero: ShadowConfiguration {
        .none
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(color: .init([animatableData[0], animatableData[1], animatableData[2], animatableData[3]]), opacity: animatableData[4], radius: animatableData[5], offset: .init(animatableData[6], animatableData[7]))
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { (self.color ?? .zero).animatableData + [opacity, radius, offset.x, offset.y] }
        set { self = .init(newValue) }
    }
}

extension CALayer {
    /// The shadow of the layer.
    var shadow: ShadowConfiguration {
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
    var innerShadow: ShadowConfiguration {
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
