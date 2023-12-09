//
//  AnimationController.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import Combine
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Manages all ``Anima`` animations.
internal class AnimationController {
    public static let shared = AnimationController()

    private var displayLink: AnyCancellable?

    private var animations: [UUID: AnimationProviding] = [:]
    private var animationSettingsStack = SettingsStack()
    
    typealias CompletionBlock = (_ finished: Bool, _ retargeted: Bool) -> Void
    var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]

    var currentAnimationParameters: AnimationParameters? {
        animationSettingsStack.currentSettings
    }

    func runAnimationBlock(
        settings: AnimationParameters,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        precondition(Thread.isMainThread, "All Anima animations are to run and be interfaced with on the main thread only. There is no support for threading of any kind.")

        // Register the handler
        groupAnimationCompletionBlocks[settings.groupID] = completion

        animationSettingsStack.push(settings: settings)
        animations()
        animationSettingsStack.pop()
    }

    public func runAnimation(_ animation: AnimationProviding) {
        if animations.isEmpty {
            startDisplayLink()
        }

        animations[animation.id] = animation

        animation.updateAnimation(deltaTime: .zero)
    }
    
    public func stopAnimation(_ animation: AnimationProviding) {
        animations[animation.id] = nil
    }
    
    func stopAllAnimations(immediately: Bool = true) {
        animations.values.forEach({$0.stop(at: .current, immediately: immediately)})
    }

    private func updateAnimations(_ frame: DisplayLink.Frame) {
        guard displayLink != nil else {
            fatalError("Can't update animations without a display link")
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        #if os(macOS)
        let deltaTime = frame.duration / 2.0
        #else
        let deltaTime = frame.duration
        #endif
        
        let sortedAnimations = animations.values.sorted(by: \.relativePriority, .descending)

        for animation in sortedAnimations {
            if animation.state != .running {
                self.stopAnimation(animation)
            } else {
                animation.updateAnimation(deltaTime: deltaTime)
            }
        }

        CATransaction.commit()

        if animations.isEmpty {
            stopDisplayLink()
        }
    }

    private func startDisplayLink() {
        if displayLink == nil {
            displayLink = DisplayLink.shared.sink { [weak self] frame in
                guard let self = self else { return }
                self.updateAnimations(frame)
            }
        }
    }

    private func stopDisplayLink() {
        displayLink?.cancel()
        displayLink = nil
    }
    
    internal func executeHandler(uuid: UUID?, finished: Bool, retargeted: Bool) {
        guard let uuid = uuid, let block = groupAnimationCompletionBlocks[uuid] else {
            return
        }
        
        block(finished, retargeted)

        if retargeted == false, finished {
            groupAnimationCompletionBlocks[uuid] = nil
        }
    }
}

extension AnimationController {
    struct AnimationParameters {
        let groupID: UUID
        let delay: CGFloat
        let animationType: AnimationType
        let options: Anima.AnimationOptions
        let completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)?
        
        init(groupID: UUID, delay: CGFloat = 0.0, animationType: AnimationType, options: Anima.AnimationOptions = [], completion: ( (_: Bool, _: Bool) -> Void)? = nil) {
            self.groupID = groupID
            self.delay = delay
            self.animationType = animationType
            self.options = options
            self.completion = completion
        }

        var repeats: Bool {
            options.contains(.repeats)
        }
        
        var integralizeValues: Bool {
            options.contains(.integralizeValues)
        }
        
        var autoreverse: Bool {
            options.contains(.autoreverse)
        }
        
        var isAnimation: Bool {
            !animationType.isNonAnimated
        }
        
        var resetSpringVelocity: Bool {
            options.contains(.resetSpringVelocity)
        }
                
        #if os(iOS) || os(tvOS)
        var preventUserInteraction: Bool {
            options.contains(.preventUserInteraction)
        }
        #endif
        
        enum AnimationType {
            case spring(spring: Spring, gestureVelocity: CGPoint?)
            case easing(timingFunction: TimingFunction, duration: TimeInterval)
            case decay(mode: Anima.DecayAnimationMode, decelerationRate: Double)
            case nonAnimated
            case velocityUpdate
            
            var isDecayVelocity: Bool {
                switch self {
                case .decay(let mode, _): return mode == .velocity
                default: return false
                }
            }
            
            var isVelocityUpdate: Bool {
                switch self {
                case .velocityUpdate: return true
                default: return false
                }
            }
            
            var isAnyVelocity: Bool {
                switch self {
                case .velocityUpdate, .decay(_, _): return true
                default: return false
                }
            }
            
            var isNonAnimated: Bool {
                switch self {
                case .nonAnimated: return true
                default: return false
                }
            }
            
            var decelerationRate: Double? {
                switch self {
                case .decay(_, let decelerationRate): return decelerationRate
                default: return nil
                }
            }
            
            var spring: Spring? {
                switch self {
                case.spring(let spring,_):  return spring
                default: return nil
                }
            }
            
            var timingFunction: TimingFunction? {
                switch self {
                case.easing(let timingFunction,_): return timingFunction
                default: return nil
                }
            }
            
            var duration: TimeInterval? {
                switch self {
                case.easing(_, let duration): return duration
                default: return nil
                }
            }
            
            var gestureVelocity: CGPoint? {
                switch self {
                case .spring(_, let gestureVelocity): return gestureVelocity
                default: return nil
                }
            }
        }
    }

    private class SettingsStack {
        private var stack: [AnimationParameters] = []

        var currentSettings: AnimationParameters? {
            stack.last
        }

        func push(settings: AnimationParameters) {
            stack.append(settings)
        }

        func pop() {
            stack.removeLast()
        }
    }
}
