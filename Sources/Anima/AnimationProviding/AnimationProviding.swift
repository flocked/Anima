//
//  AnimationProviding.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import Foundation

///  A type that provides an animation.
public protocol AnimationProviding: AnyObject {
    /// An unique identifier for the animation.
    var id: UUID { get }

    /// An unique identifier that associates the animation with an grouped animation block.
    var groupID: UUID? { get }

    /// The relative priority of the animation. The higher the number the higher the priority.
    var relativePriority: Int { get set }

    /// The current state of the animation.
    var state: AnimatingState { get }

    /**
     The delay (in seconds) after which the animations begin.

     The default value of this property is `0.0`. When the value is greater than `0`, the start of any animations is delayed by the specified amount of time.

     To set a value for this property, use the ``start(afterDelay:)`` method when starting your animations.
     */
    var delay: TimeInterval { get }

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
    func _animation<Value: AnimatableProperty>() -> (any _AnimationProviding<Value>)? {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *), let animation = self as? (any _AnimationProviding<Value>) {
            return animation
        } else if let animation = self as? SpringAnimation<Value> {
            return animation
        } else if let animation = self as? EasingAnimation<Value> {
            return animation
        } else if let animation = self as? DecayAnimation<Value> {
            return animation
        }
        return nil
    }
}

/// An internal protocol to `AnimationProviding` used for configurating the animation.
protocol _AnimationProviding<Value>: AnimationProviding {
    associatedtype Value: AnimatableProperty
    var value: Value { get set }
    var target: Value { get set }
    var startValue: Value { get set }
    var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
    var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
    var velocity: Value { get set }
    var _velocity: Value.AnimatableData { get set }
    var animationType: AnimationType { get }
    func configure(withSettings settings: AnimationGroupConfiguration)
    func reset()
    func updateAnimation(deltaTime: TimeInterval)
}

extension _AnimationProviding {
    var propertyAnimation: PropertyAnimationProviding<Value> {
        getAssociatedValue(key: "propertyAnimation", object: self, initialValue: PropertyAnimationProviding(self))
    }
}

enum AnimationType: Int {
    case spring
    case easing
    case decay
    case property
}
