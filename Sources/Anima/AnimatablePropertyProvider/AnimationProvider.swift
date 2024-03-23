//
//  Animator.swift
//  
//
//  Created by Florian Zand on 23.03.24.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// An object that provides animations.
public protocol AnimationProvider: AnyObject {
    
    /// The animation provider.
    associatedtype AnimationProvider = Self
    
    /// A dictionary containing the current animated property keys and associated animations.
    var animations: [String: AnimationProviding] { get }
    
    /**
     The current animation for the specified property.

     - Parameter keyPath: The keypath to the property.
     */
    func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<AnimationProvider, Value>) -> AnimationProviding?
    
    /**
     The current animation velocity for the specified property, or `zero` if the property isn't animated.

     - Parameter keyPath: The keypath to the property.
     */
    func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<AnimationProvider, Value>) -> Value
    
    /**
     The current animation value for the specified property, or the value of the property if it isn't animated.

     - Parameter keyPath: The keypath to the property.
     */
    func animationValue<Value: AnimatableProperty>(for keyPath: WritableKeyPath<AnimationProvider, Value>) -> Value
    
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

protocol PropertyAnimatorInternal: AnyObject {
    var lastAccessedPropertyKey: String { get set }
    associatedtype Provider
    var object: Provider { get }
    var animationHandlers: [String: Any] { get set }
    var lastAccessedProperty: AnimationProviding? { get }
    var animations: [String: AnimationProviding] { get set }
}

extension PropertyAnimator: AnimationProvider, PropertyAnimatorInternal { }

public extension AnimationProvider {
    
    func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Self, Value>) -> AnimationProviding? {
        guard let animator = self as? (any PropertyAnimatorInternal) else { return nil }
        animator.lastAccessedPropertyKey = ""
        (animator.object as? NSView)?.layer?.animator.lastAccessedPropertyKey = ""
        _ = self[keyPath: keyPath]
        return (animator.object as? NSView)?.layer?.animator.lastAccessedProperty ?? animator.lastAccessedProperty ?? animator.animations[keyPath.stringValue]
    }
    
    func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Self, Value>) -> Value {
        var velocity: Value?
        Anima.updateVelocity {
            velocity = self[keyPath: keyPath]
        }
        return velocity ?? .zero
    }
    
    func animationValue<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Self, Value>) -> Value {
        var value: Value?
        Anima.updateAnimationValue {
            value = self[keyPath: keyPath]
        }
        return value ?? self[keyPath: keyPath]
    }
    
    func setAnimationHandler<Value: AnimatableProperty>(_ keyPath: WritableKeyPath<Self, Value>, handler: ((_ value: Value,_ velocity: Value, _ isFinished: Bool)->())?) {
        guard let animator = self as? (any PropertyAnimatorInternal) else { return }
        _ = self.animation(for: keyPath)
        if animator.lastAccessedPropertyKey != "" {
            animator.animationHandlers[animator.lastAccessedPropertyKey] = handler
        } else if let animator = (animator.object as? NSUIView)?.optionalLayer?.animator, animator.lastAccessedPropertyKey != "" {
            if let handler = handler, type(of: Value.self) == type(of: Optional<NSUIColor>.self) {
                let newHandler: ((CGColor?,CGColor?, Bool)->()) = { value, velocity, finished in
                    var color: NSUIColor? = nil
                    var velocityColor: NSUIColor? = nil
                    if let value = value as? AnyObject, CFGetTypeID(value) == CGColor.typeID {
                        color = NSUIColor(cgColor: value as! CGColor)
                    }
                    if let velocity = velocity as? AnyObject, CFGetTypeID(velocity) == CGColor.typeID {
                        velocityColor = NSUIColor(cgColor: velocity as! CGColor)
                    }
                    handler(color as! Value, velocityColor as! Value, finished)
                }
                animator.animationHandlers[animator.lastAccessedPropertyKey] = newHandler
            } else {
                animator.animationHandlers[animator.lastAccessedPropertyKey] = handler
            }
        }
    }
}
