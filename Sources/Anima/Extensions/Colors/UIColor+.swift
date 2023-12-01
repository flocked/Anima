//
//  UIColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if canImport(UIKit)
import UIKit

#if os(iOS) || os(tvOS)
internal extension UIColor {
    /// Returns the dynamic light and dark colors.
    var dynamicColors: (light: UIColor, dark: UIColor) {
        let light = self.resolvedColor(with: .init(userInterfaceStyle: .light))
        let dark = self.resolvedColor(with: .init(userInterfaceStyle: .dark))
        return (light, dark)
    }
}
#endif

internal extension UIColor {
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

internal extension UIColor {
    /// The color to use for virtual shadows cast by raised objects on the screen.
    static var shadowColor: UIColor {
        return UIColor.black
    }
}
#endif
