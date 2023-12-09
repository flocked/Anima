//
//  AnimationOptions.swift
//
//
//  Created by Florian Zand on 17.11.23.
//

import Foundation

extension Anima {
    /// Options for animations.
    public struct AnimationOptions: OptionSet, Sendable, Hashable {
        public let rawValue: UInt
        
        /// When the animation finishes the value will be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
        public static let integralizeValues = AnimationOptions(rawValue: 1 << 0)
        
        /// The animation repeats indefinitely.
        public static let repeats = AnimationOptions(rawValue: 1 << 1)
        
        /// The animation runs backwards and forwards (must be combined with the ``repeats`` option).
        public static let autoreverse = AnimationOptions(rawValue: 1 << 2)
        
        /// Usually the velocity of a spring animated property is perseved when you animate it to another value. This option will reset the velocity for any new spring animation.
        public static let resetSpringVelocity = AnimationOptions(rawValue: 1 << 3)
        
#if os(iOS) || os(tvOS)
        /// Prevents the user to interact with views while they are being animated.
        public static let preventUserInteraction = AnimationOptions(rawValue: 1 << 4)
#endif
        
        /// Creates a structure that represents animation options.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
}

extension Anima.AnimationOptions: CustomStringConvertible {
    public var description: String {
        #if os(iOS) || os(tvOS)
        """
        AnimationOptions(
            integralizeValues: \(contains(.integralizeValues))
            repeats: \(contains(.repeats))
            autoreverse: \(contains(.autoreverse))
            resetSpringVelocity: \(contains(.resetSpringVelocity))
            preventUserInteraction: \(contains(.preventUserInteraction))
        )
        """
        #else
        """
        AnimationOptions(
            integralizeValues: \(contains(.integralizeValues))
            repeats: \(contains(.repeats))
            autoreverse: \(contains(.autoreverse))
            resetSpringVelocity: \(contains(.resetSpringVelocity))
        )
        """
        #endif
    }
}
