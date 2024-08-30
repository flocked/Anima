//
//  SpringAnimation.swift
//  
//
//  Created by Florian Zand on 29.03.24.
//

import Foundation
import SwiftUI

/**
 An animation that animates a value using a physically-modeled spring.

 Example usage:
 ```swift
 let springAnimation = SpringAnimation(spring: .bouncy, value: CGPoint(x: 0, y: 0), target: CGPoint(x: 50, y: 100))
 springAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
 }
 springAnimation.start()
 ```
 */
open class SpringAnimation<Value: AnimatableProperty>: PropertyAnimation<Value> {
    
    /// The spring model that determines the animation's motion.
    open var spring: Spring

    /// The estimated duration required for the animation to complete, based off its `spring` property.
    open var settlingTime: TimeInterval {
        spring.settlingDuration
    }
    
    /**
     Creates a new animation with a given ``Spring``, value, target and optional inital velocity.

     - Parameters:
        - spring: The spring that determines the animation's motion.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
        - initialVelocity: An optional inital velocity of the animtion.
     */
    public init(spring: Spring, value: Value, target: Value, initialVelocity: Value = .zero) {
        self.spring = spring
        super.init(value: value, target: target)
        _velocity = initialVelocity.animatableData
        _startVelocity = _velocity
    }
    
    override var animationType: AnimationType { .spring }
    
    override func configure(with configuration: Anima.AnimationConfiguration) {
        super.configure(with: configuration)
        spring = configuration.animation?.spring ?? spring

        if configuration.options.resetSpringVelocity {
            _velocity = .zero
        }
        
        if let gestureVelocity = configuration.animation?.gestureVelocity {
            if let gestureVelocity = gestureVelocity as? CGPoint, let animation = self as? SpringAnimation<CGRect> {
                animation.velocity.origin = gestureVelocity
            } else if let gestureVelocity = gestureVelocity as? Value {
                velocity = gestureVelocity
            }
        }
    }

    open override func updateAnimation(deltaTime: TimeInterval) {
        state = .running

        let isAnimated = spring.response > .zero

        if isAnimated {
            spring.update(value: &_value, velocity: &_velocity, target: isReversed ? _startValue : _target, deltaTime: deltaTime)
        } else {
            _value = _target
            velocity = Value.zero
        }

        runningTime = runningTime + deltaTime

        var animationFinished = (runningTime >= settlingTime) || !isAnimated
        
        if options.usesApproximatelyEqual, let value = _value as? (any ApproximateEquatable), let target = _target as? (any ApproximateEquatable), value.isApproximatelyEqual(toAny: target, epsilon: 0.01) {
            animationFinished = true
        }
        
        if animationFinished {
            if options.repeats, isAnimated {
                if options.autoreverse {
                    isReversed = !isReversed
                }
                _value = isReversed ? _target : _startValue
                velocity = isReversed ? .zero : startVelocity
            } else {
                _value = _target
            }
            runningTime = 0.0
        }

        let callbackValue = options.integralizeValues ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished, !options.repeats || !isAnimated {
            stop(at: .current)
        }
    }
    
    public override var description: String {
        """
        SpringAnimation<\(Value.self)>(
            uuid: \(id)
            groupID: \(groupID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state.rawValue)

            value: \(value)
            target: \(target)
            velocity: \(velocity)

            mode: \(spring.response > 0 ? "animated" : "nonAnimated")
            settlingTime: \(settlingTime)

            isReversed: \(isReversed)
            repeats: \(options.repeats)
            autoreverse: \(options.autoreverse)
            integralizeValues: \(options.integralizeValues)
            autoStarts: \(options.autoStarts)

            valueChanged: \(valueChanged != nil)
            completion: \(completion != nil)
        )
        """
    }
}
