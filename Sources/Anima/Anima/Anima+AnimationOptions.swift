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

        /// The animation automatically starts when the ``ValueAnimation/target`` value changes.
        public static let autoStart = AnimationOptions(rawValue: 1 << 3)

        /**
         The velocity of spring animated properties will be reset.

         Usually the animation velocity is perserved when you spring animate it to another value. This option will reset the velocity for any new spring animation.
         */
        public static let resetSpringVelocity = AnimationOptions(rawValue: 1 << 4)

        /// The spring animation is stopped if it's value is approximately equal to the target value.
        public static let useApproximatelyEqual = AnimationOptions(rawValue: 1 << 5)

        /**
         The value of spring animated properties automatically updates when the target value changes during animation.

         The tracking of a target value only works, if the assigned vallue is a `animator` property.
         
         In the following example, the frame of `otherView` is tracked during animation. If the frame changes, `view` animates to the new frame perserving the velocity:
         
         ```swift
         Anima.animate(withSpring: .bouncy, options: .trackValues) {
            view.animator.frame = otherView.animator.frame
         }
         ```
         */
        public static let trackValues = AnimationOptions(rawValue: 1 << 6)

        /// Prevents the user to interact with views while they are being animated.
        public static let preventUserInteraction = AnimationOptions(rawValue: 1 << 7)
        
        private static let colorSpaceMask: UInt = 0b1_1111 << 8

        /// The color space for animating colors.
        public var colorSpace: ColorSpace {
            get { ColorSpace(rawValue: (rawValue & Self.colorSpaceMask) >> 8) ?? .srgb }
            set {  self = Self(rawValue: (rawValue & ~Self.colorSpaceMask) | (newValue.rawValue << 8)) }
        }

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
            useApproximatelyEqual: \(usesApproximatelyEqual)
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
            useApproximatelyEqual: \(usesApproximatelyEqual)
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
    var usesApproximatelyEqual: Bool { contains(.useApproximatelyEqual) }
    var preventUserInteraction: Bool { contains(.preventUserInteraction) }
}
