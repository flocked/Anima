//
//  AnimationProviding.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import Foundation

///  A type that provides an animation.
public protocol AnimationProviding {
    /// A unique identifier for the animation.
    var id: UUID { get }
    
    /// A unique identifier that associates an animation with an grouped animation block.
    var groupUUID: UUID? { get }
    
    /// The relative priority of the animation.
    var relativePriority: Int { get set }
    
    /// The current state of the animation.
    var state: AnimationState { get }
    
    /**
     The delay (in seconds) after which the animations begin.
     
     The default value of this property is `0`. When the value is greater than `0`, the start of any animations is delayed by the specified amount of time.
     To set a value for this property, use the ``start(afterDelay:)`` method when starting your animations.
     */
    var delay: TimeInterval { get }
    
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    func updateAnimation(deltaTime: TimeInterval)
    
    /**
     Starts the animation from its current position with an optional delay.
     
     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    func start(afterDelay delay: TimeInterval)
    
    /// Pauses the animation at the current position.
    func pause()
    
    /**
     Stops the animation at the specified position.
     
     - Parameters:
        - position: The position at which position the animation should stop (``AnimationPosition/current``, ``AnimationPosition/start`` or ``AnimationPosition/end``). The default value is `current`.
        - immediately: A Boolean value that indicates whether the animation should stop immediately at the specified position. The default value is `true`.
     */
    func stop(at position: AnimationPosition, immediately: Bool)
}

extension AnimationProviding {
    public func start(afterDelay delay: TimeInterval = 0.0) {
        precondition(delay >= 0, "Animation start delay must be greater or equal to zero.")
        guard var animation = self as? (any ConfigurableAnimationProviding) else { return }
        guard state != .running else { return }
        
        let start = {
            AnimationController.shared.runAnimation(self)
        }
        
        animation.delayedStart?.cancel()
        animation.delay = delay

        if delay == .zero {
            start()
        } else {
            let task = DispatchWorkItem {
                start()
            }
            animation.delayedStart = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }

    public func pause() {
        guard var animation = self as? (any ConfigurableAnimationProviding) else { return }
        guard state == .running else { return }
        AnimationController.shared.stopAnimation(self)
        animation.state = .inactive
        animation.delayedStart?.cancel()
        animation.delay = 0.0
    }
    
    public func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        guard state == .running else { return }
        (self as? any ConfigurableAnimationProviding)?.internal_stop(at: position, immediately: immediately)
    }
}

/// An internal extension to `AnimationProviding` used for configurating animations.
internal protocol ConfigurableAnimationProviding<Value>: AnimationProviding {
    associatedtype Value: AnimatableProperty
    var state: AnimationState { get set }
    var delay: TimeInterval { get set }
    var value: Value { get set }
    var target: Value { get set }
    var fromValue: Value { get set }
    var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
    var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
    var delayedStart: DispatchWorkItem? { get set }
    var velocity: Value { get set }
    var _velocity: Value.AnimatableData { get set }
    func configure(withSettings settings: AnimationController.AnimationParameters)
    func reset()
}

extension ConfigurableAnimationProviding {
    func setAnimatableVelocity(_ velocity: Any) {
        guard let velocity = velocity as? Value.AnimatableData, velocity != _velocity else { return }
        var animation = self
        animation._velocity = velocity
    }
    
    func setVelocity(_ velocity: Any) {
        guard let velocity = velocity as? Value, velocity != self.velocity else { return }
        var animation = self
        animation.velocity = velocity
    }
}

internal extension ConfigurableAnimationProviding {
    func internal_stop(at position: AnimationPosition, immediately: Bool = true) {
        var animation = self
        animation.delayedStart?.cancel()
        animation.delay = 0.0
        if immediately == false, isVelocityAnimation {
            switch position {
            case .start:
                animation.target = fromValue
            case .current:
                animation.target = value
            default: break
            }
        } else {
            AnimationController.shared.stopAnimation(self)
            animation.state = .inactive
            switch position {
            case .start:
                animation.value = fromValue
                animation.valueChanged?(value)
            case .end:
                animation.value = target
                animation.valueChanged?(value)
            default: break
            }
            animation.target = value
            animation.reset()
            animation.velocity = .zero
        //    (self as? (any AnimationVelocityProviding))?.setVelocity(Value.zero)
            (self as? EasingAnimation<Value>)?.fractionComplete = 1.0
            completion?(.finished(at: value))
        }
    }
    
    /// A Boolean value that indicates whether the animation can be started.
    var canBeStarted: Bool {
        guard state != .running else { return false }
        if let animation = (self as? DecayAnimation<Value>) {
            return animation._velocity != .zero
        }
        return value != target
    }
    
    /// A Boolean value that indicates whether the animation has a velocity value.
    var isVelocityAnimation: Bool {
        (self as? SpringAnimation<Value>) != nil || (self as? DecayAnimation<Value>) != nil
    }
}
