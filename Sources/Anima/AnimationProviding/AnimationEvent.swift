//
//  AnimationEvent.swift
//  
//
//  Created by Florian Zand on 15.11.23.
//

import Foundation

/// Constants indicating that an ``AnimationProviding`` either retargated or finished.
public enum AnimationEvent<Value> {
    /// Indicates the animation has fully completed at the value.
    case finished(at: Value)

    /**
     Indicates that the animation's `target` value was changed in-flight while the animation was running.

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
