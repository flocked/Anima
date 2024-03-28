//
//  AnimationGroupConfiguration.swift
//  
//
//  Created by Florian Zand on 23.03.24.
//

import Foundation

struct AnimationGroupConfiguration {
    let groupID: UUID
    let type: GroupType
    let delay: CGFloat
    let options: Anima.AnimationOptions
    let completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)?
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
    
    init(type: GroupType, groupID: UUID = UUID(), delay: CGFloat = 0.0, options: Anima.AnimationOptions = [], completion: ((_: Bool, _: Bool) -> Void)? = nil) {
        self.groupID = groupID
        self.delay = delay
        self.type = type
        self.options = options
        self.completion = completion
    }
}
