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
        let options: AnimationOptions
        var animation: AnimationParameters?
        
        var animationType: AnimationType? {
            switch type {
            case .spring: return .spring
            case .easing: return .easing
            case .decay, .decayVelocity: return .decay
            case .cubic: return .cubic
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
            /// Cubic animation.
            case cubic
        }
                
        struct AnimationParameters {
            var duration: TimeInterval? = nil
            var timingFunction: TimingFunction? = nil
            var spring: Spring? = nil
            var gestureVelocity: (any AnimatableProperty)? = nil
            var decelerationRate: Double? = nil
        }
                
        init(type: GroupType, groupID: UUID = UUID(), delay: CGFloat = 0.0, options: AnimationOptions = [], animation: AnimationParameters? = nil) {
            self.groupID = groupID
            self.delay = delay
            self.type = type
            self.options = options
            self.animation = animation
        }
    }
}
