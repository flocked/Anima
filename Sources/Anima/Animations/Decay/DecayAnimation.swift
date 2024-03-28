//
//  DecayAnimation.swift
//
//  Adopted from:
//  Motion. https://github.com/b3ll/Motion/
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation

/**
  An animation that animates a value with a decaying acceleration.

 There are two ways ways to create a decay animation:

  - **target**: You provide a target and the animation will animate the value to the target with a decaying acceleration.

  ```swift
  let decayAnimation = DecayAnimation(value: value, target: target)
  decayAnimation.valueChanged = { newValue in
      view.frame.origin = newValue
  }
  decayAnimation.start()
  ```

  - **velocity**: You provide a velocity and the animation will increase or decrease the initial value depending on the velocity and will slow to a stop. This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.

  ```swift
  let decayAnimation = DecayAnimation(value: value, velocity: velocity)
  decayAnimation.valueChanged = { newValue in
      view.frame.origin = newValue
  }
  decayAnimation.start()
  ```

  */
open class DecayAnimation<Value: AnimatableProperty>: AnimationProviding, _AnimationProviding {
    
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

    /// A Boolean value that indicates whether the value returned in ``valueChanged`` should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    open var integralizeValues: Bool = false

    /// A Boolean value that indicates whether the animation automatically starts when the target changes or the ``velocity`` changes to a non `zero` value.
    open var autoStarts: Bool = false

    /// A Boolean value indicating whether the animation repeats indefinitely.
    open var repeats: Bool = false

    /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
    open var autoreverse: Bool = false

    /// A Boolean value indicating whether the animation is running in the reverse direction.
    open var isReversed: Bool = false

    /// The rate at which the velocity decays over time.
    public var decelerationRate: Double {
        get { decayFunction.decelerationRate }
        set {
            guard newValue != decelerationRate else { return }
            decayFunction.decelerationRate = newValue
            updateTarget()
        }
    }

    func updateTarget() {
        _target = DecayFunction.destination(value: _startValue, velocity: _startVelocity, decelerationRate: decayFunction.decelerationRate)
        duration = DecayFunction.duration(value: _startValue, velocity: _startVelocity, decelerationRate: decelerationRate)
    }

    /// The decay function used to calculate the animation.
    var decayFunction: DecayFunction

    public var value: Value {
        get { Value(_value) }
        set {
            guard newValue != value else { return }
            _value = newValue.animatableData
            updateTarget()
        }
    }

