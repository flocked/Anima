//
//  PropertyAnimator+Window.swift
//
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS)
import AppKit

extension NSWindow: AnimatablePropertyProvider {
    /// Provides animatable properties of the window.
    public var animator: WindowAnimator {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: WindowAnimator(self)) }
    }
}

/// Provides animatable properties of a window.
public class WindowAnimator: PropertyAnimator<NSWindow> {

    /// The frame of the window.
    public var frame: CGRect {
        get { self[\.frame_] }
        set { self[\.frame_] = newValue }
    }
    
    /// The size of the window. Changing the value keeps the window centered. To change the size without centering use the window's frame size.
    public var size: CGSize {
        get { frame.size }
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
    }
    
    /// The center of the window.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    /// The background color of the window.
    public var backgroundColor: NSColor {
        get { self[\.backgroundColor] }
        set { self[\.backgroundColor] = newValue }
    }
    
    /// The alpha value of the window.
    public var alphaValue: CGFloat {
        get { self[\.alphaValue] }
        set { self[\.alphaValue] = newValue }
    }
        
    /// The animator for the window's content view.
    public var contentView: PropertyAnimator<NSView>? {
        object.contentView?.animator
    }
}

fileprivate extension NSWindow {
   @objc dynamic var frame_: CGRect {
        get { frame }
        set { setFrame(newValue, display: false) }
    }
}

#endif
