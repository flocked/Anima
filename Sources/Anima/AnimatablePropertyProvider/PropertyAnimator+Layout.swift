//
//  PropertyAnimator+LayoutConstraint.swift
//
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSLayoutConstraint: AnimatablePropertyProvider {
    /// Provides animatable properties of the layout constraint.
    public var animator: LayoutAnimator {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: LayoutAnimator(self)) }
    }
}

/// Provides animatable properties of a layout constraint.
public class LayoutAnimator: PropertyAnimator<NSLayoutConstraint> {
    /// The constant of the layout constraint.
    public var constant: CGFloat {
        get { self[\.constant] }
        set { self[\.constant] = newValue }
    }
}

extension LayoutAnimator {
    /**
     The current animation for the property at the specified keypath, or `nil` if there isn't an animation for the keypath.

     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<LayoutAnimator, Value>) -> AnimationProviding? {
        return animations[keyPath.stringValue]
    }
    
    /**
     The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
     
     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<LayoutAnimator, Value>) -> Value? {
        return (animation(for: keyPath) as? any ConfigurableAnimationProviding)?.velocity as? Value
    }
}
