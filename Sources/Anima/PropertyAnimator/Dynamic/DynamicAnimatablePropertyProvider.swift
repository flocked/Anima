//
//  DynamicAnimatablePropertyProvider.swift
//
//
//  Created by Florian Zand on 27.10.23.
//
/*
#if os(macOS) || os(iOS) || os(tvOS)


import Foundation

/// An object that provides animatable properties that can be accessed via ``DynamicAnimatablePropertyProvider/animator``.
public protocol DynamicAnimatablePropertyProvider: AnyObject {
    associatedtype Provider: DynamicAnimatablePropertyProvider = Self
    
    /**
     Provides animatable properties. To animate a property, change it's value in a ``Anima`` animation block.
               
     Example usage:
     ```swift
     Anima.animate(withSpring: .smooth) {
        myView.animator.center = CGPoint(x: 100, y: 100)
        myView.animator.alpha = 0.5
     }
     
     myView.animator.alpha = 0.0 // Stops animating the property and changes it imminently.
     ```
     
     To get/set a property of the object that is not provided as `animator` property, use the properties keypath on `animator`. The property needs to confirm to ``AnimatableProperty``.
     
     ```swift
     Anima.animate(withSpring: .smooth) {
        myView.animator[\.myAnimatableProperty] = newValue
     }
     ```
     For easier access of the property, you can extend the object's PropertyAnimator.
     
     ```swift
     public extension PropertyAnimator<NSView> {
        var myAnimatableProperty: CGFloat {
            get { self[\.myAnimatableProperty] }
            set { self[\.myAnimatableProperty] = newValue }
        }
     }
     
     Anima.animate(withSpring: .smooth) {
        myView.animator.myAnimatableProperty = newValue
     }
     ```
     */
    var animator: DynamicPropertyAnimator<Provider> { get }
}

extension DynamicAnimatablePropertyProvider {
    public var animator: DynamicPropertyAnimator<Self> {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: DynamicPropertyAnimator(self)) }
    }
}

#endif
*/
