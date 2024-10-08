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
     Provides animatable properties of the object.

     To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update the values outside an animation block.

     See ``PropertyAnimator`` for more information.
     */
    var animator: PropertyAnimator<Provider> { get }
}

public extension AnimatablePropertyProvider {
    var animator: PropertyAnimator<Self> { getAssociatedValue("PropertyAnimator", object: self, initialValue: PropertyAnimator(self)) }
}
