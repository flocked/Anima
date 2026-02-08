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
    var nsUIColor: NSUIColor? {
        NSUIColor(cgColor: self)
    }
    
    func toRGBVector() -> SIMD4<Double> {
        let components = ((self.colorSpace == ._extendedSRGB ? self : converted(to: ._extendedSRGB, intent: .defaultIntent, options: nil))?.components ?? [0,0,0,0]).map(Double.init)
        return SIMD4(components)
    }
    
    static func fromRGBVector(_ rgb: SIMD4<Double>) -> Self {
        Self(colorSpace: ._extendedSRGB, components: [rgb.x, rgb.y, rgb.z, rgb.w])!
    }
    
    #if canImport(UIKit)
    /// The clear color in the Generic gray color space.
    static var clear: CGColor { CGColor(gray: 0, alpha: 0) }
    #endif
}

extension AnimatableProperty where Self == CGColor {
    init?(colorSpace: CGColorSpace, components: [CGFloat]) {
        guard components.count >= colorSpace.numberOfComponents else { return nil }
        var components = components.count == colorSpace.numberOfComponents ? components + [1.0] : components
        guard let color = CGColor(colorSpace: colorSpace, components: &components) else { return nil }
        self = color
    }
}

extension CGColorSpace {
    static let _extendedSRGB = CGColorSpace(name: CGColorSpace.extendedSRGB)!
}
