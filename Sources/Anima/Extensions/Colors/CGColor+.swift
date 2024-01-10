//
//  CGColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

extension CGColor {
    /// Returns the RGBA (red, green, blue, alpha) components.
    func rgbaComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var color = self
        if color.colorSpace?.model != .rgb, #available(iOS 9.0, macOS 10.11, tvOS 9.0, watchOS 2.0, *) {
            color = color.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil) ?? color
        }
        guard let components = color.components else { return nil }
        switch numberOfComponents {
        case 2:
            return (components[0], components[0], components[0], components[1])
        case 3:
            return (components[0], components[1], components[2], 1.0)
        case 4:
            return (components[0], components[1], components[2], components[3])
        default:
            let ciColor = CIColor(cgColor: color)
            return (ciColor.red, ciColor.green, ciColor.blue, ciColor.alpha)
        }
    }

    var nsUIColor: NSUIColor? {
        return NSUIColor(cgColor: self)
    }
}

#if canImport(UIKit)
extension CGColor {
    /// The clear color in the Generic gray color space.
    static var clear: CGColor {
        CGColor(gray: 0, alpha: 0)
    }
}
#endif
