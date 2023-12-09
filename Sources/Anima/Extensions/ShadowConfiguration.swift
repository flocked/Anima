//
//  ContentConfiguration+Shadow.swift
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
    /// The color of the shadow.
    public var color: NSUIColor? = .black
    
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
    
    /// Initalizes an inner shadow configuration.
    public init(color: NSUIColor? = .black,
        opacity: CGFloat = 0.3,
        radius: CGFloat = 2.0,
        offset: CGPoint = CGPoint(x: 1.0, y: -1.5))
    {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }

    /// A configuration without shadow.
    public static func none() -> Self { return Self(color: nil, opacity: 0.0) }
    
    /// A configuration for a black shadow.
    public static func black(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { return Self(color: .black, opacity: opacity, radius: radius, offset: offset) }
    
    #if os(macOS)
    /// A configuration for a accent color shadow.
    public static func accentColor(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { return Self(color: .controlAccentColor, opacity: opacity, radius: radius, offset: offset) }
    #endif
    
    /// A configuration for a shadow with the specified color.
    public static func color(_ color: NSUIColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        return Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
}

extension NSUIView {
    /**
     Configurates the inner shadow of the view.

     - Parameters:
        - configuration:The configuration for configurating the inner shadow.
     */
    func configurateInnerShadow(using configuration: ShadowConfiguration) {
        #if os(macOS)
        wantsLayer = true
        var configuration = configuration
        configuration.color = configuration.color?.resolvedColor(for: effectiveAppearance)
        layer?.configurateInnerShadow(using: configuration)
        #else
        layer.configurateInnerShadow(using: configuration)
        #endif
    }
    
    var innerShadowLayer: InnerShadowLayer? {
        #if os(macOS)
         self.layer?.firstSublayer(type: InnerShadowLayer.self)
        #else
        self.layer.firstSublayer(type: InnerShadowLayer.self)
        #endif
    }
}

extension CALayer {
    /**
     Configurates the inner shadow of the layer.

     - Parameters:
        - configuration:The configuration for configurating the inner shadow.
     */
    func configurateInnerShadow(using configuration: ShadowConfiguration) {
        if configuration.isInvisible {
            self.innerShadowLayer?.removeFromSuperlayer()
        } else {
            if self.innerShadowLayer == nil {
                let innerShadowLayer = InnerShadowLayer()
                self.addSublayer(withConstraint: innerShadowLayer)
                innerShadowLayer.sendToBack()
                innerShadowLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
            }
            self.innerShadowLayer?.configuration = configuration
        }
    }
    
    var innerShadowLayer: InnerShadowLayer? {
        self.firstSublayer(type: InnerShadowLayer.self)
    }
}