    var _value: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _startValue = _value
        }
    }

    /// The velocity of the animation. This value will change as the animation executes.
    public var velocity: Value {
        get { Value(_velocity) }
        set {
            guard newValue != velocity else { return }
            _velocity = newValue.animatableData
            updateTarget()
            runningTime = 0.0
        }
    }

    var _velocity: Value.AnimatableData {
        didSet {
            guard state != .running, oldValue != _velocity else { return }
            _startVelocity = _velocity
            if autoStarts, _velocity != .zero {
                start(afterDelay: 0.0)
            }
        }
    }

    /**
     Computes the target value the decay animation will stop at. Getting this value will compute the estimated endpoint for the decay animation. Setting this value adjust the ``velocity`` to an value  that will result in the animation ending up at the specified target when it stops.

     Adjusting this is similar to providing a new `targetContentOffset` in `UIScrollView`'s `scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)`.
     */
    public var target: Value {
        get {
            _velocity == .zero ? value : Value(DecayFunction.destination(value: _value, velocity: _velocity, decelerationRate: decayFunction.decelerationRate))
        }
        set {
            let newVelocity = DecayFunction.velocity(startValue: value.animatableData, toValue: newValue.animatableData)
            guard newVelocity != _velocity else { return }
            _velocity = newVelocity
            _startVelocity = _velocity
            duration = DecayFunction.duration(value: _startValue, velocity: _startVelocity, decelerationRate: decelerationRate)
            _target = newValue.animatableData
            runningTime = 0.0
        }
    }

    var _target: Value.AnimatableData = .zero {
        didSet {
            if state == .running {
                completion?(.retargeted(from: Value(oldValue), to: Value(_target)))
            }
        }
    }

    var startValue: Value {
        get { Value(_startValue) }
        set { _startValue = newValue.animatableData }
    }

    var _startValue: Value.AnimatableData {
        didSet {
            guard oldValue != _startValue else { return }
            updateTarget()
        }
    }

    var startVelocity: Value {
        get { Value(_startVelocity) }
        set { _startVelocity = newValue.animatableData }
    }

    var _startVelocity: Value.AnimatableData {
        didSet {
            guard oldValue != _startVelocity else { return }
            updateTarget()
        }
    }

    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    open var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    open var completion: ((_ event: AnimationEvent<Value>) -> Void)?

    var duration: TimeInterval = 0.0

    var runningTime: TimeInterval = 0.0

    /// The completion percentage of the animation.
    var fractionComplete: CGFloat {
        runningTime / duration
    }

    /**
     Creates a new animation with the specified initial value and velocity.

     - Parameters:
        - value: The start value of the animation.
        - velocity: The velocity of the animation.
        - decelerationRate: The rate at which the velocity decays over time. The default value decelerates like scrollviews.
     */
    public init(value: Value, velocity: Value, decelerationRate: Double = DecayFunction.ScrollViewDecelerationRate) {
        decayFunction = DecayFunction(decelerationRate: decelerationRate)
        _value = value.animatableData
        _startValue = _value
        _velocity = velocity.animatableData
        _startVelocity = _velocity
        updateTarget()
    }

    /**
     Creates a new animation with the specified initial value and target.

     - Parameters:
        - value: The start value of the animation.
        - target: The target value of the animation.
        - decelerationRate: The rate at which the velocity decays over time. The default value decelerates like scrollviews.
     */
    public init(value: Value, target: Value, decelerationRate: Double = DecayFunction.ScrollViewDecelerationRate) {
        decayFunction = DecayFunction(decelerationRate: decelerationRate)
        _value = value.animatableData
        _startValue = _value
        _velocity = DecayFunction.velocity(startValue: value.animatableData, toValue: target.animatableData)
        _startVelocity = _velocity
        updateTarget()
    }

    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }

    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem?

    /// The animation type.
    let animationType: AnimationType = .decay

    /// Configurates the animation with the specified settings.
    func configure(with configuration: Anima.AnimationConfiguration) {
        groupID = configuration.groupID
        repeats = configuration.options.repeats
        autoreverse = configuration.options.autoreverse
        integralizeValues = configuration.options.integralizeValues
        decelerationRate = configuration.decay?.decelerationRate ?? decelerationRate
    }

    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    open func updateAnimation(deltaTime: TimeInterval) {
        state = .running

        decayFunction.update(value: &_value, velocity: &_velocity, deltaTime: deltaTime)

        let animationFinished = _velocity.magnitudeSquared < 0.05

        if animationFinished, repeats {
            _value = _startValue
            _velocity = _startVelocity
        }

        runningTime = runningTime + deltaTime

        let callbackValue = integralizeValues ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished, !repeats {
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

    func reset() {
        runningTime = 0.0
        delayedStart?.cancel()
        _startValue = _value
    }
}

extension DecayAnimation: CustomStringConvertible {
    public var description: String {
        """
        DecayAnimation<\(Value.self)>(
            uuid: \(id)
            groupID: \(groupID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state.rawValue)

            value: \(value)
            velocity: \(velocity)
            target: \(target)

            decelerationRate: \(decelerationRate)
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

public extension Anima {
    /// The mode how `Anima` should animate properties with a decaying animation.
    enum DecayAnimationMode {
        /// The value of animated properties will increase or decrease (depending on the values applied) with a decelerating rate.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.
        case velocity
        /// The animated properties will animate to the applied values  with a decelerating rate.
        case value
    }
}
