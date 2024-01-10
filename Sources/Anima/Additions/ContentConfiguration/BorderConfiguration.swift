//
//  BorderConfiguration.swift
//  
//
//  Created by Florian Zand on 15.12.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

/// A configuration that specifies the appearance of a border.
public struct BorderConfiguration: Hashable {

    #if os(macOS)
    /// The color of the border.
    public var color: NSColor? = .black
    #else
    public var color: UIColor? = .black
    #endif

    /// The width of the border.
    public var width: CGFloat = 2.0

    /// No border.
    public static var none: Self { Self(color: nil) }

    /// A black border.
    public static func black(width: CGFloat = 2.0) -> Self {
        Self(color: .black, width: width)
    }

    #if os(macOS)
    /// A colored border.
    public static func color(_ color: NSColor, width: CGFloat) -> Self {
        Self(color: color, width: width)
    }

    /**
     Creates a border configuration.
     
     - Parameters:
        - color: The border color. The default value is `black`.
        - width: The border width. The default value is `2.0`.
     */
    public init(color: NSColor? = .black, width: CGFloat = 2.0) {
        self.color = color
        self.width = width
    }

    /// A  border with control accent color.
    public static func controlAccent(width: CGFloat = 2.0) -> Self {
        Self(color: .controlAccentColor, width: width)
    }
    #else
    /**
     Creates a border configuration.
     
     - Parameters:
        - color: The border color. The default value is `black`.
        - width: The border width. The default value is `2.0`.
     */
    public init(color: UIColor? = .black, width: CGFloat = 2.0) {
        self.color = color
        self.width = width
    }

    /// A colored border.
    public static func color(_ color: UIColor, width: CGFloat) -> Self {
        Self(color: color, width: width)
    }
    #endif
}

extension CALayer {
    var border: BorderConfiguration {
        get { BorderConfiguration(color: borderColor?.nsUIColor, width: borderWidth) }
        set {
            borderColor = newValue.color?.cgColor
            borderWidth = newValue.width
        }
    }
}

extension BorderConfiguration: AnimatableProperty, Animatable {
    public static var zero: BorderConfiguration {
        BorderConfiguration.none
    }

    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(color: .init([animatableData[0], animatableData[1], animatableData[2], animatableData[3]]), width: animatableData[4])
    }

    public var animatableData: AnimatableArray<Double> {
        get { (self.color ?? .zero).animatableData + [width] }
        set { self = .init(newValue) }
    }
}
