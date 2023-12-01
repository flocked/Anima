//
//  NSColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit

internal extension NSColor {
    /// Returns the dynamic light and dark colors.
    var dynamicColors: (light: NSColor, dark: NSColor) {
        let light = self.resolvedColor(for: NSAppearance(named: .aqua)!)
        let dark = self.resolvedColor(for: NSAppearance(named: .darkAqua)!)
        return (light, dark)
    }
    
    /**
     Generates the resolved color for the specified appearance.
     
     - Parameters appearance: The appearance of the resolved color.
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
#endif
