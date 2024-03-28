//
//  Anima.AnimationConfiguration.swift
//  
//
//  Created by Florian Zand on 23.03.24.
//

import Foundation

extension Anima {
    /// The configuration of an animation block.
    struct AnimationConfiguration {
        let groupID: UUID
        let type: GroupType
        let delay: CGFloat
        let options: Anima.AnimationOptions
        var spring: SpringParameters?
        var easing: EasingParameters?
        var decay: DecayParameters?
        
        var animationType: AnimationType? {
            switch type {
            case .spring: return .spring
            case .easing: return .easing
            case .decay, .decayVelocity: return .decay
            default: return nil
            }
        }
        
        enum GroupType: Int {
            /// Spring animation.
            case spring
            /// Easing animation
            case easing
            /// Decay animation.
            case decay
            /// Decay velocity animation.
            case decayVelocity
            /// Non animated value updates.
            case nonAnimated
            /// Animation velocity updates.
            case animationVelocity
            /// Animation value updates.
            case animationValue
        }
        
        struct SpringParameters {
            let spring: Spring
            let gestureVelocity: (any AnimatableProperty)?
        }
        
        struct EasingParameters {
            let timingFunction: TimingFunction
            let duration: TimeInterval
        }
        
        struct DecayParameters {
            let decelerationRate: Double
        }
        
        init(type: GroupType, groupID: UUID = UUID(), delay: CGFloat = 0.0, options: Anima.AnimationOptions = [], spring: SpringParameters? = nil, easing: EasingParameters? = nil, decay: DecayParameters? = nil) {
            self.groupID = groupID
            self.delay = delay
            self.type = type
            self.options = options
            self.spring = spring
            self.easing = easing
            self.decay = decay
        }
    }
}
