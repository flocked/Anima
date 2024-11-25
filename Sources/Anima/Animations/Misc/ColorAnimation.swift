//
//  PropertyBaseAnimation.swift
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

#if os(macOS)
/// A wrapped animation from `CGColor` to `NSColor`.
class ColorAnimation: ValueAnimation<Optional<NSColor>> {
    public override var id: UUID { cgColorAnimation.id }
    public override var groupID: UUID? {
        get { cgColorAnimation.groupID }
        set { cgColorAnimation.groupID = newValue }
    }
    public override var relativePriority: Int {
        get { cgColorAnimation.relativePriority }
        set { cgColorAnimation.relativePriority = newValue }
    }
    public override var state: State {
        get { cgColorAnimation.state }
        set { cgColorAnimation.state = newValue }
    }
    public override var delay: TimeInterval { 
        get { cgColorAnimation.delay }
        set { cgColorAnimation.delay = newValue }
    }
    public override var value: NSColor? {
        get { cgColorAnimation.value?.nsUIColor }
        set { cgColorAnimation.value = newValue?.cgColor }
    }
    public override var velocity: NSColor? {
        get { cgColorAnimation.velocity?.nsUIColor }
        set { cgColorAnimation.velocity = newValue?.cgColor }
    }
    public override var target: NSColor? {
        get { cgColorAnimation.target?.nsUIColor }
        set { cgColorAnimation.target = newValue?.cgColor }
    }
    public override func start(afterDelay delay: TimeInterval = 0.0) {
        cgColorAnimation.start(afterDelay: delay)
    }
    public override func pause() {
        cgColorAnimation.pause()
    }
    public override func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        cgColorAnimation.stop(at: .init(rawValue: position.rawValue)!, immediately: immediately)
    }
    
    init(_ animation: ValueAnimation<Optional<CGColor>>) {
        super.init(value: .white, target: .white)
        cgColorAnimation = animation
    }
    
    var cgColorAnimation: ValueAnimation<Optional<CGColor>>!
}
#else
/// A wrapped animation from `CGColor` to `UIColor`.
class ColorAnimation: ValueAnimation<Optional<UIColor>> {
    public override var id: UUID { cgColorAnimation.id }
    public override var groupID: UUID? {
        get { cgColorAnimation.groupID }
        set { cgColorAnimation.groupID = newValue }
    }
    public override var relativePriority: Int {
        get { cgColorAnimation.relativePriority }
        set { cgColorAnimation.relativePriority = newValue }
    }
    public override var state: State {
        get { cgColorAnimation.state }
        set { cgColorAnimation.state = newValue }
    }
    public override var delay: TimeInterval {
        get { cgColorAnimation.delay }
        set { cgColorAnimation.delay = newValue }
    }
    public override var value: UIColor? {
        get { cgColorAnimation.value?.nsUIColor }
        set { cgColorAnimation.value = newValue?.cgColor }
    }
    public override var velocity: UIColor? {
        get { cgColorAnimation.velocity?.nsUIColor }
        set { cgColorAnimation.velocity = newValue?.cgColor }
    }
    public override var target: UIColor? {
        get { cgColorAnimation.target?.nsUIColor }
        set { cgColorAnimation.target = newValue?.cgColor }
    }
    public override func start(afterDelay delay: TimeInterval = 0.0) {
        cgColorAnimation.start(afterDelay: delay)
    }
    public override func pause() {
        cgColorAnimation.pause()
    }
    public override func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        cgColorAnimation.stop(at: .init(rawValue: position.rawValue)!, immediately: immediately)
    }
    
    init(_ animation: ValueAnimation<Optional<CGColor>>) {
        super.init(value: .white, target: .white)
        cgColorAnimation = animation
    }
    
    var cgColorAnimation: ValueAnimation<Optional<CGColor>>!
}
#endif
