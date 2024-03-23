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
class AnimationController {
    public static let shared = AnimationController()

    private var displayLink: AnyCancellable?

    private var animations: [UUID: any ConfigurableAnimationProviding] = [:]
    private var animationSettingsStack = SettingsStack()

    typealias CompletionBlock = (_ finished: Bool, _ retargeted: Bool) -> Void
    var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]

    var currentAnimationParameters: AnimationParameters? {
        animationSettingsStack.currentSettings
    }

    /// The preferred rame rate of the animations.
    @available(macOS 14.0, iOS 15.0, tvOS 15.0, *)
    public var preferredFrameRateRange: CAFrameRateRange {
        get { (_preferredFrameRateRange as? CAFrameRateRange) ?? .default }
        set {
            guard newValue != preferredFrameRateRange else { return }
            _preferredFrameRateRange = newValue
        }
    }

    private var _preferredFrameRateRange: Any? {
        didSet {
            if #available(macOS 14.0, iOS 15.0, tvOS 15.0, *) {
                restartDisplayLink()
            }
        }
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

    public func runAnimation(_ animation: some ConfigurableAnimationProviding) {
        if displayLinkIsRunning == false {
            startDisplayLink()
        }

        animations[animation.id] = animation

        animation.updateAnimation(deltaTime: .zero)
    }

    public func stopAnimation(_ animation: AnimationProviding) {
        animations[animation.id] = nil
    }

    public func stopAllAnimations(immediately: Bool) {
        animations.values.forEach { $0.stop(at: .current, immediately: immediately) }
    }

    private func updateAnimations(_ frame: DisplayLink.Frame) {
        guard displayLinkIsRunning else {
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
                stopAnimation(animation)
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
        guard displayLinkIsRunning == false else { return }
        if #available(macOS 14.0, iOS 15.0, tvOS 15.0, *), preferredFrameRateRange != .default {
            displayLink = DisplayLink(preferredFrameRateRange: preferredFrameRateRange).sink { [weak self] frame in
                self?.updateAnimations(frame)
            }
        } else {
            displayLink = DisplayLink.shared.sink { [weak self] frame in
                self?.updateAnimations(frame)
            }
        }
    }

    private func stopDisplayLink() {
        displayLink?.cancel()
        displayLink = nil
    }

    private func restartDisplayLink() {
        guard displayLinkIsRunning else { return }
        stopDisplayLink()
        startDisplayLink()
    }

    private var displayLinkIsRunning: Bool {
        displayLink != nil
    }

    func executeHandler(uuid: UUID?, finished: Bool, retargeted: Bool) {
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
        let configuration: AnimationConfiguration
        let options: Anima.AnimationOptions
        let completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)?

        init(groupID: UUID, delay: CGFloat = 0.0, configuration: AnimationConfiguration, options: Anima.AnimationOptions = [], completion: ((_: Bool, _: Bool) -> Void)? = nil) {
            self.groupID = groupID
            self.delay = delay
            self.configuration = configuration
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
            !configuration.isNonAnimated
        }

        var resetSpringVelocity: Bool {
            options.contains(.resetSpringVelocity)
        }

        #if os(iOS) || os(tvOS)
            var preventUserInteraction: Bool {
                options.contains(.preventUserInteraction)
            }
        #endif

        var animationType: AnimationType? {
            configuration.type
        }

        enum AnimationType {
            case spring
            case easing
            case decay
        }

        enum AnimationConfiguration {
            case spring(spring: Spring, gestureVelocity: (any AnimatableProperty)?)
            case easing(timingFunction: TimingFunction, duration: TimeInterval)
            case decay(mode: Anima.DecayAnimationMode, decelerationRate: Double)
            case nonAnimated
            case velocityUpdate
            case animationValueUpdate

            var type: AnimationType? {
                switch self {
                case .spring: return .spring
                case .easing: return .easing
                case .decay: return .decay
                default: return nil
                }
            }
            
            var isAnimationValue: Bool {
                switch self {
                case .animationValueUpdate: return true
                default: return false
                }
            }

            var isDecayVelocity: Bool {
                switch self {
                case let .decay(mode, _): return mode == .velocity
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
                case .velocityUpdate: return true
                case .decay(let mode,_): return mode == .velocity
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
                case let .decay(_, decelerationRate): return decelerationRate
                default: return nil
                }
            }

            var spring: Spring? {
                switch self {
                case let .spring(spring, _): return spring
                default: return nil
                }
            }

            var timingFunction: TimingFunction? {
                switch self {
                case let .easing(timingFunction, _): return timingFunction
                default: return nil
                }
            }

            var duration: TimeInterval? {
                switch self {
                case let .easing(_, duration): return duration
                default: return nil
                }
            }

            var gestureVelocity: (any AnimatableProperty)? {
                switch self {
                case let .spring(_, gestureVelocity): return gestureVelocity
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
