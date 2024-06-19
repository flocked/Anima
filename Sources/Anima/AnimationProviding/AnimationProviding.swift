//
//  AnimationProviding.swift
//
//
//  Created by Florian Zand on 28.03.24.
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
    
    /**
     Updates the animation.
          
     - Parameter deltaTime: The time interval since the last update.
     */
    func updateAnimation(deltaTime: TimeInterval)
}

enum AnimationType: Int {
    case spring
    case easing
    case decay
    case property
    case cubic
}
