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

extension NSUIColor {
    /// Returns the RGBA (red, green, blue, alpha) components.
    final func rgbaComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

      #if os(iOS) || os(tvOS)
        getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
      #elseif os(macOS)
        guard let rgbaColor = self.usingColorSpace(.deviceRGB) else {
          fatalError("Could not convert color to RGBA.")
        }

        rgbaColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
      #endif
    }
        
    /**
     Generates the resolved color for the specified view,.
     
     - Parameter view: The view for the resolved color.
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
}

#if os(macOS)
extension NSColor {
    /// Returns the dynamic light and dark colors.
    var dynamicColors: (light: NSColor, dark: NSColor) {
        let light = self.resolvedColor(for: NSAppearance(named: .aqua)!)
        let dark = self.resolvedColor(for: NSAppearance(named: .darkAqua)!)
        return (light, dark)
    }
    
    /**
     Generates the resolved color for the specified appearance.
     
     - Parameter appearance: The appearance of the resolved color.
     - Returns: A `NSColor` for the appearance.
     */
    func resolvedColor(for appearance: NSAppearance? = nil) -> NSColor {
        resolvedColor(for: appearance, colorSpace: nil) ?? self
    }
    
    /**
     Generates the resolved color for the specified appearance and color space. If color space is `nil`, the color resolves to the first compatible color space.
     
     - Parameters:
        - appearance: The appearance of the resolved color.
        - colorSpace: The color space of the resolved color. If `nil`, the first compatible color space is used.
     - Returns: A color for the appearance and color space.
     */
    func resolvedColor(for appearance: NSAppearance? = nil, colorSpace: NSColorSpace?) -> NSColor? {
        var color: NSColor? = nil
        if type == .catalog {
            if let colorSpace = colorSpace {
                if #available(macOS 11.0, *) {
                    let appearance = appearance ?? .currentDrawing()
                    appearance.performAsCurrentDrawingAppearance {
                        color = self.usingColorSpace(colorSpace)
                    }
                } else {
                    let appearance = appearance ?? .current
                    let current = NSAppearance.current
                    NSAppearance.current = appearance
                    color = usingColorSpace(colorSpace)
                    NSAppearance.current = current
                }
            } else {
                for supportedColorSpace in Self.supportedColorSpaces {
                    if let color = resolvedColor(for: appearance, colorSpace: supportedColorSpace) {
                        return color
                    }
                }
            }
        }
        return color
    }
    
    /// Supported color spaces for displaying a color.
    static let supportedColorSpaces: [NSColorSpace] = [.sRGB, .deviceRGB, .extendedSRGB, .genericRGB, .adobeRGB1998, .displayP3]
}
#elseif canImport(UIKit)
extension UIColor {
    /// Returns the dynamic light and dark colors.
    var dynamicColors: (light: UIColor, dark: UIColor) {
        let light = self.resolvedColor(with: .init(userInterfaceStyle: .light))
        let dark = self.resolvedColor(with: .init(userInterfaceStyle: .dark))
        return (light, dark)
    }
    
    /**
     Creates a new color object whose component values are a weighted sum of the current color object and the specified color object's.
     
     - Parameters:
        - fraction: The amount of the color to blend with the receiver's color. The method converts color and a copy of the receiver to RGB, and then sets each component of the returned color to fraction of color’s value plus 1 – fraction of the receiver’s.
        - color: The color to blend with the receiver's color.
     
     - Returns: The resulting color object or nil if the colors can’t be converted.
     */
    func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
        let progress = fraction.clamped(max: 1.0)
        let fromComponents = rgbaComponents()
        let toComponents = color.rgbaComponents()

        let r = (1 - progress) * fromComponents.red + progress * toComponents.red
        let g = (1 - progress) * fromComponents.green + progress * toComponents.green
        let b = (1 - progress) * fromComponents.blue + progress * toComponents.blue
        let a = (1 - progress) * fromComponents.alpha + progress * toComponents.alpha
        return NSUIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /**
    The alpha component as CGFloat between 0.0 to 1.0.
    */
   var alphaComponent: CGFloat {
     return rgbaComponents().alpha
   }
}
#endif
