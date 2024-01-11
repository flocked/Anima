//
//  NSView+.swift
//  Example
//
//  Created by Florian Zand on 11.01.24.
//

import AppKit

public extension NSView {
    var backgroundColor: NSColor? {
        get {
            if let cgColor = layer?.backgroundColor {
                return NSColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    var borderColor: NSColor? {
        get {
            if let cgColor = layer?.borderColor {
                return NSColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            wantsLayer = true
            layer?.borderColor = newValue?.cgColor
        }
    }
    
    var borderWidth: CGFloat {
        get { layer?.borderWidth ?? 0.0 }
        set {
            wantsLayer = true
            layer?.borderWidth = newValue
        }
    }
    
    var cornerRadius: CGFloat {
        get { layer?.cornerRadius ?? 0.0 }
        set {
            wantsLayer = true
            layer?.cornerRadius = newValue
        }
    }
}
