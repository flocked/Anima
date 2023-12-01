//
//  NSUIColor+.swift
//
//
//  Created by Florian Zand on 20.09.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

internal extension NSUIColor {
    /// Returns the RGBA (red, green, blue, alpha) components.
    final func rgbaComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

      #if os(iOS) || os(tvOS) || os(watchOS)
        getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
      #elseif os(OSX)
        guard let rgbaColor = self.usingColorSpace(.deviceRGB) else {
          fatalError("Could not convert color to RGBA.")
        }

        rgbaColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
      #endif
    }
    
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /**
     Generates the resolved color for the specified view,.
     
     - Parameters view: The view for the resolved color.
     - Returns: A resolved color for the view.
     */
    func resolvedColor(for view: NSUIView) -> NSUIColor {
        #if os(macOS)
        self.resolvedColor(for: view.effectiveAppearance)
        #elseif canImport(UIKit)
        self.resolvedColor(with: view.traitCollection)
        #endif
    }
    
    /// A Boolean value that indicates whether the color contains a different light and dark color variant.
    var isDynamic: Bool {
        let dyamic = self.dynamicColors
        return dyamic.light != dyamic.dark
    }
    

    #endif
    
    /// A Boolean value that indicates whether the color is visible (`alphaComponent` isn't zero).
    var isVisible: Bool {
        self.alphaComponent != 0.0
    }
}
