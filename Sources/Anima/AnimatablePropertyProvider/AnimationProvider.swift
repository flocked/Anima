//
//  AnimationProvider.swift
//  
//
//  Created by Florian Zand on 23.03.24.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// Provides animations.
public protocol AnimationProvider: AnyObject {
    
    /// The animation provider.
    associatedtype AnimationProvider = Self
    
    /// A dictionary containing the currently animated property names and associated animations.
    var animations: [String: AnimationProviding] { get }
    
    /**
     The current animation for the specified property.

     - Parameter keyPath: The keypath to the property.
     */
    func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<AnimationProvider, Value>) -> PropertyAnimationProviding<Value>?

    /**
     Sets the handler that gets called when the specified property is animated and it's value changed.

     - Parameters:
        - keyPath: The keypath to the property.
        - handler: The handler that gets called when the property is animated and it's value changed:
            - value: The current value of the property.
            - velocity: The current velocity of the animation.
            - isFInished: A Boolean value indicating whether the animation is finished.
     */
    func setAnimationHandler<Value: AnimatableProperty>(_ keyPath: WritableKeyPath<AnimationProvider, Value>, handler: ((_ value: Value,_ velocity: Value, _ isFinished: Bool)->())?)
}

extension PropertyAnimator: AnimationProvider { }

extension AnimationProvider {
    public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Self, Value>) -> PropertyAnimationProviding<Value>? {
        guard let animation = _animation(for: keyPath) else { return nil }
        if let animation: any _AnimationProviding<Value> = animation._animation() {
            return animation.propertyAnimation
        } else if type(of: Value.self) == type(of: Optional<NSUIColor>.self), let animation: any _AnimationProviding<Optional<CGColor>> = animation._animation() {
            return ColorPropertyAnimationProviding(animation) as? PropertyAnimationProviding<Value>
        }
        return nil
    }
    
    func _animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Self, Value>) -> AnimationProviding? {
        guard let animator = self as? (any _PropertyAnimator) else { return nil }
        animator.lastAccessedProperty = ""
        animator.layerAnimator?.lastAccessedProperty = ""
        _ = self[keyPath: keyPath]
        return animator.layerAnimator?.lastAccessedAnimation ?? animator.lastAccessedAnimation ?? animator.animations[keyPath.stringValue]
    }
    
    public func setAnimationHandler<Value: AnimatableProperty>(_ keyPath: WritableKeyPath<Self, Value>, handler: ((_ value: Value,_ velocity: Value, _ isFinished: Bool)->())?) {
        guard let animator = self as? (any _PropertyAnimator) else { return }
        _ = self.animation(for: keyPath)
        if animator.lastAccessedProperty != "" {
            animator.animationHandlers[animator.lastAccessedProperty] = handler
        } else if let animator = animator.layerAnimator, animator.lastAccessedProperty != "" {
            if let handler = handler, type(of: Value.self) == type(of: Optional<NSUIColor>.self) {
                animator.animationHandlers[animator.lastAccessedProperty] = { (value: CGColor?, velocity: CGColor?, finished: Bool) in
                    handler(value?.nsUIColor as! Value, velocity?.nsUIColor as! Value, finished) }
            } else {
                animator.animationHandlers[animator.lastAccessedProperty] = handler
            }
        }
    }
}

/// An internal protocol for `PropertyAnimator` used for accessing animations by keypath.
protocol _PropertyAnimator: AnyObject {
    associatedtype Provider
    var _object: Provider? { get }
    var animations: [String: AnimationProviding] { get }
    var lastAccessedProperty: String { get set }
    var lastAccessedAnimation: AnimationProviding? { get }
    var animationHandlers: [String: Any] { get set }
}

extension PropertyAnimator: _PropertyAnimator { }

extension _PropertyAnimator {
    var layerAnimator: (any _PropertyAnimator)? {
        (_object as? NSUIView)?.optionalLayer?.animator
    }
}


