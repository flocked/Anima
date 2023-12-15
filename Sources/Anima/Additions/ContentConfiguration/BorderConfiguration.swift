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
    /// The color of the border.
    public var color: NSUIColor? = nil
    
    /// The width of the border.
    public var width: CGFloat = 0.0
    
    /// A configuration without border.
    public static func none() -> Self { return Self() }
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
        BorderConfiguration()
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(color: .init([animatableData[0], animatableData[1], animatableData[2], animatableData[3]]), width: animatableData[4])
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { (self.color ?? .zero).animatableData + [width] }
        set { self = .init(newValue) }
    }
}
