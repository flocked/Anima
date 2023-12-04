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
public class EasingAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding {
    /// A unique identifier for the animation.
    public let id = UUID()

    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupID: UUID?

    /// The relative priority of the animation.
    public var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive
    
    /// The delay (in seconds) after which the animations begin.
    public internal(set) var delay: TimeInterval = 0.0
    
    /// The information used to determine the timing curve for the animation.
    public var timingFunction: TimingFunction = .easeInEaseOut
    
    /// The total duration (in seconds) of the animation.
    public var duration: CGFloat = 0.0
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false
    
    /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
    public var autoreverse: Bool = false
        
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false
        
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` should be integralized to the screen's pixel boundaries when the animation finishes. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// A Boolean value that indicates whether the animation automatically starts when the ``target`` value changes.
    public var autoStarts: Bool = false
    
    /// The completion percentage of the animation.
    public var fractionComplete: CGFloat = 0.0 {
        didSet {
            fractionComplete = fractionComplete.clamped(max: 1.0)
        }
    }
    
    /// The resolved fraction complete using the timing function.
    var resolvedFractionComplete: CGFloat {
        return timingFunction.solve(at: fractionComplete, duration: duration)
    }
    
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
     Thex target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: Value {
        get { Value(_target) }
        set { _target = newValue.animatableData }
    }
    
    internal var _target: Value.AnimatableData {
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
    internal var fromValue: Value {
        get { Value(_fromValue) }
        set { _fromValue = newValue.animatableData }
    }
    
    internal var _fromValue: Value.AnimatableData
    
    /// The current velocity of the animation.
    public internal(set) var velocity: Value {
        get { Value(_velocity) }
        set { _velocity = newValue.animatableData }
    }
    
    internal var _velocity: Value.AnimatableData = .zero
        
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - timingFunction: The timing curve of the animation.
        - duration: The duration of the animation.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(timingFunction: TimingFunction, duration: CGFloat, value: Value, target: Value) {
        self._value = value.animatableData
        self._fromValue = _value
        self._target = target.animatableData
        self.duration = duration
        self.timingFunction = timingFunction
    }
    
    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil
    
    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupID = settings.groupID
        timingFunction = settings.animationType.timingFunction ?? timingFunction
        duration = settings.animationType.duration ?? duration
        integralizeValues = settings.integralizeValues
        repeats = settings.repeats
        autoStarts = settings.autoStarts
        autoreverse = settings.autoreverse
    }
            
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        state = .running
        
        if value == target {
            fractionComplete = 1.0
        }
                
        let isAnimated = duration > .zero
        
        guard deltaTime > 0.0 else { return }
                
        let previousValue = _value

        if isAnimated {
            let secondsElapsed = deltaTime/duration
            fractionComplete = isReversed ? (fractionComplete - secondsElapsed) : (fractionComplete + secondsElapsed)
            _value = _fromValue.interpolated(towards: _target, amount: resolvedFractionComplete)
        } else {
            fractionComplete = isReversed ? 0.0 : 1.0
            _value = isReversed ? _fromValue : _target
        }
        
        _velocity = (_value - previousValue).scaled(by: 1.0/deltaTime)
        
        let animationFinished = (isReversed ? fractionComplete <= 0.0 : fractionComplete >= 1.0) || !isAnimated
        
        if animationFinished {
            if repeats, isAnimated {
                if autoreverse {
                    isReversed = !isReversed
                }
                fractionComplete = isReversed ? 1.0 : 0.0
                _value = _fromValue.interpolated(towards: _target, amount: resolvedFractionComplete)
            } else {
                _value = isReversed ? _fromValue : _target
            }
        }
        
        let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if (animationFinished && !repeats) || !isAnimated {
            stop(at: .current)
        }
    }
    
    /**
     Starts the animation from its current position with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    public func start(afterDelay delay: TimeInterval = 0.0) {
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
    public func pause() {
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
    public func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        delayedStart?.cancel()
        delay = 0.0
        if immediately == false {
            switch position {
            case .start:
                target = fromValue
            case .current:
                target = value
            default: break
            }
        } else {
            AnimationController.shared.stopAnimation(self)
            state = .inactive
            switch position {
            case .start:
                value = fromValue
                valueChanged?(value)
            case .end:
                value = target
                valueChanged?(value)
            default: break
            }
            target = value
            reset()
            velocity = .zero
            completion?(.finished(at: value))
        }
    }
    
    /// Resets the animation.
    func reset() {
        delayedStart?.cancel()
        fractionComplete = 0.0
        _velocity = .zero
    }
}

extension EasingAnimation: CustomStringConvertible {
    public var description: String {
        """
        EasingAnimation<\(Value.self)>(
            uuid: \(id)
            groupID: \(groupID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state)
        
            value: \(value)
            target: \(target)
            fromValue: \(fromValue)
            velocity: \(velocity)
            fractionComplete: \(fractionComplete)

            timingFunction: \(timingFunction.name)
            duration: \(duration)
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
        _value = _fromValue.interpolated(towards: _target, amount: fractionComplete)
    } else {
        _value = _fromValue.interpolated(towards: _target, amount: resolvedFractionComplete)
    }
    valueChanged?(value)
}
*/
