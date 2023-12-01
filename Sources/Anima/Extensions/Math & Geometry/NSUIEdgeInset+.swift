//
//  NSUIEdgeInset+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

extension NSDirectionalRectEdge: Hashable {}

extension NSUIEdgeInsets: Hashable {
    public static func == (lhs: NSUIEdgeInsets, rhs: NSUIEdgeInsets) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(left)
        hasher.combine(right)
    }
}

public extension NSUIEdgeInsets {
#if os(macOS)
/// An edge insets struct whose top, left, bottom, and right fields are all set to 0.
static var zero = NSEdgeInsets(0)
#endif
}

internal extension NSUIEdgeInsets {
    /// Creates an edge insets structure with the specified value for top, bottom, left and right.
    init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}

public extension NSDirectionalEdgeInsets {
    #if os(macOS)
///A directional edge insets structure whose top, leading, bottom, and trailing fields all have a value of 0.
    static var zero = NSDirectionalEdgeInsets(0)
    #endif
}

internal extension NSDirectionalEdgeInsets {
    /// Creates an edge insets structure with the specified value for top, bottom, leading and trailing.
    init(_ value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }
    
    
    /// The width (leading + trailing) of the insets.
    var width: CGFloat {
        get { return leading + trailing }
        set {
            let value = newValue / 2.0
            leading = value
            trailing = value
        }
    }

    /// The height (top + bottom) of the insets.
    var height: CGFloat {
        get { return top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }
}

extension NSDirectionalEdgeInsets: Hashable {
    public static func == (lhs: NSDirectionalEdgeInsets, rhs: NSDirectionalEdgeInsets) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(trailing)
        hasher.combine(leading)
    }
}

internal extension CGRect {
    func inset(by edgeInsets: NSDirectionalEdgeInsets) -> CGRect {
        var result = self
        result.origin.x += edgeInsets.leading
        result.origin.y += edgeInsets.top
        result.size.width -= edgeInsets.leading - edgeInsets.trailing
        result.size.height -= edgeInsets.top - edgeInsets.bottom
        return result
    }
}
