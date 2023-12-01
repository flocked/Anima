//
//  Animation.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

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
public class SpringAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding {
    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupUUID: UUID?
    
    /// The relative priority of the animation.
    public var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive
    
    /// The delay (in seconds) after which the animations begin.
    public internal(set) var delay: TimeInterval = 0.0

    /// The spring model that determines the animation's motion.
    public var spring: Spring
    
    /// The estimated duration required for the animation to complete, based off its `spring` property.
    public var settlingTime: TimeInterval {
        spring.settlingDuration
    }
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` should be integralized to the screen's pixel boundaries when the animation finishes. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// A Boolean value that indicates whether the animation automatically starts when the ``target`` value changes.
    public var autoStarts: Bool = false
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false
    
    /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
    public var autoreverse: Bool = false
        
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false

    /// The _current_ value of the animation. This value will change as the animation executes.
    public var value: Value {
        get { Value(_value) }
        set { _value = newValue.animatableData }
    }
    
    var _value: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _fromValue = _value
        }
    }

    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: Value {
        get { Value(_target) }
        set { _target = newValue.animatableData }
    }
    
    var _target: Value.AnimatableData {
        didSet {
            guard oldValue != _target else { return }
            if state == .running {
                runningTime = 0.0
                completion?(.retargeted(from: Value(oldValue), to: target))
            } else if autoStarts, _target != _value {
                start(afterDelay: 0.0)
            }
        }
    }

    /**
     The current velocity of the animation.

     If animating a view's `center` or `frame` with a gesture, you may want to set `velocity` to the gesture's final velocity on touch-up.
     */
    public var velocity: Value {
        get { Value(_velocity) }
        set { _velocity = newValue.animatableData }
    }
    
    var _velocity: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _fromVelocity = _velocity
        }
    }

    var fromValue: Value {
        get { Value(_fromValue) }
        set { _fromValue = newValue.animatableData }
    }
    
    var _fromValue: Value.AnimatableData
    
    var fromVelocity: Value {
        get { Value(_fromVelocity) }
        set { _fromVelocity = newValue.animatableData }
    }
    
    var _fromVelocity: Value.AnimatableData
    
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /// The total running time of the animation.
    var runningTime: TimeInterval = 0.0

    /**
     Creates a new animation with a given ``Spring``, value, target and optional inital velocity.

     - Parameters:
        - spring: The spring that determines the animation's motion.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
        - initialVelocity: An optional inital velocity of the animtion.
     */
    public init(spring: Spring, value: Value, target: Value, initialVelocity: Value = .zero) {
        self._value = value.animatableData
        self._target = target.animatableData
        self._velocity = initialVelocity.animatableData
        self.spring = spring
        self._fromValue = _value
        self._fromVelocity = _velocity
    }
    
    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil

    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        spring = settings.animationType.spring ?? spring
        repeats = settings.repeats
        autoStarts = settings.autoStarts
        autoreverse = settings.autoreverse
        integralizeValues = settings.integralizeValues
        
        if let gestureVelocity = settings.animationType.gestureVelocity {
            (self as? SpringAnimation<CGRect>)?.velocity.origin = gestureVelocity
            (self as? SpringAnimation<CGRect>)?.fromVelocity.origin = gestureVelocity
            
            (self as? SpringAnimation<CGPoint>)?.velocity = gestureVelocity
            (self as? SpringAnimation<CGPoint>)?.fromVelocity = gestureVelocity
        }
    }
        
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        state = .running

        let isAnimated = spring.response > .zero

        if isAnimated {
            spring.update(value: &_value, velocity: &_velocity, target: isReversed ? _fromValue : _target, deltaTime: deltaTime)
        } else {
            self._value = _target
            velocity = Value.zero
        }
                
        runningTime = runningTime + deltaTime

        let animationFinished = (runningTime >= settlingTime) || !isAnimated
        
        if animationFinished {
            if repeats, isAnimated {
                if autoreverse {
                    isReversed = !isReversed
                }
                _value = isReversed ? _target : _fromValue
                _velocity = isReversed ? .zero : _fromVelocity
            } else {
                _value = _target
            }
            runningTime = 0.0
        }

        let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished, !repeats || !isAnimated {
            stop(at: .current)
        }
    }
    
    func reset() {
        runningTime = 0.0
        delayedStart?.cancel()
    }
}

extension SpringAnimation: CustomStringConvertible {
    public var description: String {
        """
        SpringAnimation<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(groupUUID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state)

            value: \(value)
            target: \(target)
            velocity: \(velocity)

            mode: \(spring.response > 0 ? "animated" : "nonAnimated")
            settlingTime: \(settlingTime)
            isReversed: \(isReversed)
            repeats: \(repeats)
            autoreverse: \(autoreverse)
            integralizeValues: \(integralizeValues)
            autoStarts: \(autoStarts)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))
        )
        """
    }
}
