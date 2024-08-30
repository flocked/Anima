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
     Adds an animation to the layer.

     This method generates a pre-configured `CAKeyframeAnimation` from the supplied animation and adds it to the layer, animating the given key path.

     - Parameters:
        - animation: The animation to add.
        - keyPath: The key path to animate. The key path is relative to the layer.
     */
    func add(_ animation: CAKeyframeAnimationEmittable, for keyPath: String) {
        #if os(macOS)
        let keyframeAnimation = animation.keyframeAnimation(forFramerate: parentView?.window?.screen?.preferredFramesPerSecond)
        #else
        let keyframeAnimation = animation.keyframeAnimation(forFramerate: parentView?.window?.screen.preferredFramesPerSecond)
        #endif
        keyframeAnimation.keyPath = keyPath
        add(keyframeAnimation, forKey: keyPath)
    }

    /**
     Adds an animation to the layer.

     This method generates a pre-configured `CAKeyframeAnimation` from the supplied animation and adds it to the layer, animating the given key path.

     - Parameters:
        - animation: The animation to add.
        - keyPath: The key path to animate.
     */
    func add<T: AnimatableProperty & CAKeyframeAnimationValueConvertible>(_ animation: DecayAnimation<T>, for keyPath: WritableKeyPath<CALayer, T>) {
        add(animation, for: keyPath.stringValue)
    }

    /**
     Adds an animation to the layer.

     This method generates a pre-configured `CAKeyframeAnimation` from the supplied animation and adds it to the layer, animating the given key path.

     - Parameters:
        - animation: The animation to add.
        - keyPath: The key path to animate.
     */
    func add<T: AnimatableProperty & CAKeyframeAnimationValueConvertible>(_ animation: EasingAnimation<T>, for keyPath: WritableKeyPath<CALayer, T>) {
        add(animation, for: keyPath.stringValue)
    }
    
    /**
     Adds an animation to the layer.

     This method generates a pre-configured `CAKeyframeAnimation` from the supplied animation and adds it to the layer, animating the given key path.

     - Parameters:
        - animation: The animation to add.
        - keyPath: The key path to animate.
     */
    func add<T: AnimatableProperty & CAKeyframeAnimationValueConvertible>(_ animation: SpringAnimation<T>, forKey key: String? = nil, keyPath: WritableKeyPath<CALayer, T>) {
        add(animation, for: keyPath.stringValue)
    }
}
