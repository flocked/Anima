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
 Provides animatable properties and animations of an object conforming to ``AnimatablePropertyProvider``.

 ### Accessing Properties

 To access the animatable properties, use their keypath on the objects ``AnimatablePropertyProvider/animator-94wn0``:

 To animate them, change their values inside an  an ``Anima`` animation block. To stop their animations and to update them immediately, change their values outside an animation block.

 ```swift
 class Car: AnimatablePropertyProvider {
    var speed: CGFloat = 0.0
    var location: CGPoint = .zero
 }

 let car = Car()

 Anima.animate(withSpring: .smooth) {
    car.animator[\.speed] = 120.0
    car.animator[\.location].x = 200.0
 }
 ```

 For easier access of the properties, you can extend the animator.

 ```swift
 public extension PropertyAnimator<Car> {
    var speed: CGFloat {
        get { self[\.speed] }
        set { self[\.speed] = newValue }
    }

    var location: CGPoint {
        get { self[\.location] }
        set { self[\.location] = newValue }
    }
 }

 Anima.animate(withSpring: .smooth) {
    car.animator.speed = 120.0
    car.animator.location.x = 200.0
 }
 ```

 ### Accessing Animations

 ``animations`` is a dictionary of all running animations keyed by property names.

 To access the animation for a specific property, use it's keypath on the `animator` using ``subscript(animation:)``:

 ```swift
 if let speedAnimation = car.animator[animation: \.speed] {
    speedAnimation.stop()
 }
 ```

 ### Accessing Animation velocity

 To access or change the animation velocity of a property that is currently animated,  use it's keypath on the `animator` using ``subscript(velocity:)``:

 ```swift
 car.animator[velocity: \.speed] = 120.0
 ```
 */
open class PropertyAnimator<Provider: AnimatablePropertyProvider> {
    var object: Provider

    init(_ object: Provider) {
        self.object = object
    }

    /// A dictionary containing the current animated property keys and associated animations.
    public internal(set) var animations: [String: AnimationProviding] = [:]

    /**
     The current value of the property at the specified keypath.

     Assigning a new value inside a ``Anima`` animation block animates to the new value. Changing the value outside an animation block, stops it's animation and updates the value imminently.

     - Parameter keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Provider, Value>) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }

    /**
     The current animation of the property at the specified keypath, or `nil` if the property isn't animated.

     - Parameter keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(animation keyPath: WritableKeyPath<Provider, Value>) -> AnimationProviding? {
        animation(for: keyPath, checkLayer: true)
    }

    /**
     The current animation velocity of the property at the specified keypath, or `zero` if the property isn't animated or the animation doesn't support velocity values.

     - Parameter keyPath: The keypath to the animatable property for the velocity.
     */
    public subscript<Value: AnimatableProperty>(velocity keyPath: WritableKeyPath<Provider, Value>) -> Value {
        get { animation(for: keyPath, checkLayer: true)?.velocity as? Value ?? .zero }
        set { animation(for: keyPath, checkLayer: true)?.setVelocity(newValue) }
    }
    
