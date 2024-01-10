//
//  AnimatingState.swift
//
//
//  Created by Florian Zand on 15.11.23.
//

/// The current state of an ``AnimationProviding``.
public enum AnimatingState: String, Sendable {
    /// The animation is not currently running, but is ready. It also maybe paused. This is the initial state of an animation.
    case inactive

    /// The animation is currently animating.
    case running

    /// The animation has just stopped, and will be reset to the ``inactive`` state.
    case ended
}
