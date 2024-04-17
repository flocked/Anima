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
    private var animations: [UUID: WeakAimation] = [:]
    private var groupAnimationCompletionBlocks: [UUID: (handler: ((_ state: Anima.AnimationState) -> Void), count: Int)] = [:]
    var animationConfigurationStack = ConfigurationStack()
    var currentAnimationConfiguration: Anima.AnimationConfiguration? {
        animationConfigurationStack.current
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
        configuration: Anima.AnimationConfiguration,
        animations: () -> Void,
        completion: ((_ state: Anima.AnimationState) -> Void)? = nil) {
        precondition(Thread.isMainThread, "All Anima animations are to run and be interfaced with on the main thread only. There is no support for threading of any kind.")

        if let completion = completion {
            groupAnimationCompletionBlocks[configuration.groupID] = (completion, 0)
        }
        animationConfigurationStack.push(configuration)
        animations()
        animationConfigurationStack.pop()
    }

    public func runAnimation(_ animation: some AnimationProviding) {
        if displayLinkIsRunning == false {
            startDisplayLink()
        }
        animations[animation.id] = WeakAimation(animation)
        animation.updateAnimation(deltaTime: .zero)
    }

    public func stopAnimation(_ animation: AnimationProviding) {
        animations[animation.id] = nil
    }
    
    func stopAnimation(_ animation: WeakAimation) {
        animations[animation.id] = nil
    }

    public func stopAllAnimations(immediately: Bool) {
        animations.values.forEach { $0.animation?.stop(at: .current, immediately: immediately) }
    }

    private func updateAnimations(_ frame: DisplayLink.Frame) {
        guard displayLinkIsRunning else {
            fatalError("Can't update animations without a display link")
        }
        
        DisableActions {
            let sortedAnimations = animations.values.sorted(by: \.relativePriority, .descending)
            for weak in sortedAnimations {
                if let animation = weak.animation, animation.state == .running {
                    animation.updateAnimation(deltaTime: frame.duration)
                } else {
                    stopAnimation(weak)
                }
            }
        }
        
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
    
    func addAnimationCount(uuid: UUID?) {
        guard let uuid = uuid, var block = groupAnimationCompletionBlocks[uuid] else {
            return
        }
        block.count += 1
        groupAnimationCompletionBlocks[uuid] = block
    }

    func executeGroupHandler(uuid: UUID?, state: Anima.AnimationState) {
        guard let uuid = uuid, var block = groupAnimationCompletionBlocks[uuid] else {
            return
        }
        Swift.print(block.count)
        block.count -= 1
        groupAnimationCompletionBlocks[uuid] = block
        if state == .retargeted {
            block.handler(state)
        } else if block.count <= 0 {
            block.handler(state)
            groupAnimationCompletionBlocks[uuid] = nil
        }
    }
}

extension AnimationController {
    class ConfigurationStack {
        private var stack: [Anima.AnimationConfiguration] = []
        
        var current: Anima.AnimationConfiguration? {
            stack.last
        }
        
        func push(_ configuration: Anima.AnimationConfiguration) {
            stack.append(configuration)
        }
        
        func pop() {
            stack.removeLast()
        }
    }
    
    class WeakAimation {
        let id: UUID
        
        var relativePriority: Int {
            animation?.relativePriority ?? 0
        }
        
        weak var animation: (any AnimationProviding)?
        
        init(_ animation: some AnimationProviding) {
            id = animation.id
            self.animation = animation
        }
    }
}
