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
    func resolved(for view: NSUIView) -> Self {
        var border = self
        border.color = border.color?.resolvedColor(for: view)
        return border
    }
}

extension CALayer {
    @objc dynamic var border: BorderConfiguration {
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
        self.init(color: NSUIColor(.init([animatableData[0], animatableData[1], animatableData[2], animatableData[3], animatableData[4]], .srgb)), width: animatableData[5])
    }

    public var animatableData: AnimatableArray<Double> {
        get { (color ?? .zero).animatableData.elements + [width] }
        set { self = .init(newValue) }
    }
}

/// The Objective-C class for ``BorderConfiguration``.
public class __BorderConfiguration: NSObject, NSCopying {
    let configuration: BorderConfiguration

    public init(configuration: BorderConfiguration) {
        self.configuration = configuration
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        __BorderConfiguration(configuration: configuration)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        configuration == (object as? __BorderConfiguration)?.configuration
    }
}

extension BorderConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __BorderConfiguration

    public func _bridgeToObjectiveC() -> __BorderConfiguration {
        return __BorderConfiguration(configuration: self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __BorderConfiguration, result: inout BorderConfiguration?) {
        result = source.configuration
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __BorderConfiguration, result: inout BorderConfiguration?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __BorderConfiguration?) -> BorderConfiguration {
        if let source = source {
            var result: BorderConfiguration?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return BorderConfiguration()
    }

    public var description: String {
        "(color: \(color?.description ?? "-"), width: \(width))"
    }

    public var debugDescription: String {
        description
    }
}
