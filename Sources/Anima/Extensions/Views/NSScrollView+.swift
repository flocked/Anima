//
//  NSScrollView+.swift
//  
//
//  Created by Florian Zand on 22.05.22.
//

#if os(macOS)

import AppKit
import Foundation

internal extension NSScrollView {
    /**
     The point at which the origin of the content view is offset from the origin of the scroll view.

     The default value is CGPointZero.
     */
    @objc dynamic var contentOffset: CGPoint {
        get { return documentVisibleRect.origin }
        set {  documentView?.scroll(newValue) }
    }

    /**
     Magnify the content by the given amount and optionally center the result on the given point.
     
     - Parameters:
        - magnification: The amount by which to magnify the content.
        - point: The point (in content view space) on which to center magnification, or nil if the magnification shouldn't be centered.
        - animationDuration: The animation duration of the magnification, or nil if the magnification shouldn't be animated.

     */
    func setMagnification(_ magnification: CGFloat, centeredAt point: CGPoint? = nil, animationDuration: TimeInterval?) {
        if let animationDuration = animationDuration, animationDuration != 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                if let point = point {
                    self.animator().setMagnification(magnification, centeredAt: point)
                } else {
                    self.animator().magnification = magnification
                }
            }
        } else {
            if let point = point {
                self.setMagnification(magnification, centeredAt: point)
            } else {
                self.magnification = magnification
            }
        }
    }
}

internal extension NSClipView {
    /**
     Changes the origin of the clip view’s bounds rectangle animted to newOrigin.

     - Parameters:
        - newOrigin: The point in the view to scroll to.
        - animationDuration: The animation duration of the scolling.
     */
    func scroll(to newOrigin: CGPoint, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                    self.animator().setBoundsOrigin(newOrigin)
                self.enclosingScrollView?.reflectScrolledClipView(self)
            }
        } else {
            self.scroll(to: newOrigin)
        }
    }
}

internal extension NSScrollView {
    /// A saved scroll position.
    struct SavedScrollPosition {
        internal let bounds: CGRect
        internal let visible: CGRect
    }

    /// Saves the current scroll position.
    func saveScrollPosition() -> SavedScrollPosition {
        return SavedScrollPosition(bounds: bounds, visible: visibleRect)
    }

    /**
     Restores the specified saved scroll position.
     
     - Parameters scrollPosition: The scroll position to restore.
     */
    func restoreScrollPosition(_ scrollPosition: SavedScrollPosition) {
        let oldBounds = scrollPosition.bounds
        let oldVisible = scrollPosition.visible
        let oldY = oldVisible.midY
        let oldH = oldBounds.height
        guard oldH > 0.0 else { return }

        let fraction = (oldY - oldBounds.minY) / oldH
        let newBounds = bounds
        var newVisible = visibleRect
        let newY = newBounds.minY + fraction * newBounds.height
        newVisible.origin.y = newY - 0.5 * newVisible.height
        scroll(newVisible.origin)
    }
}

#endif
