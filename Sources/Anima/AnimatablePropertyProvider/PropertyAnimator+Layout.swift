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
