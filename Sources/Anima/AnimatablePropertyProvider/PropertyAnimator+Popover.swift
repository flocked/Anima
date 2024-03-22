//
//  PropertyAnimator+Popover.swift
//  
//
//  Created by Florian Zand on 03.02.24.
//

#if os(macOS)

import AppKit

extension NSPopover: AnimatablePropertyProvider {
    /**
     Provides the animatable content size.

     To animate the property change it's value inside an ``Anima`` animation block, To stop its animation and to change the value imminently, update it outside an animation block.
     */
    public var animator: PopoverAnimator { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: PopoverAnimator(self)) }
}

/**
 Provides the animatable content size.

 To animate the `contentSize` of a popover, change it's value inside an ``Anima`` animation block:

 ```swift
 Anima.animate(withSpring: .smooth) {
    popover.animator.contentSize = CGSize(width: 200, height: 200)
 }
 ```
 To stop the animation and to change the constant immediately, change it's value outside an animation block:

 ```swift
 popover.animator.contentSize = CGSize(width: 100, height: 100)
 ```

 ### Accessing Animation

 To access the animation for `contentSize`, use ``animation(for:)``:

 ```swift
 if let animation = popover.animator.animation(for: \.contentSize) {
    animation.stop()
 }
 ```

 ### Accessing Animation Velocity

 To access the animation velocity for `contentSize`, use ``animationVelocity(for:)``.

 ```swift
 if let velocity = popover.animator.animation(for: \.contentSize) {

 }
 ```
 */
public class PopoverAnimator: PropertyAnimator<NSPopover> {
    /// The content size of the popover.
    public var contentSize: CGSize {
        get { self[\.contentSize] }
        set { self[\.contentSize] = newValue }
    }
}

public extension PopoverAnimator {
    /**
     The current animation for the property at the specified keypath, or `nil` if the property isn't animated.

     - Parameter keyPath: The keypath to an animatable property.
     */
    func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PopoverAnimator, Value>) -> AnimationProviding? {
        lastAccessedPropertyKey = ""
        _ = self[keyPath: keyPath]
        return animations[lastAccessedPropertyKey != "" ? lastAccessedPropertyKey : keyPath.stringValue]
    }

    /**
     The current animation velocity for the property at the specified keypath, or `nil` if the property isn't animated or doesn't support velocity values.

     - Parameter keyPath: The keypath to an animatable property.
     */
    func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PopoverAnimator, Value>) -> Value? {
        var velocity: Value?
        Anima.updateVelocity {
            velocity = self[keyPath: keyPath]
        }
        return velocity
    }
    
    /**
     The current animation value for the specified property, or the value of the property if it isn't animated.

     - Parameter keyPath: The keypath to an animatable property.
     */
    func animationValue<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PopoverAnimator, Value>) -> Value {
        (animation(for: keyPath) as? (any ConfigurableAnimationProviding))?.value as? Value ?? self[keyPath: keyPath]
    }
}


#endif
