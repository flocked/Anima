//
//  DecayAnimation.swift
//  
//
//  Created by Florian Zand on 29.03.24.
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
open class DecayAnimation<Value: AnimatableProperty>: PropertyAnimation<Value> {
    
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
    
    var duration: TimeInterval = 0.0
    
    override var animationType: AnimationType { .decay }
    
    public override var velocity: Value {
        get { Value(_velocity) }
        set {
            guard newValue != velocity else { return }
            _velocity = newValue.animatableData
            updateTarget()
            runningTime = 0.0
        }
    }
    
    override var _velocity: Value.AnimatableData {
        didSet {
            guard state != .running, oldValue != _velocity else { return }
            _startVelocity = _velocity
            if options.autoStarts, _velocity != .zero {
                start(afterDelay: 0.0)
            }
        }
    }
    
    public override var target: Value {
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
    
    override var _startValue: Value.AnimatableData {
        didSet {
            guard oldValue != _startValue else { return }
            updateTarget()
        }
    }
    
    override var _startVelocity: Value.AnimatableData {
        didSet {
            guard oldValue != _startVelocity else { return }
            updateTarget()
        }
    }
    
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
        self.decayFunction = DecayFunction(decelerationRate: decelerationRate)
        super.init(value: value, target: value)
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
        self.decayFunction = DecayFunction(decelerationRate: decelerationRate)
        super.init(value: value, target: target)
        _velocity = DecayFunction.velocity(startValue: value.animatableData, toValue: target.animatableData)
        _startVelocity = _velocity
        updateTarget()
    }
    
    override func configure(with configuration: Anima.AnimationConfiguration) {
        super.configure(with: configuration)
        decelerationRate = configuration.decay?.decelerationRate ?? decelerationRate
    }
    
    public override func updateAnimation(deltaTime: TimeInterval) {
        state = .running

        decayFunction.update(value: &_value, velocity: &_velocity, deltaTime: deltaTime)

        let animationFinished = _velocity.magnitudeSquared < 0.05

        if animationFinished, options.repeats {
            _value = _startValue
            _velocity = _startVelocity
        }

        runningTime = runningTime + deltaTime

        let callbackValue = options.integralizeValues ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished, !options.repeats {
            stop(at: .current)
        }
    }
    
    public override var description: String {
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

public extension Anima {
    /// The mode how `Anima` should animate properties with a decaying animation.
    enum DecayAnimationMode {
        /// The value of animated properties will increase or decrease (depending on the values applied) with a decelerating rate.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.
        case velocity
        /// The animated properties will animate to the applied values  with a decelerating rate.
        case value
    }
}
