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
 An animation that can generate a `CAKeyframeAnimation`.
 
 Example usage:
 ```
 let animation = SpringAnimation(spring: .bouncy, value: 0.0, target: 100.0)
 
 let keyframeAnimation = animation.keyframeAnimation()
 keyFrameAnimation.keyPath = "position.y"
 layer.add(keyFrameAnimation, forKey: "position")
 ```
 */
public protocol CAKeyframeAnimationEmittable {
    /**
     Generates a `CAKeyframeAnimation` from the animation.
     
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from it's current value to it's target value.
     - Note: You need to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to work.
     */
    func keyframeAnimation() -> CAKeyframeAnimation
    
    /**
     Generates a `CAKeyframeAnimation` from the animation.
     
     - Parameter framerate: The framerate the `CAKeyframeAnimation` should be targeting. If nil, the device's default framerate will be used.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from it's current value to it's target value.
     - Note: You need to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to work.
     */
    func keyframeAnimation(forFramerate framerate: Int) -> CAKeyframeAnimation
}

protocol _CAKeyframeAnimationEmittable {
    func keyframeAnimationData(for deltaTime: TimeInterval) -> (duration: TimeInterval, values: [AnyObject], keyTimes: [NSNumber])
}

public extension CAKeyframeAnimationEmittable {
    func keyframeAnimation() -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: NSUIScreen.main?.preferredFramesPerSecond ?? 60)
    }
    
    func keyframeAnimation(forFramerate framerate: Int) -> CAKeyframeAnimation {
        let deltaTime = 1.0 / TimeInterval(framerate)
        let keyframeAnimationData = (self as! _CAKeyframeAnimationEmittable).keyframeAnimationData(for: deltaTime)
        let keyframeAnimation = CAKeyframeAnimation()
        keyframeAnimation.calculationMode = .discrete
        keyframeAnimation.values = keyframeAnimationData.values
        keyframeAnimation.keyTimes = keyframeAnimationData.keyTimes
        keyframeAnimation.duration = keyframeAnimationData.duration
        return keyframeAnimation
    }
    
    internal func keyframeAnimation(forFramerate framerate: Int?) -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: framerate ?? NSUIScreen.main?.preferredFramesPerSecond ?? 60)
    }
    
#if os(macOS)
    /**
     Generates a `CAKeyframeAnimation` from the animation.
     
     - Parameter screen: The screen where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from it's current value to it's target value.
     - Note: You need to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to work.
     */
    func keyframeAnimation(for screen: NSScreen) -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: screen.preferredFramesPerSecond)
    }
    
    /**
     Generates a `CAKeyframeAnimation` from the animation.
     
     - Parameter window: The window where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from it's current value to it's target value.
     - Note: You need to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to work.
     */
    func keyframeAnimation(for window: NSWindow) -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: window.screen?.preferredFramesPerSecond)
    }
    
    /**
     Generates a `CAKeyframeAnimation` from the animation.
     
     - Parameter view: The view where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from it's current value to it's target value.
     - Note: You need to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to work.
     */
    func keyframeAnimation(for view: NSView) -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: view.window?.screen?.preferredFramesPerSecond)
    }
#else
    /**
     Generates a `CAKeyframeAnimation` from the animation.
     
     - Parameter screen: The screen where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from it's current value to it's target value.
     - Note: You need to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to work.
     */
    func keyframeAnimation(for screen: UIScreen) -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: screen.preferredFramesPerSecond)
    }
    
    /**
     Generates a `CAKeyframeAnimation` from the animation.
     
     - Parameter window: The window where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from it's current value to it's target value.
     - Note: You need to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to work.
     */
    func keyframeAnimation(for window: UIWindow) -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: window.screen.preferredFramesPerSecond)
    }
    
    /**
     Generates a `CAKeyframeAnimation` from the animation.
     
     - Parameter view: The view where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from it's current value to it's target value.
     - Note: You need to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to work.
     */
    func keyframeAnimation(for view: UIView) -> CAKeyframeAnimation {
        keyframeAnimation(forFramerate: view.window?.screen.preferredFramesPerSecond)
    }
#endif
}

extension DecayAnimation: CAKeyframeAnimationEmittable, _CAKeyframeAnimationEmittable where Value: CAKeyframeAnimationValueConvertible {
    func keyframeAnimationData(for deltaTime: TimeInterval) -> (duration: TimeInterval, values: [AnyObject], keyTimes: [NSNumber]) {
        var values: [AnyObject] = []
        var keyTimes: [NSNumber] = []
        var value = _value
        var velocity = _velocity
        var runningTime: TimeInterval = 0.0
        while velocity.magnitudeSquared >= 0.05 {
            decayFunction.update(value: &value, velocity: &velocity, deltaTime: deltaTime)
            values.append(Value(value).toKeyframeValue())
            keyTimes.append(runningTime as NSNumber)
            runningTime += deltaTime
        }
        return (runningTime, values, keyTimes)
    }
}

extension EasingAnimation: CAKeyframeAnimationEmittable, _CAKeyframeAnimationEmittable where Value: CAKeyframeAnimationValueConvertible {
    func keyframeAnimationData(for deltaTime: TimeInterval) -> (duration: TimeInterval, values: [AnyObject], keyTimes: [NSNumber]) {
        var values: [AnyObject] = []
        var keyTimes: [NSNumber] = []
        var fractionComplete: CGFloat = isReversed ? 1.0 : 0.0
        let secondsElapsed = deltaTime / duration
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
        return (runningTime, values, keyTimes)
    }
}

extension SpringAnimation: CAKeyframeAnimationEmittable, _CAKeyframeAnimationEmittable where Value: CAKeyframeAnimationValueConvertible {
    func keyframeAnimationData(for deltaTime: TimeInterval) -> (duration: TimeInterval, values: [AnyObject], keyTimes: [NSNumber]) {
        var values: [AnyObject] = []
        var keyTimes: [NSNumber] = []
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
        return (t, values, keyTimes)
    }
}

#if os(macOS)
extension NSScreen {
    var preferredFramesPerSecond: Int {
        guard #available(macOS 12.0, *) else { return 60 }
        return maximumFramesPerSecond > 0 ? maximumFramesPerSecond : 60
    }
}
#elseif canImport(UIKit)
extension UIScreen {
    static var main: UIScreen? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return window.screen
            }
        }
        return nil
    }
    
    var preferredFramesPerSecond: Int {
        maximumFramesPerSecond > 0 ? maximumFramesPerSecond : 60
    }
}
#endif
