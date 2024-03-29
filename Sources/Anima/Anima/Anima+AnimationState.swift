//
//  Anima+AnimationState.swift
//  
//
//  Created by Florian Zand on 28.03.24.
//

import Foundation

extension Anima {
    /// The state of an animation block.
    public enum AnimationState: String, Sendable {
        
        /// All animations finished animating.
        case finished
        
        /// A property from the animation block retargeted to a new value or animation.
        case retargeted
    }
}
