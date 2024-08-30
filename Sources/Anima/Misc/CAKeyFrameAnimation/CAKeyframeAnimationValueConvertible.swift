//
//  CAKeyframeAnimationValueConvertible.swift
//
//  Copyright (c) 2020, Adam Bell
//  Modifed:
//  Florian Zand on 02.11.23.
//

import Foundation
#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

// MARK: - CAKeyframeAnimationValueConvertible

/**
 A protocol for types to supply the ability to convert themselves into `NSValue` or `NSNumber` for use with `CAKeyframeAnimation`. This is required for `CAKeyframeAnimationEmittable`.

 - Note: This is required for using `CAKeyframeAnimationEmittable`.
 */
public protocol CAKeyframeAnimationValueConvertible {
    /// Converts the value  for use with `CAKeyframeAnimation`.
    func toKeyframeValue() -> AnyObject
}

extension Float: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        self as NSNumber
    }
}

extension Double: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        self as NSNumber
    }
}

// MARK: CoreGraphics Types

extension CGFloat: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        self as NSNumber
    }
}

extension CGPoint: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        #if os(macOS)
            return NSValue(point: self)
        #else
            return NSValue(cgPoint: self)
        #endif
    }
}

extension CGSize: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        #if os(macOS)
            return NSValue(size: self)
        #else
            return NSValue(cgSize: self)
        #endif
    }
}

extension CGRect: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        #if os(macOS)
            return NSValue(rect: self)
        #else
            return NSValue(cgRect: self)
        #endif
    }
}

extension CGColor: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        self
    }
}

#if os(macOS)
    extension NSColor: CAKeyframeAnimationValueConvertible {
        public func toKeyframeValue() -> AnyObject {
            cgColor
        }
    }
#else
    extension UIColor: CAKeyframeAnimationValueConvertible {
        public func toKeyframeValue() -> AnyObject {
            cgColor
        }
    }
#endif
extension NSRange: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        NSValue(range: self)
    }
}

extension ClosedRange: CAKeyframeAnimationValueConvertible where Bound: BinaryInteger {
    public func toKeyframeValue() -> AnyObject {
        NSValue(range: NSRange(location: Int(lowerBound), length: Int(upperBound - lowerBound - 1)))
    }
}

extension Range: CAKeyframeAnimationValueConvertible where Bound: BinaryInteger {
    public func toKeyframeValue() -> AnyObject {
        NSValue(range: NSRange(location: Int(lowerBound), length: Int(upperBound - lowerBound)))
    }
}

extension CATransform3D: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        NSValue(caTransform3D: self)
    }
}

extension CGAffineTransform: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        NSValue(cgAffineTransform: self)
    }
}

#if os(macOS)
    extension NSEdgeInsets: CAKeyframeAnimationValueConvertible {
        public func toKeyframeValue() -> AnyObject {
            #if os(macOS)
                NSValue(edgeInsets: self)
            #else
                NSValue(uiEdgeInsets: self)
            #endif
        }
    }
#else
    extension UIEdgeInsets: CAKeyframeAnimationValueConvertible {
        public func toKeyframeValue() -> AnyObject {
            #if os(macOS)
                NSValue(edgeInsets: self)
            #else
                NSValue(uiEdgeInsets: self)
            #endif
        }
    }
#endif

extension NSDirectionalEdgeInsets: CAKeyframeAnimationValueConvertible {
    public func toKeyframeValue() -> AnyObject {
        NSValue(directionalEdgeInsets: self)
    }
}
