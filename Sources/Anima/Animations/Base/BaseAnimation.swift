//
//  BaseAnimation.swift
//
//
//  Created by Florian Zand on 28.03.24.
//

import Foundation

/**
 Subclassing this class let's you create your own animations.
 
 You have to override ``updateAnimation(deltaTime:)`` with your animation code. If the animation is finished call ``stop()`` inside.

 ## Starting and stopping the animation

 To start the animation, use ``start(afterDelay:)``. It  changes the ``state`` to `running` and updates ``delay``.

 To stop an running animation, use ``stop()``. It  changes the `state` to `ended`.

 To pause an running animation, use ``pause()``. It  changes the `state` to `inactive`.

 If you overwrite ``start(afterDelay:)``, ``pause()`` or ``stop()`` make sure to call super.
 */
open class BaseAnimation: CustomStringConvertible {
    let _id = UUID()
    var delayedStart: DispatchWorkItem?
    
    /// An unique identifier for the animation.
    open var id: UUID {
        _id
    }
    
    /// An unique identifier that associates the animation with an grouped animation block.
    open internal(set) var groupID: UUID? = nil
    
    /**
     The relative priority of the animation. The higher the number the higher the priority.
     
     Running animations are animated in the order of their relative priority.
     */
    open var relativePriority: Int = 0
    
    /// The current state of the animation.
    open internal(set) var state: State = .inactive
    
    public enum State: String, Sendable {
        /// The animation is currently not running. It might be paused. This is the initial state of an animation.
        case inactive

        /// The animation is currently animating.
        case running

        /// The animation has stopped, and will be reset to the ``inactive`` state.
        case ended
    }
    
    /// The delay (in seconds) after which the animation starts.
    open internal(set) var delay: TimeInterval = 0.0
    
    /**
     Starts the animation from its current position with an optional delay.
     
     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    open func start(afterDelay delay: TimeInterval = 0.0) {
        guard state != .running else { return }
        self.delay = delay.clamped(min: 0.0)
        delayedStart?.cancel()
        func start() {
            AnimationController.shared.runAnimation(self)
            state = .running
        }
        if self.delay >= 0.0 {
            let task = DispatchWorkItem {
                start()
            }
            delayedStart = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        } else {
            start()
        }
    }
    
    /// Pauses the animation.
    open func pause() {
        guard state == .running else { return }
        AnimationController.shared.stopAnimation(self)
        delayedStart?.cancel()
        state = .inactive
        delay = 0.0
    }
    
    /// Stops the animation.
    open func stop() {
        guard state == .running else { return }
        AnimationController.shared.stopAnimation(self)
        delayedStart?.cancel()
        state = .ended
        delay = 0.0
    }
    
    /**
     Updates the animation.
          
     - Parameter deltaTime: The time interval since the last update.
     */
    open func updateAnimation(deltaTime: TimeInterval) {
        
    }
    
    open var description: String {
        """
        BaseAnimation(
            uuid: \(id)
            groupID: \(groupID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state.rawValue)
        )
        """
    }
    
    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }
}

enum AnimationType: Int {
    case spring
    case easing
    case decay
    case property
    case cubic
}
