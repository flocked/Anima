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
    public var animator: LayoutAnimator { getAssociatedValue("PropertyAnimator", initialValue: LayoutAnimator(self)) }
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

 To access the animation for a property, use ``Anima/AnimationProvider/animation(for:)-6b22o``:

 ```swift
 if let animation = widthConstraint.animator.animation(for: \.constant) {
    animation.stop()
 }
 ```
 
 ### Accessing Animation Value and Velocity
 
 The animation returned via ``Anima/AnimationProvider/animation(for:)-6b22o`` provides the current animation value and velocity.

 ```swift
 if let animation = widthConstraint.animator.animation(for: \.constant) {
    let velocity = animation.velocity
    let value = animation.value
 }
 ```
 */
public class LayoutAnimator: PropertyAnimator<NSLayoutConstraint> {
    /// The constant of the layout constraint.
    public var constant: CGFloat {
        get { self[\.constant] }
        set { self[\.constant] = newValue }
    }
    
    #if os(macOS)
    /**
     The backing scale factor of the main window, used when animating with animation options that contain ``Anima/AnimationOptions/integralizeValues``.

     The default value is `nil`, which uses the platform default backing scale factor.
     
     For example:
     
     ```swift
     Anima.animate(withSpring: .bouncy, options: .integralizeValues) {
        layoutConstraint.animator.constant = 120.0
     }
     ```
     */
    public override var backingScaleFactor: CGFloat? { nil }
    #endif
}
