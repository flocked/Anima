//
//  Anima+ColorSpace.swift
//
//
//  Created by Florian Zand on 08.02.26.
//

import Foundation

extension Anima {
    /// A color space for animating colors.
    public enum ColorSpace: UInt, Equatable, Hashable, Sendable, CaseIterable, CustomStringConvertible, Codable {
        /// sRGB.
        case srgb
        /// HSL.
        case hsl
        /// HSB.
        case hsb
        /// OKLAB.
        case oklab
        /// OKLCH.
        case oklch
        /// OKHSB.
        case okhsb
        /// OKHSL
        case okhsl
        /// XYZ.
        case xyz
        /// LAB.
        case lab
        /// LCH.
        case lch
        /// LUV.
        case luv
        /// HPLUV.
        case hpluv
        /// Display P3.
        case displayP3
        /// HWB.
        case hwb
        /// LCHUV.
        case lchuv
        /// HSLUV.
        case hsluv
        /// JZCZHZ.
        case jzczhz
        /// JZAZBZ.
        case jzazbz
        
        var hueIndex: Int? {
            switch self {
            case .hpluv, .hsb, .hsl, .hsluv, .hwb, .okhsb, .okhsl: return 0
            case .jzczhz, .lch, .lchuv, .oklch: return 2
            default: return nil
            }
        }
        
        public var description: String {
            switch self {
            case .srgb:      return "sRGB"
            case .hsl:       return "HSL"
            case .hsb:       return "HSB"
            case .oklab:     return "OKLab"
            case .oklch:     return "OKLCH"
            case .okhsb:     return "OKHSB"
            case .okhsl:     return "OKHSL"
            case .xyz:       return "XYZ"
            case .lab:       return "Lab"
            case .lch:       return "LCH"
            case .luv:       return "Luv"
            case .hpluv:     return "HPLuv"
            case .displayP3: return "Display P3"
            case .hwb:       return "HWB"
            case .lchuv:     return "LCHuv"
            case .hsluv:     return "HSLuv"
            case .jzczhz:    return "JzCzHz"
            case .jzazbz:    return "JzAzBz"
            }
        }
    }
}
