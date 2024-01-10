//
//  CAKeyframeAnimationEmittable.swift
//
//  Copyright (c) 2020, Adam Bell
//  Modifed:
//  Florian Zand on 02.11.23.
//

import Foundation
import QuartzCore
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

// MARK: - CAKeyframeAnimationEmittable

/**
 A type that defines the ability to generate a `CAKeyframeAnimation` from an animation.
 
 Example usage:
 ```
 let animation = SpringAnimation(spring: .bouncy, value: 0.0, target: 100.0)

 let keyframeAnimation = animation.keyframeAnimation()
 keyFrameAnimation.keyPath = "position.y"
 layer.add(keyFrameAnimation, forKey: "animation")
 ```
 */
public protocol CAKeyframeAnimationEmittable {
    /**
     Generates a `CAKeyframeAnimation` based on the animation's current value and target.

     - Parameters:
        - framerate: The framerate the `CAKeyframeAnimation` should be targeting. If nil, the device's default framerate will be used.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from the current animation's state to its resolved state.
     - Note: You will be required to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to be useful.
     */
    func keyframeAnimation(forFramerate framerate: Int?) -> CAKeyframeAnimation

    /**
     Generates and returns the values and keyTimes for a `CAKeyframeAnimation`. This is called by default from `keyframeAnimation(forFramerate:)`.

     - Parameters:
        - deltaTime: The target delta time. Typically you'd want 1.0 / targetFramerate`
        - values: A preinitialized array that should be populated with the values to align with the given keyTimes.
        - keyTimes: A preinitialized array that should be populated with the keyTimes to align with the given values.

     - Returns: The total duration of the `CAKeyframeAnimation`.

     - Note: Returning values and keyTimes with different lengths will result in undefined behaviour.
     */
    func populateKeyframeAnimationData(deltaTime: TimeInterval, values: inout [AnyObject], keyTimes: inout [NSNumber]) -> TimeInterval

}

extension CAKeyframeAnimationEmittable {
    /**
     Generates a `CAKeyframeAnimation` based on the animation's current value and target.
     
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from the current animation's state to its resolved state.
     - Note: You will be required to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to be useful.
     */
    public func keyframeAnimation() -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: nil)
    }

    public func keyframeAnimation(forFramerate framerate: Int?) -> CAKeyframeAnimation {
        let deltaTime: TimeInterval
        if let framerate = framerate {
            deltaTime = 1.0 / TimeInterval(framerate)
        } else {
            deltaTime = 1.0 / TimeInterval(NSUIScreen.current?.preferredFramesPerSecond ?? 60)
        }

        var values = [AnyObject]()
        var keyTimes = [NSNumber]()

        let duration = populateKeyframeAnimationData(deltaTime: deltaTime, values: &values, keyTimes: &keyTimes)

        let keyframeAnimation = CAKeyframeAnimation()
        keyframeAnimation.calculationMode = .discrete
        keyframeAnimation.values = values
        keyframeAnimation.keyTimes = keyTimes
        keyframeAnimation.duration = duration
        return keyframeAnimation
    }

    #if os(macOS)
    /**
     Generates a `CAKeyframeAnimation` based on the animation's current value and target.

     - Parameters:
        - screen: The screen where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from the current animation's state to its resolved state.
     - Note: You will be required to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to be useful.
     */
    public func keyframeAnimation(forScreen screen: NSScreen) -> CAKeyframeAnimation {
        return keyframeAnimation(forFramerate: screen.preferredFramesPerSecond)
    }
    #else
    /**
     Generates a `CAKeyframeAnimation` based on the animation's current value and target.

     - Parameters:
        - screen: The screen where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from the current animation's state to its resolved state.
     - Note: You will be required to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to be useful.
     */
    public func keyframeAnimation(forScreen screen: UIScreen) -> CAKeyframeAnimation {
        return keyframeAnimation(forFramerate: screen.preferredFramesPerSecond)
    }
    #endif
}

extension DecayAnimation: CAKeyframeAnimationEmittable where Value: CAKeyframeAnimationValueConvertible {
    /// Generates and populates the `values` and `keyTimes` for a given `DecayAnimation` animating from its ``value`` to its ``target`` by ticking it by `deltaTime` until it resolves.
    public func populateKeyframeAnimationData(deltaTime: TimeInterval, values: inout [AnyObject], keyTimes: inout [NSNumber]) -> TimeInterval {
        var value = _value
        var velocity = _velocity
        var runningTime: TimeInterval = 0.0
        while velocity.magnitudeSquared >= 0.05 {
            decayFunction.update(value: &value, velocity: &velocity, deltaTime: deltaTime)
            values.append(Value(value).toKeyframeValue())
            keyTimes.append(runningTime as NSNumber)
            runningTime += deltaTime
        }
        return runningTime
    }
}

extension EasingAnimation: CAKeyframeAnimationEmittable where Value: CAKeyframeAnimationValueConvertible {
    /// Generates and populates the `values` and `keyTimes` for a given `EasingAnimation` animating from its ``value`` to its ``target`` by ticking it by `deltaTime` until it resolves.
    public func populateKeyframeAnimationData(deltaTime: TimeInterval, values: inout [AnyObject], keyTimes: inout [NSNumber]) -> TimeInterval {
        var fractionComplete: CGFloat = isReversed ? 1.0 : 0.0
        let secondsElapsed = deltaTime/duration
        var value = isReversed ? target : startValue
        var runningTime: TimeInterval = 0.0
        while runningTime < duration {
            fractionComplete = isReversed ? (fractionComplete - secondsElapsed) : (fractionComplete + secondsElapsed)
            let resolvedFractionComplete = timingFunction.solve(at: fractionComplete, duration: duration)
            value = Value(startValue.animatableData.interpolated(towards: target.animatableData, amount: resolvedFractionComplete))
            values.append(value.toKeyframeValue())
            keyTimes.append(runningTime as NSNumber)
            runningTime += deltaTime
        }

        values.append(isReversed ? startValue.toKeyframeValue() : target.toKeyframeValue())
        keyTimes.append(duration as NSNumber)
        return runningTime
    }
}

extension SpringAnimation: CAKeyframeAnimationEmittable where Value: CAKeyframeAnimationValueConvertible {
    /// Generates and populates the `values` and `keyTimes` for a given `SpringAnimation` animating from its ``value`` to its ``target`` by ticking it by `deltaTime` until it resolves.
    public func populateKeyframeAnimationData(deltaTime: TimeInterval, values: inout [AnyObject], keyTimes: inout [NSNumber]) -> TimeInterval {
        var velocity = velocity

        var t = 0.0
        var hasResolved = false
        while !hasResolved {
            spring.update(value: &value, velocity: &velocity, target: target, deltaTime: deltaTime)

            values.append(value.toKeyframeValue())
            keyTimes.append(t as NSNumber)

            t += deltaTime

            let isAnimated = spring.response > .zero
            hasResolved = (t >= settlingTime) || !isAnimated
        }

        values.append(target.toKeyframeValue())
        keyTimes.append(t as NSNumber)

        return t
    }
}

#if os(macOS)
fileprivate extension NSScreen {
    var preferredFramesPerSecond: Int {
        guard #available(macOS 12.0, *) else { return 60 }
        let fps = maximumFramesPerSecond
        guard fps > 0 else { return 60 }
        return fps
    }

    static var current: NSScreen? {
        NSScreen.main
    }
}
#elseif canImport(UIKit)
fileprivate extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }

    var preferredFramesPerSecond: Int {
        let fps = maximumFramesPerSecond
        guard fps > 0 else { return 60 }
        return fps
    }
}

fileprivate extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}
#endif
