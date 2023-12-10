//
//  AnimatablePropertyProvider.swift
//  
//
//  Created by Florian Zand on 27.10.23.
//

import Foundation

/// An object that provides animatable properties that can be accessed via it's ``animator-94wn0``.
public protocol AnimatablePropertyProvider: AnyObject {
    /// The object that provides animatable properties.
    associatedtype Provider: AnimatablePropertyProvider = Self
    
    /**
     Provides the animatable properties of the object.
     
     To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update their values outside an animation block.
     
     See ``PropertyAnimator`` for more information.
     */
    var animator: PropertyAnimator<Provider> { get }
}

extension AnimatablePropertyProvider {
    public var animator: PropertyAnimator<Self> {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: PropertyAnimator(self)) }
    }
}
