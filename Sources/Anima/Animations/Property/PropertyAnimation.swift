//
//  PropertyAnimation.swift
//
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation

/**
 Subclassing this class let's you create your own animations. the animation itself isn't animating and your have to provide your own animation implemention in your subclass.

 ## Start and stop the animation

 To start your animation, use ``start(afterDelay:)``. It  changes the ``state`` to `running` and updates ``delay``.

 To stop a running animation either use ``stop(at:immediately:)`` or change the `state` to `ended` or `inactive`.

 Calling ``pause()`` changes the `state` to `inactive`.

 If you overwrite ``start(afterDelay:)``, ``pause()`` or ``stop(at:immediately:)`` make sure to call super.

 - Note: Changing `state` itself isn't starting or stopping an animation. It only reflects the state of your animation. You have to use the above functions.

 ## Update animation values

 ``startValue`` is value when the animation starts. Make sure to update it on start as it's used as value when the position of ``stop(at:immediately:)`` is `start`.

 ``target`` is the target value of the animation. Your animation should stop when it reaches the animation by calling ``stop(at:immediately:)``.

 ``velocity`` is the velocity of the animation. If your animation doesn't use any velocity you can ignore this value. It's default value is `zero`.

 ``value`` is the current value of the animation.

 ``updateAnimation(deltaTime:)`` gets called until you stop the animation. You should update `value` inside it. Call `super` and it will send the current value to ``valueChanged`` and stops it if the value equals the target value.
 */
open class PropertyAnimation<Value: AnimatableProperty>: AnimationProviding, CustomStringConvertible {
    /// A unique identifier for the animation.
    public var id: UUID {
        _id
    }
    let _id = UUID()

    /// A unique identifier that associates the animation with an grouped animation block.
    open internal(set) var groupID: UUID?

    /// The relative priority of the animation. The higher the number the higher the priority.
    open var relativePriority: Int = 0

    /// The current state of the animation.
    open internal(set) var state: AnimatingState = .inactive

    /// The delay (in seconds) after which the animations begin.
    open internal(set) var delay: TimeInterval = 0.0
    
    /// Additional animation options.
    open var options: Anima.AnimationOptions = []

    /// A Boolean value indicating whether the animation is running in the reverse direction.
    var isReversed: Bool = false
  
    var runningTime: TimeInterval = 0.0

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
                completion?(.retargeted(from: Value(oldValue), to: target))
            } else if options.autoStarts, _target != _value {
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
    public init(value: Value, target: Value) {
        _value = value.animatableData
        _startValue = _value
        _target = target.animatableData
    }

    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }

    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem?

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
    open func updateAnimation(deltaTime: TimeInterval) {
        guard state == .running else { return }
        let callbackValue = options.integralizeValues ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if _value == _target {
            stop(at: .end)
        }
    }

    /**
     Starts the animation from its current position with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    open func start(afterDelay delay: TimeInterval = 0.0) {
        precondition(delay >= 0, "Animation start delay must be greater or equal to zero.")
        guard state != .running else { return }

        let start = { [weak self] in
            guard let self = self else { return }
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
        guard state == .running else { return }
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
            velocity = .zero
            completion?(.finished(at: value))
        }
    }

    /// Resets the animation.
    func reset() {
        delayedStart?.cancel()
        _startValue = _value
        runningTime = 0.0
    }
    
    public var description: String {
        """
        PropertyAnimation<\(Value.self)>(
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
