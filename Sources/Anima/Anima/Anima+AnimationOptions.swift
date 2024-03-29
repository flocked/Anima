//
//  Anima+AnimationOptions.swift
//
//
//  Created by Florian Zand on 17.11.23.
//

import Foundation

public extension Anima {
    /// Options for animations.
    struct AnimationOptions: OptionSet, Sendable, Hashable {
        public let rawValue: UInt

        /// When the animation finishes the value will be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
        public static let integralizeValues = AnimationOptions(rawValue: 1 << 0)

        /// The animation repeats indefinitely.
        public static let repeats = AnimationOptions(rawValue: 1 << 1)

        /// The animation runs backwards and forwards (must be combined with the ``repeats`` option).
        public static let autoreverse = AnimationOptions(rawValue: 1 << 2)

        /// The animation automatically starts when the ``target`` value changes.
        public static let autoStart = AnimationOptions(rawValue: 1 << 3)
        
        /**
         The velocity of spring animated properties will be reset.

         Usually the animation velocity is perserved when you spring animate it to another value. This option will reset the velocity for any new spring animation.
         */
        public static let resetSpringVelocity = AnimationOptions(rawValue: 1 << 4)
        
        #if os(iOS) || os(tvOS)
            /// Prevents the user to interact with views while they are being animated.
            public static let preventUserInteraction = AnimationOptions(rawValue: 1 << 5)
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
                integralizeValues: \(integralizeValues)
                repeats: \(repeats)
                autoreverse: \(autoreverse)
                autoStarts: \(autoStarts)
                resetSpringVelocity: \(resetSpringVelocity)
                preventUserInteraction: \(preventUserInteraction)
            )
            """
        #else
            """
            AnimationOptions(
                integralizeValues: \(integralizeValues)
                repeats: \(repeats)
                autoreverse: \(autoreverse)
                autoStarts: \(autoStarts)
                resetSpringVelocity: \(resetSpringVelocity)
            )
            """
        #endif
    }
}

extension Anima.AnimationOptions {
    var repeats: Bool { contains(.repeats) }
    var integralizeValues: Bool { contains(.integralizeValues) }
    var autoreverse: Bool { contains(.autoreverse) }
    var resetSpringVelocity: Bool { contains(.resetSpringVelocity) }
    var autoStarts: Bool { contains(.autoStart) }
    #if os(iOS) || os(tvOS)
    var preventUserInteraction: Bool { contains(.preventUserInteraction) }
    #endif
}
