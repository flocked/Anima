//
//  PropertyAnimator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

import Foundation
import QuartzCore
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/**
 Provides animatable properties of an object conforming to ``AnimatablePropertyProvider``.
 
 For easier access of a animatable property, you can extend the object's PropertyAnimator.
 
 ```swift
 class Car: AnimatablePropertyProvider {
    var speed: CGFloat = 0.0
    var location: CGPoint = .zero
 }
  
 public extension PropertyAnimator<Car> {
    var speed: CGFloat {
        get { self[\.value] }
        set { self[\.value] = newValue }
    }
 
    var location: CGPoint {
        get { self[\.point] }
        set { self[\.point] = newValue }
    }
 }
 
 let car = Car()
 
 Anima.animate(withSpring: .smooth) {
    car.animator.speed = 120.0
    car.animator.point = CGPoint(x: 100.0, y: 100.0)
 }
 ```
 */
public class PropertyAnimator<Provider: AnimatablePropertyProvider> {
    internal var object: Provider
    
    internal init(_ object: Provider) {
        self.object = object
    }
    /// A dictionary containing the current animated property keys and associated animations.
    public var animations: [String: AnimationProviding] = [:]
    
    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Anima`` animation block animates to the new value.
     
     - Parameters keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Provider, Value>) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }
    
    /**
     The current animation velocity of the property at the specified keypath, or `zero` if there isn't an animation for the property or the animation doesn't support velocity values.

     - Parameters velocity: The keypath to the animatable property for the velocity.
     */
    public subscript<Value: AnimatableProperty>(velocity velocity: WritableKeyPath<Provider, Value>) -> Value {
        get { ((self.animation(for: velocity)?.velocity as? Value)) ?? .zero  }
        set { self.animation(for: velocity)?.setVelocity(newValue) }
    }
    
    /**
     The current animation for the property at the specified keypath.
     
     - Parameters keyPath: The keypath to an animatable property.
     */
    public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PropertyAnimator, Value>) -> AnimationProviding? {
        var key = keyPath.stringValue
        if key.contains("layer."), let viewAnimator = self as? PropertyAnimator<NSUIView> {
            key = key.replacingOccurrences(of: "layer.", with: "")
            return viewAnimator.object.optionalLayer?.animator.animations[key]
        } else {
            return self.animations[key]
        }
    }
    
    /**
     The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
     
     - Parameters keyPath: The keypath to an animatable property.
     */
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PropertyAnimator, Value>) -> Value? {
        return (self.animation(for: keyPath) as? any ConfigurableAnimationProviding)?.velocity as? Value
    }
}

internal extension PropertyAnimator {
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Provider, Value>) -> Value {
        if AnimationController.shared.currentAnimationParameters?.animationType.isAnyVelocity == true {
            return (self.animation(for: keyPath)?.velocity as? Value) ?? .zero
        }
        return (self.animation(for: keyPath)?.target as? Value) ?? object[keyPath: keyPath]
    }
    
    /// Animates the value of the property at the keypath to a new value.
    func setValue<Value: AnimatableProperty>(_ newValue: Value, for keyPath: WritableKeyPath<Provider, Value>, completion: (()->())? = nil) {
        guard let settings = AnimationController.shared.currentAnimationParameters, settings.isAnimation else {
            self.animation(for: keyPath)?.stop(at: .current, immediately: true)
            self.object[keyPath: keyPath] = newValue
            return
        }
        
        guard value(for: keyPath) != newValue else {
            return
        }
        
        var value = object[keyPath: keyPath]
        var target = newValue
        updateValue(&value, target: &target)

        AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupID, finished: false, retargeted: true)
        switch settings.animationType {
        case .spring(_,_):
            let animation = springAnimation(for: keyPath) ?? SpringAnimation(spring: .smooth, value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .easing(_,_):
            let animation = easingAnimation(for: keyPath) ?? EasingAnimation(timingFunction: .linear, duration: 1.0, value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .decay(_,_):
            let animation = decayAnimation(for: keyPath) ?? DecayAnimation(value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .velocityUpdate:
            animation(for: keyPath)?.setVelocity(target)
        case .nonAnimated:
            break
        }  
    }
    
    /// Configurates an animation and starts it.
    func configurateAnimation<Value>(_ animation: some ConfigurableAnimationProviding<Value>, target: Value, keyPath: WritableKeyPath<Provider, Value>, settings: AnimationController.AnimationParameters, completion: (()->())? = nil) {
        
        var animation = animation
        animation.reset()
        
        if settings.animationType.isDecayVelocity, let animation = animation as? DecayAnimation<Value> {
            animation.velocity = target
            animation._fromVelocity = animation._velocity
        } else {
            animation.target = target
        }

        animation.fromValue = animation.value
        animation.configure(withSettings: settings)
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
        }
        
        #if os(iOS) || os(tvOS)
        if settings.preventUserInteraction {
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.insert(animation.id)
        } else {
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
        }
        #endif
        
        let animationKey = keyPath.stringValue
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                completion?()
                self?.animations[animationKey] = nil
                #if os(iOS) || os(tvOS)
                (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
                #endif
                AnimationController.shared.executeHandler(uuid: animation.groupID, finished: true, retargeted: false)
            default:
                break
            }
        }
        
        if let oldAnimation = animations[animationKey], oldAnimation.id != animation.id {
            if settings.options.contains(.keepVelocity), let velocity = self.animation(for: keyPath)?._velocity as? Value.AnimatableData, velocity != .zero {
                animation.setAnimatableVelocity(velocity)
            }
            oldAnimation.stop(at: .current, immediately: true)
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    /// Updates the current  and target of an animatable property for better interpolation/animations.
    func updateValue<V: AnimatableProperty>(_ value: inout V, target: inout V) {
        if V.self == CGColor.self {
            let color = value as! CGColor
            let targetColor = target as! CGColor
            if color.alpha == 0.0 {
                value = (targetColor.copy(alpha: 0.0) ?? .clear) as! V
            }
            if targetColor.alpha == 0.0 {
                target = (color.copy(alpha: 0.0) ?? .clear) as! V
            }
        } else if var collection = value as? any AnimatableCollection, var targetCollection = target as? any AnimatableCollection, collection.count != targetCollection.count {
            collection.makeAnimatable(to: &targetCollection)
            value = collection as! V
            target = targetCollection as! V
        }
    }
}

internal extension PropertyAnimator {
    /// The current animation for the property at the keypath or key, or `nil` if there isn't an animation for the keypath.
    func animation(for keyPath: PartialKeyPath<Provider>) -> (any ConfigurableAnimationProviding)? {
        return animations[keyPath.stringValue] as? any ConfigurableAnimationProviding
    }
    
    /// The current decay animation for the property at the keypath or key, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Val>(for keyPath: PartialKeyPath<Provider>) -> DecayAnimation<Val>? {
        return self.animation(for: keyPath) as? DecayAnimation<Val>
    }
    
    /// The current easing animation for the property at the keypath or key, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Val>(for keyPath: PartialKeyPath<Provider>) -> EasingAnimation<Val>? {
        return self.animation(for: keyPath) as? EasingAnimation<Val>
    }
    
    /// The current spring animation for the property at the keypath or key, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Val>(for keyPath: PartialKeyPath<Provider>) -> SpringAnimation<Val>? {
        return self.animation(for: keyPath) as? SpringAnimation<Val>
    }
}
