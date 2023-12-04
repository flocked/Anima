//
//  AnimationOptions.swift
//
//
//  Created by Florian Zand on 17.11.23.
//

import Foundation

/// Options for animations.
public struct AnimationOptions: OptionSet, Sendable, Hashable {
    public let rawValue: UInt

    /// When the animation finishes the value will be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public static let integralizeValues = AnimationOptions(rawValue: 1 << 0)
    
    /// The animation repeats indefinitely.
    public static let repeats = AnimationOptions(rawValue: 1 << 1)
    
    /// The animation runs backwards and forwards (must be combined with the ``repeats`` option).
    public static let autoreverse = AnimationOptions(rawValue: 1 << 2)
    
    /// The animation starts automatically when it's `target` value changes to a value that isn't equal to it's current `value`.
    public static let autoStarts = AnimationOptions(rawValue: 1 << 3)
    
    internal static let keepVelocity = AnimationOptions(rawValue: 1 << 4)
        
    #if os(iOS) || os(tvOS)
    /// Prevents the user to interact with views while they are being animated.
    public static let preventUserInteraction = AnimationOptions(rawValue: 1 << 5)
    #endif
    
    /// Creates a structure that represents animation options.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

extension AnimationOptions: CustomStringConvertible {
    public var description: String {
        #if os(iOS) || os(tvOS)
        """
        AnimationOptions(
            integralizeValues: \(contains(.integralizeValues))
            repeats: \(contains(.repeats))
            autoreverse: \(contains(.autoreverse))
            autoStarts: \(contains(.autoStarts))
            preventUserInteraction: \(contains(.preventUserInteraction))
        )
        """
        #else
        """
        AnimationOptions(
            integralizeValues: \(contains(.integralizeValues))
            repeats: \(contains(.repeats))
            autoreverse: \(contains(.autoreverse))
            autoStarts: \(contains(.autoStarts))
        )
        """
        #endif
    }
}
