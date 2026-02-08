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
    var alpha: CGFloat {
        alphaComponent
    }
    

    /**
     Generates the resolved color for the specified view,.

     - Parameter view: The view for the resolved color.
     - Returns: A resolved color for the view.
     */
    func resolvedColor(for view: NSUIView) -> NSUIColor {
        #if os(macOS)
            resolvedColor(for: view.effectiveAppearance)
        #elseif canImport(UIKit)
            resolvedColor(with: view.traitCollection)
        #endif
    }

    /// A Boolean value that indicates whether the color contains a different light and dark color variant.
    var isDynamic: Bool {
        let dyamic = dynamicColors
        return dyamic.light != dyamic.dark
    }
}

#if os(macOS)
    extension NSColor {
        /// Returns the dynamic light and dark colors.
        var dynamicColors: (light: NSColor, dark: NSColor) {
            let light = resolvedColor(for: NSAppearance(named: .aqua)!)
            let dark = resolvedColor(for: NSAppearance(named: .darkAqua)!)
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
            var color: NSColor?
            if type == .catalog {
                if let colorSpace = colorSpace {
                    if #available(macOS 11.0, *) {
                        let appearance = appearance ?? .currentDrawing()
                        appearance.performAsCurrentDrawingAppearance {
                            color = usingColorSpace(colorSpace)
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
            let light = resolvedColor(with: .init(userInterfaceStyle: .light))
            let dark = resolvedColor(with: .init(userInterfaceStyle: .dark))
            return (light, dark)
        }

        /**
         The alpha component as CGFloat between 0.0 to 1.0.
         */
        var alphaComponent: CGFloat {
            cgColor.rgb().w
        }
    }
#endif
