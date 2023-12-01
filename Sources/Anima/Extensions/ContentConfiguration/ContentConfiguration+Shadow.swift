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

public extension ContentConfiguration {
    /**
     A configuration that specifies the appearance of a shadow.
     
     On AppKit `NSView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.Shadow)`.
     
     On UIKit `UIView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.Shadow)`.
     */
    struct Shadow: Hashable {
        /// The color of the shadow.
        public var color: NSUIColor? = .shadowColor
        /// The opacity of the shadow.
        public var opacity: CGFloat = 0.5
        /// The blur radius of the shadow.
        public var radius: CGFloat = 2.0
        /// The offset of the shadow.
        public var offset: CGPoint = .init(x: 1.0, y: -1.5)

        /// A Boolean value that indicates whether the shadow is invisible (when the color is `nil`, `clear` or the opacity `0`).
        public var isInvisible: Bool {
            return (color?.alphaComponent == 0.0 || opacity == 0.0 || color == nil)
        }
        
        /// Initalizes a shadow configuration.
        public init(color: NSUIColor? = nil,
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
        
        /// A default configuration for a black shadow.
        public static func `default`(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { return Self(opacity: opacity, radius: radius, offset: offset) }
        
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
}
