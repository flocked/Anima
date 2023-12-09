//
//  AnimatablePropertyProvider.swift
//  
//
//  Created by Florian Zand on 27.10.23.
//

import Foundation

/// An object that provides animatable properties that can be accessed via it's ``animator``.
public protocol AnimatablePropertyProvider: AnyObject {
    /// The object that provides animatable properties.
    associatedtype Provider: AnimatablePropertyProvider = Self
    
    /**
     It provides all animatable properties of the object. To animate them change their value inside an ``Anima`` animation block.
               
     Example usage:
     ```swift
     Anima.animate(withSpring: .smooth) {
        myView.animator.center = CGPoint(x: 100, y: 100)
        myView.animator.alpha = 0.5
     }
     ```
     
     To stop animating values and to update their values imminently, change them outside of an animation block.
          
     ```swift
     myView.animator.alpha = 0.0
     ```
     
     To get/set a property of the object that is not provided as property of ``animator``, use the properties keypath on `animator`. The property needs to confirm to ``AnimatableProperty``.
     
     ```swift
     class MyObject: AnimatablePropertyProvider {
        var myAnimatableProperty: CGFloat = 0.0
     }
     
     Anima.animate(withSpring: .smooth) {
        myObject.animator[\.myAnimatableProperty] = newValue
     }
     ```
     For easier access of the property, you can extend the object's PropertyAnimator.
     
     
     ```swift
     public extension PropertyAnimator<MyObject> {
        var myAnimatableProperty: CGFloat {
            get { self[\.myAnimatableProperty] }
            set { self[\.myAnimatableProperty] = newValue }
        }
     }
     
     Anima.animate(withSpring: .smooth) {
        myObject.animator.myAnimatableProperty = newValue
     }
     ```
     */
    var animator: PropertyAnimator<Provider> { get }
}

extension AnimatablePropertyProvider {
    public var animator: PropertyAnimator<Self> {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: PropertyAnimator(self)) }
    }
}
