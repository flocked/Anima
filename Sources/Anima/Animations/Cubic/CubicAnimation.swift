//
//  CubicAnimation.swift
//
//
//  Created by Florian Zand on 29.03.24.
//

import Foundation

// Not working. Will be used for keyframe animations.
class CubicAnimation<Value: AnimatableProperty>: PropertyAnimation<Value> {

    /// The total duration (in seconds) of the animation.
    open var duration: CGFloat = 0.0
    
    /// The completion percentage of the animation.
    open var fractionComplete: CGFloat = 0.0 {
        didSet {
            fractionComplete = fractionComplete.clamped(max: 1.0)
        }
    }
    
    override var _target: Value.AnimatableData {
        didSet {
            guard oldValue != _target else { return }
            if state == .running {
                fractionComplete = 0.0
                completion?(.retargeted(from: Value(oldValue), to: target))
            } else if options.autoStarts, _target != _value {
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
    public init(duration: CGFloat, value: Value, target: Value) {
        super.init(value: value, target: target)
        self.duration = duration
    }
    
    override var animationType: AnimationType { .cubic }
    
    override func configure(with configuration: Anima.AnimationConfiguration) {
        super.configure(with: configuration)
        duration = configuration.animation?.duration ?? duration
    }
    
    open override func updateAnimation(deltaTime: TimeInterval) {
        state = .running

        let isAnimated = duration > .zero

        guard deltaTime > 0.0 else { return }

        let previousValue = _value

        if isAnimated {
            let secondsElapsed = deltaTime / duration
            fractionComplete = isReversed ? (fractionComplete - secondsElapsed) : (fractionComplete + secondsElapsed)
            // (p0 - p1) * 2
            let start = (_startValue - _target) * 0.5
            let last = (_target - _startValue) * 0.5
            _value = Spline.catmullRom(p0: start, p1: _startValue, p2: _target, p3: last, t: fractionComplete)
        } else {
            fractionComplete = isReversed ? 0.0 : 1.0
            _value = isReversed ? _startValue : _target
            Swift.print(value)
        }

        _velocity = (_value - previousValue).scaled(by: 1.0 / deltaTime)

        let animationFinished = (isReversed ? fractionComplete <= 0.0 : fractionComplete >= 1.0) || !isAnimated

        if animationFinished {
            if options.repeats, isAnimated {
                if options.autoreverse {
                    isReversed = !isReversed
                }
                fractionComplete = isReversed ? 1.0 : 0.0
                _value = isReversed ? _target : _value
            } else {
                _value = isReversed ? _startValue : _target
            }
        }

        let callbackValue = options.integralizeValues ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if (animationFinished && !options.repeats) || !isAnimated {
            stop(at: .current)
        }
    }
    
    override func reset() {
        runningTime = 0.0
        fractionComplete = 0.0
    }
    
    public override var description: String {
                """
                CubicAnimation<\(Value.self)>(
                    uuid: \(id)
                    groupID: \(groupID?.description ?? "nil")
                    priority: \(relativePriority)
                    state: \(state.rawValue)

                    value: \(value)
                    target: \(target)
                    startValue: \(startValue)
                    velocity: \(velocity)
                    fractionComplete: \(fractionComplete)

                    duration: \(duration)
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
