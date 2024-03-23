//
//  PropertyAnimator+Layout.swift
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
    /**
     Provides animatable properties of the layout constraint.

     To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update their values outside an animation block.

     See ``LayoutAnimator`` for more information about how to animate and all animatable properties.
     */
    public var animator: LayoutAnimator { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: LayoutAnimator(self)) }
}

/**
 Provides animatable properties of `NSLayoutConstraint`.

 To animate the `constant` of a layer, change it's value inside an ``Anima`` animation block:

 ```swift
 Anima.animate(withSpring: .smooth) {
    widthConstraint.animator.constant = 200.0
 }
 ```
 To stop the animation and to change the constant immediately, change it's value outside an animation block:

 ```swift
 widthConstraint.animator.constant = 50.0
 ```

 ### Accessing Animation

 To access the animation for a property, use ``Anima/AnimationProvider/animation(for:)-54u0m``:

 ```swift
 if let animation = widthConstraint.animator.animation(for: \.constant) {
    animation.stop()
 }
 ```
 
 ### Accessing Animation Value

 To access the current animation value for a property, use ``Anima/AnimationProvider/animationValue(for:)-91c63``.

 ```swift
 if let value = widthConstraint.animator.animationValue(for: \.constant) {

 }
 ```

 ### Accessing Animation Velocity

 To access the animation velocity for `constant`, use ``Anima/AnimationProvider/animationVelocity(for:)-1k944``.

 ```swift
 if let velocity = widthConstraint.animator.animationVelocity(for: \.constant) {

 }
 ```
 */
public class LayoutAnimator: PropertyAnimator<NSLayoutConstraint> {
    /// The constant of the layout constraint.
    public var constant: CGFloat {
        get { self[\.constant] }
        set { self[\.constant] = newValue }
    }
}
