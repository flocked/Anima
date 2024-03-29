//
//  PropertyAnimationProviding.swift
//  
//
//  Created by Florian Zand on 28.03.24.
//

import Foundation
import CoreGraphics
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// An animation that animates the value of a property.
public class PropertyAnimationProviding<Value: AnimatableProperty> {
    
    /// An unique identifier for the animation.
    public var id: UUID { animation.id }

    /// An unique identifier that associates the animation with an grouped animation block.
    public var groupID: UUID? { animation.groupID }

    /// The relative priority of the animation. The higher the number the higher the priority.
    public var relativePriority: Int {
        get { animation.relativePriority }
        set { animation.relativePriority = newValue }
    }

    /// The current state of the animation.
    public var state: AnimatingState { animation.state }
    
    /**
     The delay (in seconds) after which the animations begin.

     The default value of this property is `0.0`. When the value is greater than `0`, the start of any animations is delayed by the specified amount of time.

     To set a value for this property, use the ``start(afterDelay:)`` method when starting your animations.
     */
    public var delay: TimeInterval { animation.delay }
    
    /// The current value of the animation.
    public var value: Value {
        get { animation.value }
      //  set { animation.value = newValue }
    }
    
    /// The velocity of the animation.
    public var velocity: Value {
        get { animation.velocity }
        set { animation.velocity = newValue }
    }
    
    /// The target of the animation.
    public var target: Value {
        get { animation.target }
      //  set { animation.target = newValue }
    }

    /**
     Starts the animation from its current position with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    public func start(afterDelay delay: TimeInterval = 0.0) {
        animation.start(afterDelay: delay)
    }

    /// Pauses the animation at the current position.
    public func pause() {
        animation.pause()
    }
    
    /**
     Stops the animation at the specified position.

     - Parameters:
        - position: The position at which position the animation should stop (``AnimationPosition/current``, ``AnimationPosition/start`` or ``AnimationPosition/end``). The default value is `current`.
        - immediately: A Boolean value that indicates whether the animation should stop immediately at the specified position. The default value is `true`.
     */
    public func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        animation.stop(at: position, immediately: immediately)
    }
    
    init(_ animation: some _AnimationProviding<Value>) {
        self.animation = animation
    }
    
    let animation: any _AnimationProviding<Value>
}

#if os(macOS)
/// A wrapped animation from `CGColor` to `NSColor`.
class ColorPropertyAnimationProviding: PropertyAnimationProviding<Optional<NSColor>> {
    
    public override var id: UUID { cgColorAnimation.id }
    public override var groupID: UUID? { cgColorAnimation.groupID }
    public override var relativePriority: Int {
        get { cgColorAnimation.relativePriority }
        set { cgColorAnimation.relativePriority = newValue }
    }
    public override var state: AnimatingState { cgColorAnimation.state }
    public override var delay: TimeInterval { cgColorAnimation.delay }
    public override var value: NSColor? {
        get { cgColorAnimation.value?.nsUIColor }
      //  set { cgColorAnimation.value = newValue?.cgColor }
    }
    public override var velocity: NSColor? {
        get { cgColorAnimation.velocity?.nsUIColor }
        set { cgColorAnimation.velocity = newValue?.cgColor }
    }
    public override var target: NSColor? {
        get { cgColorAnimation.target?.nsUIColor }
      //  set { cgColorAnimation.target = newValue?.cgColor }
    }
    public override func start(afterDelay delay: TimeInterval = 0.0) {
        cgColorAnimation.start(afterDelay: delay)
    }
    public override func pause() {
        cgColorAnimation.pause()
    }
    public override func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        cgColorAnimation.stop(at: position, immediately: immediately)
    }
    
    init(_ animation: some _AnimationProviding<Optional<CGColor>>) {
        cgColorAnimation = animation
        super.init(EasingAnimation(timingFunction: .linear, duration: 1, value: NSUIColor.zero, target: NSUIColor.zero))
    }
    
    var cgColorAnimation: any _AnimationProviding<Optional<CGColor>>
}
#else
/// A wrapped animation from `CGColor` to `UIColor`.
class ColorPropertyAnimationProviding: PropertyAnimationProviding<Optional<UIColor>> {
    
    public override var id: UUID { cgColorAnimation.id }
    public override var groupID: UUID? { cgColorAnimation.groupID }
    public override var relativePriority: Int {
        get { cgColorAnimation.relativePriority }
        set { cgColorAnimation.relativePriority = newValue }
    }
    public override var state: AnimatingState { cgColorAnimation.state }
    public override var delay: TimeInterval { cgColorAnimation.delay }
    public override var value: UIColor? {
        get { cgColorAnimation.value?.nsUIColor }
      //  set { cgColorAnimation.value = newValue?.cgColor }
    }
    public override var velocity: UIColor? {
        get { cgColorAnimation.velocity?.nsUIColor }
        set { cgColorAnimation.velocity = newValue?.cgColor }
    }
    public override var target: UIColor? {
        get { cgColorAnimation.target?.nsUIColor }
      //  set { cgColorAnimation.target = newValue?.cgColor }
    }
    public override func start(afterDelay delay: TimeInterval = 0.0) {
        cgColorAnimation.start(afterDelay: delay)
    }
    public override func pause() {
        cgColorAnimation.pause()
    }
    public override func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        cgColorAnimation.stop(at: position, immediately: immediately)
    }
    
    init(_ animation: some _AnimationProviding<Optional<CGColor>>) {
        cgColorAnimation = animation
        super.init(EasingAnimation(timingFunction: .linear, duration: 1, value: NSUIColor.zero, target: NSUIColor.zero))
    }
    
    var cgColorAnimation: any _AnimationProviding<Optional<CGColor>>
}
#endif
