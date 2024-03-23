//
//  EasingAnimation.swift
//
//
//  Created by Florian Zand on 03.11.23.
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
open class EasingAnimation<Value: AnimatableProperty>: AnimationProviding, ConfigurableAnimationProviding {
    /// A unique identifier for the animation.
    public let id = UUID()

    /// A unique identifier that associates the animation with an grouped animation block.
    open internal(set) var groupID: UUID?

    /// The relative priority of the animation. The higher the number the higher the priority.
    open var relativePriority: Int = 0

    /// The current state of the animation.
    open internal(set) var state: AnimatingState = .inactive

    /// The delay (in seconds) after which the animations begin.
    open internal(set) var delay: TimeInterval = 0.0

    /// The timing function of the animation.
    open var timingFunction: TimingFunction = .easeInEaseOut

    /// The total duration (in seconds) of the animation.
    open var duration: CGFloat = 0.0

    /// A Boolean value indicating whether the animation repeats indefinitely.
    open var repeats: Bool = false

    /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
    public var autoreverse: Bool = false

    /// A Boolean value indicating whether the animation is running in the reverse direction.
    open var isReversed: Bool = false

    /// A Boolean value that indicates whether the value returned in ``valueChanged`` should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    open var integralizeValues: Bool = false

    /// A Boolean value that indicates whether the animation automatically starts when the ``target`` value changes.
    open var autoStarts: Bool = false

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

    /// The _current_ value of the animation. This value will change as the animation executes.
    public var value: Value {
        get { Value(_value) }
        set { _value = newValue.animatableData }
    }

    var _value: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _startValue = _value
        }
    }

    /**
     Thex target value of the animation.

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
                fractionComplete = 0.0
                completion?(.retargeted(from: Value(oldValue), to: target))
            } else if autoStarts, _target != _value {
                start(afterDelay: 0.0)
            }
        }
    }

    /// The start value of the animation.
    var startValue: Value {
        get { Value(_startValue) }
        set { _startValue = newValue.animatableData }
    }

    var _startValue: Value.AnimatableData

    /// The current velocity of the animation.
    public internal(set) var velocity: Value {
        get { Value(_velocity) }
        set { _velocity = newValue.animatableData }
    }

    var _velocity: Value.AnimatableData = .zero

    var startVelocity: Value {
        get { .zero }
        set {}
    }

    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    open var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    open var completion: ((_ event: AnimationEvent<Value>) -> Void)?

    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.

     - Parameters:
        - timingFunction: The timing curve of the animation.
        - duration: The duration of the animation.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(timingFunction: TimingFunction, duration: CGFloat, value: Value, target: Value) {
        _value = value.animatableData
        _startValue = _value
        _target = target.animatableData
        self.duration = duration
        self.timingFunction = timingFunction
    }

    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }

    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem?

    /// The animation type.
    let animationType: AnimationParameters.AnimationType = .easing

    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationParameters) {
        groupID = settings.groupID
        repeats = settings.options.repeats
        autoreverse = settings.options.autoreverse
        integralizeValues = settings.options.integralizeValues

        timingFunction = settings.easing?.timingFunction ?? timingFunction
        duration = settings.easing?.duration ?? duration
    }

    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    open func updateAnimation(deltaTime: TimeInterval) {
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

    /**
     Starts the animation from its current position with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    open func start(afterDelay delay: TimeInterval = 0.0) {
        precondition(delay >= 0, "Animation start delay must be greater or equal to zero.")
        guard state != .running else { return }

        let start = {
            self.state = .running
            AnimationController.shared.runAnimation(self)
        }

        delayedStart?.cancel()
        self.delay = delay

        if delay == .zero {
            start()
        } else {
            let task = DispatchWorkItem {
                start()
            }
            delayedStart = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }

    /// Pauses the animation at the current position.
    open func pause() {
        guard state == .running else { return }
        AnimationController.shared.stopAnimation(self)
        state = .inactive
        delayedStart?.cancel()
        delay = 0.0
    }

    /**
     Stops the animation at the specified position.

     - Parameters:
        - position: The position at which position the animation should stop (``AnimationPosition/current``, ``AnimationPosition/start`` or ``AnimationPosition/end``). The default value is `current`.
        - immediately: A Boolean value that indicates whether the animation should stop immediately at the specified position. The default value is `true`.
     */
    open func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        delayedStart?.cancel()
        delay = 0.0
        if immediately == false {
            switch position {
            case .start:
                _target = _startValue
            case .current:
                _target = _value
            default: break
            }
        } else {
            AnimationController.shared.stopAnimation(self)
            state = .inactive
            switch position {
            case .start:
                _value = _startValue
                valueChanged?(value)
            case .end:
                _value = _target
                valueChanged?(value)
            default: break
            }
            reset()
            completion?(.finished(at: value))
        }
    }

    /// Resets the animation.
    func reset() {
        delayedStart?.cancel()
        fractionComplete = 0.0
        velocity = .zero
    }
}

extension EasingAnimation: CustomStringConvertible {
    public var description: String {
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

/*
 /**
  A Boolean value indicating whether a paused animation scrubs linearly or uses its specified timing information.

  The default value of this property is `true`, which causes the animator to use a linear timing function during scrubbing. Setting the property to `false` causes the animator to use its specified timing curve.
  */
 var scrubsLinearly: Bool = false
 */

/*
 func updateValue() {
     guard state != .running else { return }
     if scrubsLinearly {
         _value = _startValue.interpolated(towards: _target, amount: fractionComplete)
     } else {
         _value = _startValue.interpolated(towards: _target, amount: resolvedFractionComplete)
     }
     valueChanged?(value)
 }
 */
