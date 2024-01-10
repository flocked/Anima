//
//  CAKeyframeAnimationEmittable+Layer.swift
//
//  Copyright (c) 2020, Adam Bell
//  Modifed:
//  Florian Zand on 02.11.23.
//

import Foundation
import QuartzCore

public extension CALayer {
    /**
     Adds a supported animation conforming to `CAKeyframeAnimationEmittable` to the layer.

     This method generates a pre-configured `CAKeyframeAnimation` from the supplied animation and adds it to the supplied layer, animating the given key path.

     - Parameters:
        - animation: An animation that conforms to `CAKeyframeAnimationEmittable`.
        - key: The key to be associated with the generated `CAKeyframeAnimation` when added to the layer.
        - keyPath: The key path to animate. The key path is relative to the layer.
     */
    func add(_ animation: CAKeyframeAnimationEmittable, forKey key: String, keyPath: String) {
        if keyPath.isEmpty {
            assertionFailure("The keyPath must not be nil.")
            return
        }

        let keyframeAnimation = animation.keyframeAnimation(forFramerate: nil)
        keyframeAnimation.keyPath = keyPath
        add(keyframeAnimation, forKey: key)
    }

    /**
     Adds a decay animation to the layer.

     This method generates a pre-configured `CAKeyframeAnimation` from the supplied spring animator and adds it to the supplied layer, animating the given key path.

     - Parameters:
        - decayAnimation: The decay animation.
        - key: The key to be associated with the generated `CAKeyframeAnimation` when added to the layer. The default value is `nil` which uses the keypath as key.
        - keyPath: The key path to animate.
     */
    func add<T: AnimatableProperty & CAKeyframeAnimationValueConvertible>(_ decayAnimation: DecayAnimation<T>, forKey key: String? = nil, keyPath: WritableKeyPath<CALayer, T>) {
        let keyframeAnimation = decayAnimation.keyframeAnimation(forFramerate: nil)
        keyframeAnimation.keyPath = keyPath.stringValue
        add(keyframeAnimation, forKey: key)
    }

    /**
     Adds an easing animation to the layer.

     This method generates a pre-configured `CAKeyframeAnimation` from the supplied spring animator and adds it to the supplied layer, animating the given key path.

     - Parameters:
        - easingAnimation: The easing animation.
        - key: The key to be associated with the generated `CAKeyframeAnimation` when added to the layer. The default value is `nil` which uses the keypath as key.
        - keyPath: The key path to animate.
     */
    func add<T: AnimatableProperty & CAKeyframeAnimationValueConvertible>(_ easingAnimation: EasingAnimation<T>, forKey key: String? = nil, keyPath: WritableKeyPath<CALayer, T>) {
        let keyframeAnimation = easingAnimation.keyframeAnimation(forFramerate: nil)
        keyframeAnimation.keyPath = keyPath.stringValue
        add(keyframeAnimation, forKey: key ?? keyPath.stringValue)
    }

    /**
     Adds a spring animation to the layer.

     This method generates a pre-configured `CAKeyframeAnimation` from the supplied spring animator and adds it to the supplied layer, animating the given key path.

     - Parameters:
        - springAnimation: The spring animation.
        - key: The key to be associated with the generated `CAKeyframeAnimation` when added to the layer. The default value is `nil` which uses the keypath as key.
        - keyPath: The key path to animate.
     */
    func add<T: AnimatableProperty & CAKeyframeAnimationValueConvertible>(_ springAnimation: SpringAnimation<T>, forKey key: String? = nil, keyPath: WritableKeyPath<CALayer, T>) {
        let keyframeAnimation = springAnimation.keyframeAnimation(forFramerate: nil)
        keyframeAnimation.keyPath = keyPath.stringValue
        add(keyframeAnimation, forKey: key ?? keyPath.stringValue)
    }
}
