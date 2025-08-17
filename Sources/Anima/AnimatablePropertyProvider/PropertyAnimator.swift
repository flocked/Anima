//
//  PropertyAnimator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

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

 ### Accessing Animation value and velocity
 
 The animation returned via ``subscript(animation:)`` provides the current animation value and velocity.

 ```swift
 if let speedAnimation = car.animator[animation: \.speed] {
    speedAnimation.velocity = 120
 }
 ```
 */
open class PropertyAnimator<Provider: AnimatablePropertyProvider>: NSObject {
    weak var object: Provider!
    
    var propertyObservers: [ObjectIdentifier: KeyValueObserver] = [:]
    var propertyObserverKeyPaths: [PartialKeyPath<Provider>: (id: ObjectIdentifier, keyPath: String)] = [:]
    
    var _object: Provider? {
        object
    }

    init(_ object: Provider) {
        self.object = object
    }
    
    /// A dictionary containing the current animated property keys and associated animations.
    open internal(set) var animations: [String: BaseAnimation] = [:]

    /**
     The current value of the property at the specified keypath.

     Assigning a new value inside a ``Anima`` animation block animates to the new value. Changing the value outside an animation block, stops it's animation and updates the value imminently.

     - Parameter keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(keyPath: ReferenceWritableKeyPath<Provider, Value>) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }

    /**
     The current animation of the property at the specified keypath, or `nil` if the property isn't animated.

     - Parameter keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(animation keyPath: WritableKeyPath<Provider, Value>) -> ValueAnimation<Value>? {
        animation(for: keyPath, checkLayer: true)
    }

    var animationHandlers: [String: Any] = [:]
    var lastAccessedProperty: String = ""
    var lastAccessedAnimation: BaseAnimation? {
        guard lastAccessedProperty != "" else { return nil }
        return animations[lastAccessedProperty]
    }
        
    deinit {
        animations.values.forEach({AnimationController.shared.stopAnimation($0)})
    }
}

extension PropertyAnimator {
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation's target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Provider, Value>) -> Value {
        if AnimationController.shared.currentAnimationConfiguration?.options.contains(.trackValues) == true, let keyPathString = keyPath.kvcStringValue, let object = object as? (any NSObject & AnimatablePropertyProvider) {
            AnimationController.shared.lastAccess = (object, keyPathString)
        }
        if let configurationType = Anima.currentConfiguration?.type {
            if configurationType == .animationVelocity || configurationType == .decayVelocity {
                return animation(for: keyPath)?.velocity ?? .zero
            } else if configurationType == .animationValue {
                return animation(for: keyPath)?.value ?? .zero
            }
        }
        return animation(for: keyPath)?.target ?? object[keyPath: keyPath]
    }

    /// Animates the value of the property at the keypath to a new value.
    func setValue<Value: AnimatableProperty>(_ newValue: Value, for keyPath: ReferenceWritableKeyPath<Provider, Value>, completion: (() -> Void)? = nil) {
        stopPropertyObservation(of: keyPath)
        guard let object = object else { return }
        let currentAnimation = animation(for: keyPath)
        guard let configuration = Anima.currentConfiguration, configuration.type != .nonAnimated else {
            currentAnimation?.stopAtCurrent()
            DisableActions {
                object[keyPath: keyPath] = newValue
            }
            return
        }
        
        guard value(for: keyPath) != newValue || configuration.type.animation != currentAnimation?.animationType else {
            return
        }

        var value = object[keyPath: keyPath]
        var target = newValue
        updateValue(&value, target: &target)
        AnimationController.shared.executeGroupHandler(uuid: currentAnimation?.groupID, state: .retargeted)
        switch configuration.type {
        case .spring:
            let animation = springAnimation(for: keyPath) ?? SpringAnimation(spring: .smooth, value: value, target: target)
            if currentAnimation?.id != animation.id, let velocity = currentAnimation?._velocity as? Value.AnimatableData {
                animation._startVelocity = velocity
                animation._velocity = velocity
            }
            configurateAnimation(animation, target: target, keyPath: keyPath, configuration: configuration, completion: completion)
            setupPropertyObservation(of: keyPath)
        case .easing:
            let animation = easingAnimation(for: keyPath) ?? EasingAnimation(timingFunction: .linear, duration: 1.0, value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, configuration: configuration, completion: completion)
        case .decay, .decayVelocity:
            let animation = decayAnimation(for: keyPath) ?? DecayAnimation(value: value, target: target)
            configurateAnimation(animation, target: target, keyPath: keyPath, configuration: configuration, completion: completion)
        case .cubic:
            let animation = cubicAnimation(for: keyPath) ?? CubicAnimation(duration: 1.0, value: value, target: target)
            /*
            if currentAnimation?.id != animation.id, let velocity = currentAnimation?._velocity as? Value.AnimatableData {
                animation._startVelocity = velocity
                animation._velocity = velocity
            }
             */
            configurateAnimation(animation, target: target, keyPath: keyPath, configuration: configuration, completion: completion)
        case .animationVelocity:
            animation(for: keyPath)?.velocity = newValue
        case .animationValue:
            animation(for: keyPath)?.value = newValue
        case .nonAnimated:
            break
        }
    }
    
    /// Configurates an animation and starts it.
    func configurateAnimation<Value>(_ animation: ValueAnimation<Value>, target: Value, keyPath: ReferenceWritableKeyPath<Provider, Value>, configuration: Anima.AnimationConfiguration, completion: (() -> Void)? = nil) {
        
        animation.reset()

        if configuration.type == .decayVelocity, let animation = animation as? DecayAnimation<Value> {
            animation.velocity = target
            animation._startVelocity = animation._velocity
        } else {
            animation.target = target
        }

        animation.configure(with: configuration)
        AnimationController.shared.addAnimationCount(uuid: animation.groupID)
        
        let animationKey = keyPath.stringValue
                
        var animationHandler: ((Value,Value, Bool)->())? {
            animationHandlers[animationKey] as? ((Value,Value, Bool)->())
        }
 
        animation.valueChanged = { [weak self] value in
            guard let self = self, let object = self.object else {
                AnimationController.shared.stopAnimation(animation)
                return
            }
            object[keyPath: keyPath] = value
            animationHandler?(value, animation.velocity, false)
        }

        if let view = object as? NSUIView {
            if configuration.options.preventUserInteraction {
                view.preventingUserInteractionAnimations.insert(animation.id)
            } else {
                view.preventingUserInteractionAnimations.remove(animation.id)
            }
        }
        animation.completion = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .finished:
                #if os(macOS) || os(iOS) || os(tvOS)
                if let layer = self.object as? CALayer {
                    layer.removeFromSuperlayerIfNeeded()
                    layer.parentView?.removeFromSuperviewIfNeeded()
                }
                #endif                
                completion?()
                self.stopPropertyObservation(of: keyPath)
                self.animations[animationKey] = nil
                animationHandler?(animation.value, animation.velocity, true)
                (self.object as? NSUIView)?.preventingUserInteractionAnimations.remove(animation.id)
                AnimationController.shared.executeGroupHandler(uuid: animation.groupID, state: .finished)
            default:
                break
            }
        }

        if let oldAnimation = animations[animationKey], oldAnimation.id != animation.id {
            oldAnimation.stop()
        }
        animations[animationKey] = animation
        animation.start(afterDelay: configuration.delay)
    }
    
    func setupPropertyObservation<Value: AnimatableProperty>(of keyPath: ReferenceWritableKeyPath<Provider, Value>) {
        guard let lastAccess = AnimationController.shared.lastAccess else { return }
        propertyObservers[ObjectIdentifier(lastAccess.provider), default: KeyValueObserver(lastAccess.provider)].add(lastAccess.keyPath, type: Value.self) { [weak self] oldValue, newValue in
            guard let self = self, let animation = self.animation(for: keyPath), animation.state == .running else { return }
            animation.target = newValue
        }
        propertyObserverKeyPaths[keyPath] = (ObjectIdentifier(lastAccess.provider), lastAccess.keyPath)
        AnimationController.shared.lastAccess = nil
    }
    
    func stopPropertyObservation(of keyPath: PartialKeyPath<Provider>) {
        guard let tracking = propertyObserverKeyPaths[keyPath], let observer = propertyObservers[tracking.id] else { return }
        observer.remove(tracking.keyPath)
        guard !observer.isObserving() else { return }
        propertyObservers[tracking.id] = nil
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
    public func velocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Provider, Value>) -> Value? {
        animation(for: keyPath)?.velocity
    }
    
    /// The current animation for the specified property, or `nil` if there isn't an animation for the keypath.
    func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Provider, Value>, checkLayer: Bool = false) -> ValueAnimation<Value>? {
        animation(for: keyPath.stringValue, checkLayer: checkLayer) as? ValueAnimation<Value>
    }

    func animation(for keyPath: String, checkLayer: Bool = false) -> BaseAnimation? {
        lastAccessedProperty = keyPath
        if let animation = animations[lastAccessedProperty] {
            return animation
        }
        guard checkLayer else { return nil }
        return (object as? NSUIView)?.optionalLayer?.animator.animation(for: keyPath)
    }

    /// The current decay animation for the property at the keypath, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Value>(for keyPath: WritableKeyPath<Provider, Value>) -> DecayAnimation<Value>? {
        animation(for: keyPath) as? DecayAnimation<Value>
    }

    /// The current easing animation for the property at the keypath, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Value>(for keyPath: WritableKeyPath<Provider, Value>) -> EasingAnimation<Value>? {
        animation(for: keyPath) as? EasingAnimation<Value>
    }

    /// The current spring animation for the property at the keypath, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Value>(for keyPath: WritableKeyPath<Provider, Value>) -> SpringAnimation<Value>? {
        animation(for: keyPath) as? SpringAnimation<Value>
    }
    
    /// The current cubic animation for the property at the keypath, or `nil` if there isn't a spring animation for the keypath.
    func cubicAnimation<Value>(for keyPath: WritableKeyPath<Provider, Value>) -> CubicAnimation<Value>? {
        animation(for: keyPath) as? CubicAnimation<Value>
    }
}