    /**
     The current value of the animation for the specified property, or the property's value if it isn't animatin.
     
     - Parameter keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(value keyPath: WritableKeyPath<Provider, Value>) -> Value {
        animation(for: keyPath, checkLayer: true)?.value as? Value ?? object[keyPath: keyPath]
    }

    var lastAccessedPropertyKey: String = ""
    var lastAccessedProperty: AnimationProviding? {
        guard lastAccessedPropertyKey != "" else { return nil }
        return animations[lastAccessedPropertyKey]
    }
    var animationHandlers: [String: Any] = [:]
}

extension PropertyAnimator {
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation's target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Provider, Value>) -> Value {
        if let configuration = AnimationController.shared.currentAnimationParameters?.configuration {
            if configuration.isAnyVelocity {
                return animation(for: keyPath)?.velocity as? Value ?? .zero
            } else if configuration.isAnimationValue {
                return animation(for: keyPath)?.value as? Value ?? .zero
            }
        }
        return animation(for: keyPath)?.target as? Value ?? object[keyPath: keyPath]
    }

    /// Animates the value of the property at the keypath to a new value.
    func setValue<Value: AnimatableProperty>(_ newValue: Value, for keyPath: WritableKeyPath<Provider, Value>, completion: (() -> Void)? = nil) {
        guard let settings = AnimationController.shared.currentAnimationParameters, settings.isAnimation else {
            animation(for: keyPath)?.stop(at: .current, immediately: true)
            object[keyPath: keyPath] = newValue
            return
        }

        if value(for: keyPath) == newValue {
            if let animationType = settings.animationType {
                guard animationType != animation(for: keyPath)?.animationType else {
                    return
                }
            } else {
                return
            }
        }

        var value = object[keyPath: keyPath]
        var target = newValue
        updateValue(&value, target: &target)

        AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupID, finished: false, retargeted: true)
        switch settings.configuration {
        case .spring:
            let animation = springAnimation(for: keyPath) ?? SpringAnimation(spring: .smooth, value: value, target: target)
            if let oldAnimation = self.animation(for: keyPath), oldAnimation.id != animation.id, let velocity = oldAnimation._velocity as? Value.AnimatableData {
                animation._velocity = velocity
            }
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .easing:
            let animation = easingAnimation(for: keyPath) ?? EasingAnimation(timingFunction: .linear, duration: 1.0, value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .decay:
            let animation = decayAnimation(for: keyPath) ?? DecayAnimation(value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, settings: settings, completion: completion)
        case .velocityUpdate:
            animation(for: keyPath)?.setVelocity(newValue)
        case .animationValueUpdate:
            break
        case .nonAnimated:
            break
        }
    }

    /// Configurates an animation and starts it.
    func configurateAnimation<Value>(_ animation: some ConfigurableAnimationProviding<Value>, target: Value, keyPath: WritableKeyPath<Provider, Value>, settings: AnimationController.AnimationParameters, completion: (() -> Void)? = nil) {
        var animation = animation
        animation.reset()

        if settings.configuration.isDecayVelocity, let animation = animation as? DecayAnimation<Value> {
            animation.velocity = target
            animation._startVelocity = animation._velocity
        } else {
            animation.target = target
        }

        animation.startValue = animation.value
        animation.configure(withSettings: settings)
        let animationKey = keyPath.stringValue

        var handler: ((Value,Value, Bool)->())? {
            if let handler: ((Value,Value, Bool)->()) = animationHandler(for: animationKey) {
                return handler
            }
            return nil
        }
        
        if Provider.self is CALayer.Type {
            animation.valueChanged = { [weak self] value in
                guard let self = self else { return }
                DisableActions {
                    self.object[keyPath: keyPath] = value
                    handler?(value,animation.velocity, false)
                }
            }
        } else {
            animation.valueChanged = { [weak self] value in
                guard let self = self else { return }
                self.object[keyPath: keyPath] = value
                handler?(value, animation.velocity, false)
            }
        }

        #if os(iOS) || os(tvOS)
            if let self = self as? PropertyAnimator<UIView> {
                if settings.preventUserInteraction {
                    self.preventingUserInteractionAnimations.insert(animation.id)
                } else {
                    self.preventingUserInteractionAnimations.remove(animation.id)
                }
            }
        #endif
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                completion?()
                self?.animations[animationKey] = nil
                handler?(animation.value, .zero, true)
                #if os(iOS) || os(tvOS)
                    (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
                #endif
                AnimationController.shared.executeHandler(uuid: animation.groupID, finished: true, retargeted: false)
            default:
                break
            }
        }

        if let oldAnimation = animations[animationKey], oldAnimation.id != animation.id {
            oldAnimation.stop(at: .current, immediately: true)
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }

    /// Updates the current value and target of an animatable property for better interpolation/animations.
    func updateValue<V>(_ value: inout V, target: inout V) where V: AnimatableProperty {
        if let color = value as? any AnimatableColor, let targetColor = target.animatableData as? any AnimatableColor {
            value = color.animatable(to: targetColor) as! V
            target = targetColor.animatable(to: color) as! V
        } else if let collection = value.animatableData as? any AnimatableCollection, let targetCollection = target.animatableData as? any AnimatableCollection, collection.count != targetCollection.count {
            value = V(collection.animatable(to: targetCollection) as! V.AnimatableData)
            target = V(targetCollection.animatable(to: collection) as! V.AnimatableData)
        } else if let configuration = value as? any AnimatableConfiguration, let targetConfiguration = target as? AnimatableConfiguration {
            value = configuration.animatable(to: targetConfiguration) as! V
            target = targetConfiguration.animatable(to: configuration) as! V
        }
    }
}

extension PropertyAnimator {
    /// The current animation for the specified property, or `nil` if there isn't an animation for the keypath.
    func animation(for keyPath: PartialKeyPath<Provider>, checkLayer: Bool = false) -> (any ConfigurableAnimationProviding)? {
        animation(for: keyPath.stringValue, checkLayer: checkLayer)
    }

    func animation(for keyPath: String, checkLayer: Bool = false) -> (any ConfigurableAnimationProviding)? {
        lastAccessedPropertyKey = keyPath
        if let animation = animations[lastAccessedPropertyKey] as? any ConfigurableAnimationProviding {
            return animation
        }
        guard checkLayer else { return nil }
        #if os(macOS)
        return (object as? NSView)?.layer?.animator.animation(for: keyPath)
        #elseif canImport(UIKit)
        return (object as? UIView)?.layer.animator.animation(for: keyPath)
        #endif
    }

    /// The current decay animation for the property at the keypath, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Value>(for keyPath: PartialKeyPath<Provider>) -> DecayAnimation<Value>? {
        animation(for: keyPath) as? DecayAnimation<Value>
    }

    /// The current easing animation for the property at the keypath, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Value>(for keyPath: PartialKeyPath<Provider>) -> EasingAnimation<Value>? {
        animation(for: keyPath) as? EasingAnimation<Value>
    }

    /// The current spring animation for the property at the keypath, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Value>(for keyPath: PartialKeyPath<Provider>) -> SpringAnimation<Value>? {
        animation(for: keyPath) as? SpringAnimation<Value>
    }
    
    func animationHandler<Value: AnimatableProperty>(for keyPath: String) -> ((Value, Value, Bool)->())? {
        if let handler = animationHandlers[keyPath] as? ((Value, Value, Bool)->()) {
            return handler
        }
        if let viewAnimator = (object as? CALayer)?.parentView?.animator {
            return viewAnimator.animationHandler(for: keyPath)
        }
        return nil
    }
}
