//
//  AnimationPosition.swift
//
//
//  Created by Florian Zand on 16.11.23.
//

import Foundation

/// Constants indicating positions within an ``AnimationProviding`` to use with ``AnimationProviding/stop(at:immediately:)``.
public enum AnimationPosition: Int, Sendable {
    /// The end point of the animation. Use this constant when you want to stop an animation at the `target` value.
    case end

    /// The beginning of the animation. Use this constant when you want stop an animation at the starting position.
    case start

    /// The current position. Use this constant when you want to stop an animation at the most recent `value`.
    case current
}
