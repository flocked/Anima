//
//  NSValue+.swift
//  
//
//  Created by Florian Zand on 22.09.23.
//

import Foundation
#if canImport(QuartzCore)
import QuartzCore
#endif

#if os(macOS)
import AppKit

extension NSValue {
    /// Creates a new value object containing the specified directional edge insets structure.
    internal convenience init(directionalEdgeInsets: NSDirectionalEdgeInsets) {
        var insets = directionalEdgeInsets
        self.init(bytes: &insets, objCType: _getObjCTypeEncoding(NSDirectionalEdgeInsets.self))
    }
    
    /// Returns the directional edge insets structure representation of the value.
    internal var directionalEdgeInsetsValue: NSDirectionalEdgeInsets {
        var insets = NSDirectionalEdgeInsets()
        self.getValue(&insets)
        return insets
    }
    
    /// Creates a new value object containing the specified CoreGraphics affine transform structure.
    internal convenience init(cgAffineTransform: CGAffineTransform) {
        var transform = cgAffineTransform
        self.init(bytes: &transform, objCType: _getObjCTypeEncoding(CGAffineTransform.self))
    }
    
    /// Returns the CoreGraphics affine transform representation of the value.
    internal var cgAffineTransformValue: CGAffineTransform {
        var transform = CGAffineTransform.identity
        self.getValue(&transform)
        return transform
    }
}
#endif

internal extension CGPoint {
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
        return NSValue(cgPoint: self)
        #else
        return NSValue(point: NSPointFromCGPoint(self))
        #endif
    }
}

internal extension CGRect {
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
        return NSValue(cgRect: self)
        #else
        return NSValue(rect: NSRectFromCGRect(self))
        #endif
    }
}

internal extension CGSize {
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
        return NSValue(cgSize: self)
        #else
        return NSValue(size: NSSizeFromCGSize(self))
        #endif
    }
}

internal extension NSRange {
    var nsValue: NSValue {
        return NSValue(range: self)
    }
}

public extension ClosedRange where Bound: BinaryInteger {
    var nsValue: NSValue {
        return NSValue(range: self.nsRange)
    }
}

internal extension Range where Bound: BinaryInteger {
    var nsValue: NSValue {
        return NSValue(range: self.nsRange)
    }
}

#if os(macOS)
internal extension NSEdgeInsets {
    var nsValue: NSValue {
        return NSValue(edgeInsets: self)
    }
}
#elseif canImport(UIKit) || os(watchOS)
import UIKit
internal extension UIEdgeInsets {
    var nsValue: NSValue {
        return NSValue(uiEdgeInsets: self)
    }
}
#endif

#if canImport(QuartzCore)
internal extension CATransform3D {
    var nsValue: NSValue {
        return NSValue(caTransform3D: self)
    }
}
#endif

