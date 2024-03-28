//
//  AnimationController.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import Combine
#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// Manages the animations of ``Anima``.
class AnimationController {
    public static let shared = AnimationController()

    private var displayLink: AnyCancellable?

    private var animations: [UUID: WeakANimation] = [:]
    private var animationSettingsStack = SettingsStack()

    typealias CompletionBlock = (_ finished: Bool, _ retargeted: Bool) -> Void
    var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]

    var currentGroupConfiguration: AnimationGroupConfiguration? {
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

    func runAnimationGroup(
        configuration: AnimationGroupConfiguration,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil) {
        precondition(Thread.isMainThread, "All Anima animations are to run and be interfaced with on the main thread only. There is no support for threading of any kind.")

        // Register the handler
        groupAnimationCompletionBlocks[configuration.groupID] = completion

        animationSettingsStack.push(settings: configuration)
        animations()
        animationSettingsStack.pop()
    }

    public func runAnimation(_ animation: some _AnimationProviding) {
        if displayLinkIsRunning == false {
            startDisplayLink()
        }
        animations[animation.id] = WeakANimation(animation)
        animation.updateAnimation(deltaTime: .zero)
    }

    public func stopAnimation(_ animation: AnimationProviding) {
        animations[animation.id] = nil
    }
    
    func stopAnimation(_ animation: WeakANimation) {
        animations[animation.id] = nil
    }

    public func stopAllAnimations(immediately: Bool) {
        animations.values.forEach { $0.animation?.stop(at: .current, immediately: immediately) }
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

        for weak in sortedAnimations {
            if let animation = weak.animation {
                if animation.state != .running {
                    stopAnimation(animation)
                } else {
                    animation.updateAnimation(deltaTime: deltaTime)
                }
            } else {
                stopAnimation(weak)
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
    private class SettingsStack {
        private var stack: [AnimationGroupConfiguration] = []
        
        var currentSettings: AnimationGroupConfiguration? {
            stack.last
        }
        
        func push(settings: AnimationGroupConfiguration) {
            stack.append(settings)
        }
        
        func pop() {
            stack.removeLast()
        }
    }
    
    class WeakANimation {
        let id: UUID
        var relativePriority: Int {
            animation?.relativePriority ?? 0
        }
        var animation: (any _AnimationProviding)? {
            (_weakValue ?? _value) as? (any _AnimationProviding)
        }
        weak var _weakValue: AnyObject?
        var _value: Any?
        init(_ animation: any _AnimationProviding) {
            id = animation.id
            if type(of: animation) is AnyClass {
                _weakValue = animation as AnyObject
            } else {
                _value = animation
            }
        }
    }
}
