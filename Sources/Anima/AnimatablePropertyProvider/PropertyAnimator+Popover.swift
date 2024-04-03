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

 To access the animation for a property, use ``Anima/AnimationProvider/animation(for:)-6b22o``:

 ```swift
 if let animation = popover.animator.animation(for: \.contentSize) {
    animation.stop()
 }
 ```
 
 ### Accessing Animation Value and Velocity
 
 The animation returned via ``Anima/AnimationProvider/animation(for:)-6b22o`` provides the current animation value and velocity.

 ```swift
 if let animation = popover.animator.animation(for: \.contentSize) {
    let velocity = animation.velocity
    let value = animation.value
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


#endif
