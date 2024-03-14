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
        @objc var contentOffset: CGPoint {
            get { documentVisibleRect.origin }
            set { documentView?.scroll(newValue) }
        }
        
        /**
         The fractional document offset.

         - A value of `CGPoint(x:0, y:0)` indicates the document view is at the bottom left.
         - A value of `CGPoint(x:1, y:1)` indicates the document view is at the top right.
         */
        var documentOffsetFractional: CGPoint {
            get {
                guard let maxOffset = maxContentOffset else { return .zero }
                return CGPoint(contentOffset.x / maxOffset.x, contentOffset.y / maxOffset.y)
            }
            set {
                guard let maxOffset = maxContentOffset else { return }
                contentOffset = CGPoint(newValue.x.clamped(max: 1.0) * maxOffset.x, newValue.y.clamped(max: 1.0) * maxOffset.y)
            }
        }
        
        var maxContentOffset: CGPoint? {
            guard let documentView = documentView else { return nil }
            let maxY = documentView.frame.maxY - contentView.bounds.height
            let maxX = documentView.frame.maxX - contentView.bounds.width
            return CGPoint(maxX, maxY)
        }

        /**
         The size of the document view, or `nil` if there isn't a document view.

         The value can be animated via `animator()`.
         */
        @objc var documentSize: CGSize {
            get { documentView?.frame.size ?? NSSize.zero }
            set { documentView?.setFrameSize(newValue) }
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
                    setMagnification(magnification, centeredAt: point)
                } else {
                    self.magnification = magnification
                }
            }
        }
    }

#endif
