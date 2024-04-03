//
//  Keyframe.swift
//  
//
//  Created by Florian Zand on 29.03.24.
//

/*
import Foundation

public class KeyframeAnimation {
    var keyframes: [Keyframe]
    public init(@KeyframeBuilder keyframes: () -> [Keyframe]) {
        self.keyframes = keyframes()
    }
}

public struct KeyframeTrack: Keyframe {
    let delay: TimeInterval
    let keyframes: [Keyframe]
    
    
    public init(delay: TimeInterval = 0, @KeyframeBuilder keyframes: () -> [Keyframe]) {
        self.delay = delay
        self.keyframes = keyframes()
    }
}

public protocol Keyframe { }

public struct MoveKeyframe: Keyframe {
    let changes: ()->()
    let delay: TimeInterval
    
    var configuration: Anima.AnimationConfiguration{
        .init(type: .nonAnimated, delay: delay, options: [])
    }

    public init(delay: TimeInterval = 0, changes: @escaping () -> Void) {
        self.changes = changes
        self.delay = delay
    }
}

public struct SpringKeyframe: Keyframe {
    let spring: Spring
    let initalVelocity: (any AnimatableProperty)?
    let delay: TimeInterval
    let animations: ()->()
    
    var configuration: Anima.AnimationConfiguration{
        .init(type: .spring, delay: delay, options: [], animation: .init(spring: spring, gestureVelocity: initalVelocity))
    }
    
    public init(spring: Spring = .snappy, initalVelocity: (any AnimatableProperty)? = nil, delay: TimeInterval = 0,  animations: @escaping () -> Void) {
        self.spring = spring
        self.initalVelocity = initalVelocity
        self.delay = delay
        self.animations = animations
    }
}

public struct EasingKeyframe: Keyframe {
    let timingFunction: TimingFunction
    let duration: TimeInterval
    let delay: TimeInterval
    let animations: ()->()
    
    var configuration: Anima.AnimationConfiguration{
        .init(type: .easing, delay: delay, options: [], animation: .init(duration: duration, timingFunction: timingFunction))
    }
    
    public init(timingFunction: TimingFunction, duration: TimeInterval, delay: TimeInterval = 0, animations: @escaping () -> Void) {
        self.timingFunction = timingFunction
        self.duration = duration
        self.delay = delay
        self.animations = animations
    }
}

public struct DecayKeyframe: Keyframe {
    let mode: Anima.DecayAnimationMode
    let decelerationRate: Double
    let delay: TimeInterval
    let animations: ()->()
    
    var configuration: Anima.AnimationConfiguration{
        .init(type: mode == .velocity ? .decayVelocity : .decay, delay: delay, options: [], animation: .init(decelerationRate: decelerationRate))
    }
    
    public init(mode: Anima.DecayAnimationMode, decelerationRate: Double  = DecayFunction.ScrollViewDecelerationRate, delay: TimeInterval = 0, animations: @escaping () -> Void) {
        self.mode = mode
        self.decelerationRate = decelerationRate
        self.delay = delay
        self.animations = animations
    }
}

@resultBuilder
public enum KeyframeBuilder {
    public static func buildBlock(_ block: [Keyframe]...) -> [Keyframe] {
        block.flatMap { $0 }
    }

    public static func buildOptional(_ item: [Keyframe]?) -> [Keyframe] {
        item ?? []
    }

    public static func buildEither(first: [Keyframe]?) -> [Keyframe] {
        first ?? []
    }

    public static func buildEither(second: [Keyframe]?) -> [Keyframe] {
        second ?? []
    }

    public static func buildArray(_ components: [[Keyframe]]) -> [Keyframe] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expr: [Keyframe]?) -> [Keyframe] {
        expr ?? []
    }

    public static func buildExpression(_ expr: Keyframe?) -> [Keyframe] {
        expr.map { [$0] } ?? []
    }
}

protocol ObjectKeyframe {
   associatedtype Object
}
*/
