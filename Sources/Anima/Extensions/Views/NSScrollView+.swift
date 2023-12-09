//
//  NSScrollView+.swift
//  
//
//  Created by Florian Zand on 22.05.22.
//

#if os(macOS)

import AppKit
import Foundation

extension NSScrollView {
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

#endif
