//
//  EasingAnimation.swift
//  
//
//  Created by Florian Zand on 29.03.24.
//

import Foundation

/**
 An animation that animates a value using an easing function (like `easeIn` or `linear`).

 Example usage:
 ```swift
 let easingAnimation = EasingAnimation(timingFunction = .easeIn, duration: 3.0, value: CGPoint(x: 0, y: 0), target: CGPoint(x: 50, y: 100))
 easingAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
 }
 easingAnimation.start()
 ```
 */
open class EasingAnimation<Value: AnimatableProperty>: PropertyAnimation<Value> {
    /// The timing function of the animation.
    open var timingFunction: TimingFunction = .easeInEaseOut

    /// The total duration (in seconds) of the animation.
    open var duration: CGFloat = 0.0
    
    /// The completion percentage of the animation.
    open var fractionComplete: CGFloat = 0.0 {
        didSet {
            fractionComplete = fractionComplete.clamped(max: 1.0)
        }
    }

    /// The resolved fraction complete using the timing function.
    var resolvedFractionComplete: CGFloat {
        timingFunction.solve(at: fractionComplete, duration: duration)
    }
    
    override var _target: Value.AnimatableData {
        didSet {
            guard oldValue != _target else { return }
            if state == .running {
                fractionComplete = 0.0
                completion?(.retargeted(from: Value(oldValue), to: target))
            } else if autoStarts, _target != _value {
                start(afterDelay: 0.0)
            }
        }
    }
    
    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.

     - Parameters:
        - timingFunction: The timing curve of the animation.
        - duration: The duration of the animation.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(timingFunction: TimingFunction, duration: CGFloat, value: Value, target: Value) {
        super.init(value: value, target: target)
        self.duration = duration
        self.timingFunction = timingFunction
    }
    
    override var animationType: AnimationType { .easing }
    
    override func configure(with configuration: Anima.AnimationConfiguration) {
        super.configure(with: configuration)
        timingFunction = configuration.easing?.timingFunction ?? timingFunction
        duration = configuration.easing?.duration ?? duration
    }
    
    open override func updateAnimation(deltaTime: TimeInterval) {
        state = .running

        let isAnimated = duration > .zero

        guard deltaTime > 0.0 else { return }

        let previousValue = _value

        if isAnimated {
            let secondsElapsed = deltaTime / duration
            fractionComplete = isReversed ? (fractionComplete - secondsElapsed) : (fractionComplete + secondsElapsed)
            _value = _startValue.interpolated(towards: _target, amount: resolvedFractionComplete)
        } else {
            fractionComplete = isReversed ? 0.0 : 1.0
            _value = isReversed ? _startValue : _target
        }

        _velocity = (_value - previousValue).scaled(by: 1.0 / deltaTime)

        let animationFinished = (isReversed ? fractionComplete <= 0.0 : fractionComplete >= 1.0) || !isAnimated

        if animationFinished {
            if repeats, isAnimated {
                if autoreverse {
                    isReversed = !isReversed
                }
                fractionComplete = isReversed ? 1.0 : 0.0
                _value = isReversed ? _target : _value
            } else {
                _value = isReversed ? _startValue : _target
            }
        }

        let callbackValue = integralizeValues ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if (animationFinished && !repeats) || !isAnimated {
            stop(at: .current)
        }
    }
    
    override func reset() {
        super.reset()
        fractionComplete = 0.0
    }
    
    public override var description: String {
                """
                EasingAnimation<\(Value.self)>(
                    uuid: \(id)
                    groupID: \(groupID?.description ?? "nil")
                    priority: \(relativePriority)
                    state: \(state.rawValue)

                    value: \(value)
                    target: \(target)
                    startValue: \(startValue)
                    velocity: \(velocity)
                    fractionComplete: \(fractionComplete)

                    timingFunction: \(timingFunction.name)
                    duration: \(duration)
                    isReversed: \(isReversed)
                    repeats: \(repeats)
                    autoreverse: \(autoreverse)
                    integralizeValues: \(integralizeValues)
                    autoStarts: \(autoStarts)

                    valueChanged: \(valueChanged != nil)
                    completion: \(completion != nil)
                )
                """
    }

}
