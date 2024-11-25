//
//  ValueAnimation.swift
//
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation

/**
 An animation that animates a value to a target value.
 
 ## Creating an own animation.
 
 ``BaseAnimation`` itself isn't animating and you have to subclass it.
  
 In your subclass you have, override ``updateAnimation(deltaTime:)`` and provide the code that updates ``value`` towards ``target``.
 
 Call `super` at the end of your implementation. It sends the current `value` to ``valueChanged`` and stops the animation, if the`target` is reached.

 ## Start and stop the animation

 To start the animation, use ``BaseAnimation/start(afterDelay:)``. It  changes the ``BaseAnimation/state-swift.property`` to `running` and updates ``BaseAnimation/delay``.

 To stop a running animation, use ``stop(at:immediately:)``. It changes the `state` to `ended`.
 
 Calling ``BaseAnimation/pause()``, pauses a running animation and changes the `state` to `inactive`.

 If you overwrite ``BaseAnimation/start(afterDelay:)``, ``BaseAnimation/pause()`` or ``stop(at:immediately:)`` make sure to call `super`.

 ## Update animation values

 - ``startValue`` is the value when the animation starts. Make sure to update it on start as it's used as value when the position of ``stop(at:immediately:)`` is `start`.
 - ``target`` is the target value of the animation. Your animation should stop when it reaches the animation by calling ``stop(at:immediately:)``.
 - ``velocity`` is the velocity of the animation. If your animation doesn't use any velocity you can ignore this value. It's default value is `zero`.
 - ``value`` is the current value of the animation.
 */
open class ValueAnimation<Value: AnimatableProperty>: BaseAnimation {
    /// Additional animation options.
    open var options: Anima.AnimationOptions = []

    /// A Boolean value indicating whether the animation is running in the reverse direction.
    var isReversed: Bool = false
  
    var runningTime: TimeInterval = 0.0

    /**
     The _current_ value of the animation.
     
     This value updates while the animation is running.
     */
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
                if _target == _value {
                    stop(at: .end, immediately: true)
                } else {
                    completion?(.retargeted(from: Value(oldValue), to: target))
                }
            } else if options.autoStarts, _target != _value {
                start(afterDelay: 0.0)
            }
        }
    }

    /// The start value of the animation.
    public var startValue: Value {
        get { Value(_startValue) }
        set { _startValue = newValue.animatableData }
    }

    var _startValue: Value.AnimatableData

    /**
     The _current_ velocity of the animation.
     
     This value might update while the animation is running.
     */
    public var velocity: Value {
        get { Value(_velocity) }
        set { _velocity = newValue.animatableData }
    }

    var _velocity: Value.AnimatableData = .zero

    var startVelocity: Value {
        get { Value(_startVelocity)  }
        set { _startVelocity = newValue.animatableData }
    }
    
    var _startVelocity: Value.AnimatableData = .zero
    

    /// The callback block to call when the animation's ``ValueAnimation/value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    open var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    open var completion: ((_ event: AnimationEvent) -> Void)?

    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.

     - Parameters:
        - timingFunction: The timing curve of the animation.
        - duration: The duration of the animation.
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(value: Value, target: Value) {
        _value = value.animatableData
        _startValue = _value
        _target = target.animatableData
    }

    /// The animation type.
    var animationType: AnimationType { .property }

    /// Configurates the animation with the specified settings.
    func configure(with configuration: Anima.AnimationConfiguration) {
        groupID = configuration.groupID
        options = configuration.options
    }

    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    open override func updateAnimation(deltaTime: TimeInterval) {
        guard state == .running else { return }
        let callbackValue = options.integralizeValues ? value.scaledIntegral : value
        valueChanged?(callbackValue)
        runningTime += deltaTime
        if _value == _target {
            stop(at: .end)
        }
    }
    
    open override func stop() {
        stop(at: .current, immediately: true)
    }

    /**
     Stops the animation at the specified position.

     - Parameters:
        - position: The position at which position the animation should stop (``AnimationPosition/current``, ``AnimationPosition/start`` or ``AnimationPosition/end``). The default value is `current`.
        - immediately: A Boolean value that indicates whether the animation should stop immediately at the specified position. The default value is `true`.
     */
    open func stop(at position: AnimationPosition, immediately: Bool = true) {
        guard state == .running else { return }
        delayedStart?.cancel()
        delay = 0.0
        if !immediately {
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
            velocity = .zero
            completion?(.finished(at: value))
        }
    }
    
    /// The position of an animation.
    public enum AnimationPosition: String, Sendable {
        /**
         End position of the animation.
         
         Use this value to stop an animation at it's `target` value.
         */
        case end

        /**
         Start position of the animation.
         
         Use this value to stop an animation at it's `startValue`.
         */
        case start

        /**
         Current position of the animation.
         
         Use this value to stop an animation at it's current `value`.
         */
        case current
    }

    /// Resets the animation.
    func reset() {
        delayedStart?.cancel()
        _startValue = _value
        runningTime = 0.0
    }
    
    public override var description: String {
        """
        ValueAnimation<\(Value.self)>(
            uuid: \(id)
            groupID: \(groupID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state.rawValue)

            value: \(value)
            target: \(target)
            startValue: \(startValue)
            velocity: \(velocity)
        
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
    
    /// Constants indicating that an animation is either retargated or finished.
    public enum AnimationEvent {
        /// The animation finished at the value.
        case finished(at: Value)
        
        /**
         The animation's `target` value changed in-flight while the animation is running.
         
         - Parameters:
            - from: The previous `target` value of the animation.
            - to: The new `target` value of the animation.
         */
        case retargeted(from: Value, to: Value)
        
        /// A Boolean value that indicates whether the animation is finished.
        public var isFinished: Bool {
            switch self {
            case .finished: return true
            case .retargeted: return false
            }
        }
        
        /// A Boolean value that indicates whether the animation is retargeted.
        public var isRetargeted: Bool {
            switch self {
            case .finished: return false
            case .retargeted: return true
            }
        }
    }
    
    func stopAtCurrent(immediately: Bool = true) {
        stop(at: .current, immediately: immediately)
    }
}
