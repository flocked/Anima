//
//  ColorMath.swift
//  Anima
//
//  Created by Florian Zand on 08.02.26.
//

import Foundation
import simd
import SwiftUI

public enum ColorMath {
}
public extension ColorMath {
    static func rgbToLinear(_ color: SIMD4<Double>) -> SIMD4<Double> {
        .init(rgbToLinear(color.x), rgbToLinear(color.y), rgbToLinear(color.z), color.w)
    }
    
    static func rgbToNonlinear(_ color: SIMD4<Double>) -> SIMD4<Double> {
        .init(rgbToNonlinear(color.x), rgbToNonlinear(color.y), rgbToNonlinear(color.z), color.w)
    }
    
    static func rgbToOKLAB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let linear = rgbToLinear(color)
        let rgb = SIMD3(linear.x, linear.y, linear.z)
        let lms = (rgbToLMS * rgb).map(cbrt)
        let oklab = lmsToOKLAB * lms
        return .init(oklab.x, oklab.y, oklab.z, color.w)
    }
    
    static func rgbToHSL(_ color: SIMD4<Double>) -> SIMD4<Double> {
        rgbToHSX(color, isHSL: true)
    }
    
    static func rgbToHSB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        rgbToHSX(color, isHSL: false)
    }
    
    static func rgbToXYZ(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let linearRGB = SIMD3(rgbToLinear(color.x), rgbToLinear(color.y), rgbToLinear(color.z))
        let xyz = rgbToXYZ * linearRGB
        return .init(xyz.x, xyz.y, xyz.z, color.w)
    }
    
    static func xyzToRGB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let xyzVec = SIMD3(color.x, color.y, color.z)
        let rgb = xyztoRGB * xyzVec
        return .init(rgbToNonlinear(rgb.x), rgbToNonlinear(rgb.y), rgbToNonlinear(rgb.z), color.w)
    }
    
    static func xyzToLUV(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (x, y, z, alpha) = (color.x, color.y, color.z, color.w)
        let un = D65.un
        let vn = D65.vn
        let denom = x + 15*y + 3*z
        let uPrime = denom != 0 ? 4*x/denom : 0
        let vPrime = denom != 0 ? 9*y/denom : 0
        let Y_Yn = y / D65.y
        let lightness: Double
        if Y_Yn > pow(6.0/29.0, 3.0) {
            lightness = 116 * pow(Y_Yn, 1/3.0) - 16
        } else {
            lightness = (29.0/3.0)*(29.0/3.0)*Y_Yn
        }
        let greenRed = 13 * lightness * (uPrime - un)
        let blueYellow = 13 * lightness * (vPrime - vn)
        return .init(lightness, greenRed, blueYellow, alpha)
    }
    
    static func xyzToLAB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (x, y, z, alpha) = (color.x, color.y, color.z, color.w)
        let fx = f(x / D65.x)
        let fy = f(y / D65.y)
        let fz = f(z / D65.z)
        return .init(116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz), alpha)
    }
    
    static func xyzToDisplay3(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (x, y, z, alpha) = (color.x, color.y, color.z, color.w)
        let xyzVec = SIMD3(x, y, z)
        let rgb = xyzToDisplayP3 * xyzVec
        return .init(rgbToNonlinear(rgb.x), rgbToNonlinear(rgb.y), rgbToNonlinear(rgb.z), alpha)
    }
    
    static func xyzToJZAZBZ(_ color: SIMD4<Double>) -> SIMD4<Double> {
        JZAZBZ.fromXYZ(color)
    }
    
    static func jzazbzToXYZ(_ color: SIMD4<Double>) -> SIMD4<Double> {
        JZAZBZ.toXYZ(color)
    }
    
    static func hsbToHSL(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (hue, saturation, brightness, alpha) = (color.x, color.y, color.z, color.w)
        let lightness = brightness * (1 - saturation * 0.5)
        let sat: Double
        if lightness == 0 || lightness == brightness {
            sat = 0
        } else {
            sat = (brightness - lightness) / min(lightness, brightness - lightness)
        }
        return .init(wrapUnit(hue), sat, lightness, alpha)
    }
    
    static func hsbToRGB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (hue, saturation, brightness, alpha) = (color.x, color.y, color.z, color.w)
        if saturation <= 0 { return .init(brightness, brightness, brightness, alpha) }
        let hueWrapped = wrapUnit(hue)
        let h = hueWrapped * 6.0
        let i = Int(floor(h))
        let f = h - Double(i)
        let p = brightness * (1.0 - saturation)
        let q = brightness * (1.0 - saturation * f)
        let t = brightness * (1.0 - saturation * (1.0 - f))
        
        switch (i % 6) {
        case 0: return .init(brightness, t, p, alpha)
        case 1: return .init(q, brightness, p, alpha)
        case 2: return .init(p, brightness, t, alpha)
        case 3: return .init(p, q, brightness, alpha)
        case 4: return .init(t, p, brightness, alpha)
        default: return .init(brightness, p, q, alpha)
        }
    }
    
    static func hsbToHWB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (hue, saturation, brightness, alpha) = (color.x, color.y, color.z, color.w)
        return .init(hue, brightness * (1 - saturation), 1 - brightness, alpha)
    }
    
    static func hpluvTpLCHUV(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (hue, saturation, _lightness, alpha) = (color.x, color.y, color.z, color.w)
        let lightness = _lightness * 100
        let chroma = saturation == 0 ? 0 : maxChroma(lightness, hue) * saturation
        // let chroma saturation > 0 ? maxChroma(lightness, hue) * saturation : 0
        return .init(lightness, chroma, hue, alpha)
    }
    
    static func hslToHSB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (hue, saturation, lightness, alpha) = (color.x, color.y, color.z, color.w)
        let l = lightness
        let s_hsl = saturation
        let v = l + s_hsl * min(l, max(0, 1 - l))
        let s_hsv: Double
        if v == 0 {
            s_hsv = 0
        } else {
            s_hsv = 2 * (1 - l / v)
        }
        return .init(wrapUnit(hue), s_hsv, v, alpha)
    }
    
    static func hsluvTOLCHUV(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (hue, saturation, _lightness, alpha) = (color.x, color.y, color.z, color.w)
        let lightness = _lightness * 100
        let chroma = saturation == 0 ? 0 : maxChroma(lightness, hue) * saturation
        // let chroma saturation > 0 ? maxChroma(lightness, hue) * saturation : 0
        return .init(lightness, chroma, hue, alpha)
    }
    
    static func hwbToHSB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (hue, whiteness, blackness, alpha) = (color.x, color.y, color.z, color.w)
        let brightness = 1 - blackness
        let saturation: Double
        if brightness == 0 {
            saturation = 0
        } else {
            saturation = 1 - whiteness / brightness
        }
        return .init(hue, saturation, brightness, alpha)
    }
    
    static func jzczhzTojzazbz(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (jz, chroma, hue, alpha) = (color.x, color.y, color.z, color.w)
        let hueRadians = hue * 2.0 * .pi
        let az = chroma * cos(hueRadians)
        let bz = chroma * sin(hueRadians)
        return .init(jz, az, bz, alpha)
    }
    
    static func lchToLAB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, chroma, hue, alpha) = (color.x, color.y, color.z, color.w)
        let cartesian = cartesianFromPolar(hue: hue, chroma: chroma)
        return .init(lightness, cartesian.a, cartesian.b, alpha)
    }
    
    static func lchuvToLUV(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, chroma, hue, alpha) = (color.x, color.y, color.z, color.w)
        let cartesian = cartesianFromPolar(hue: hue, chroma: chroma)
        return .init(lightness, cartesian.a, cartesian.b, alpha)
    }
    
    static func lchuvToHSLUV(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, chroma, hue, alpha) = (color.x, color.y, color.z, color.w)
        let maxC = maxChroma(lightness, hue)
        let saturation = maxC > 0 ? chroma / maxC : 0
        return .init(hue, saturation, lightness / 100.0, alpha)
    }
    
    static func lchuvToHPLUV(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, chroma, hue, alpha) = (color.x, color.y, color.z, color.w)
        let maxC = maxChroma(lightness, hue)
        let saturation = maxC > 0 ? chroma / maxC : 0
        return .init(hue, saturation, lightness / 100.0, alpha)
    }
    
    static func oklchToOKLAB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, chroma, hue, alpha) = (color.x, color.y, color.z, color.w)
        let cartesian = cartesianFromPolar(hue: hue, chroma: chroma)
        return .init(lightness, cartesian.a, cartesian.b, alpha)
    }
    
    static func luvToXYZ(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, greenRed, blueYellow, alpha) = (color.x, color.y, color.z, color.w)
        let un = D65.un
        let vn = D65.vn
        let uPrime = lightness != 0 ? greenRed / (13 * lightness) + un : 0
        let vPrime = lightness != 0 ? blueYellow / (13 * lightness) + vn : 0
        let y: Double
        if lightness > 8 {
            y = D65.y * pow((lightness + 16.0)/116.0, 3.0)
        } else {
            y = D65.y * lightness * pow(3.0/29.0, 3.0)
        }
        guard vPrime != 0 else {
            return .init(0, y, 0, alpha)
        }
        let x = y * 2.25 * uPrime / vPrime
        let z = y * (3 - 0.75*uPrime - 5*vPrime) / vPrime
        return .init(x, y, z, alpha)
    }
    
    static func luvToLCHUV(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, greenRed, blueYellow, alpha) = (color.x, color.y, color.z, color.w)
        let chroma = chromaFromCartesian(greenRed, blueYellow)
        let hue = hueFromCartesian(greenRed, blueYellow)
        return .init(lightness, chroma, hue, alpha)
    }
    
    static func jzazbzToJZCZHZ(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (jz, az, bz, alpha) = (color.x, color.y, color.z, color.w)
        let cz = sqrt(az * az + bz * bz)
        var hz = atan2(bz, az) / (2.0 * .pi)
        if hz < 0 { hz += 1.0 }
        return .init(jz, cz, hz, alpha)
    }
    
    static func labToXYZ(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, greenRed, blueYellow, alpha) = (color.x, color.y, color.z, color.w)
        let fy = (lightness + 16.0) / 116.0
        let fx = fy + greenRed / 500.0
        let fz = fy - blueYellow / 200.0
        return .init(fInv(fx) * D65.x, fInv(fy) * D65.y, fInv(fz) * D65.z, alpha)
    }
    
    static func labToLCH(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, greenRed, blueYellow, alpha) = (color.x, color.y, color.z, color.w)
        let chroma = chromaFromCartesian(greenRed, blueYellow)
        let hue = hueFromCartesian(greenRed, blueYellow)
        return .init(lightness, chroma, hue, alpha)
    }
    
    static func oklabToRGB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, greenRed, blueYellow, alpha) = (color.x, color.y, color.z, color.w)
        let oklab = SIMD3(lightness, greenRed, blueYellow)
        var lms = oklabToLMS * oklab
        lms = lms * lms * lms
        let rgb = lmsToSRGB * lms
        return .init(rgbToNonlinear(rgb.x), rgbToNonlinear(rgb.y), rgbToNonlinear(rgb.z), alpha)
    }
    
    static func oklabToOKLCH(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let (lightness, greenRed, blueYellow, alpha) = (color.x, color.y, color.z, color.w)
        let chroma = chromaFromCartesian(greenRed, blueYellow)
        let hue = hueFromCartesian(greenRed, blueYellow)
        return .init(lightness, chroma, hue, alpha)
    }
    
    static func oklabToOKHSB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        OKLAB.toHSX(color, hsl: false)
    }
    
    static func oklabToOKHSL(_ color: SIMD4<Double>) -> SIMD4<Double> {
        OKLAB.toHSX(color, hsl: true)
    }
    
    static func okhsbToOKLAB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        OKLAB.fromHSX(color, hsl: false)
    }
    
    static func okhslToOKLAB(_ color: SIMD4<Double>) -> SIMD4<Double> {
        OKLAB.fromHSX(color, hsl: true)
    }
    
    static func displayP3ToXYZ(_ color: SIMD4<Double>) -> SIMD4<Double> {
        let rgb = SIMD3(rgbToLinear(color.x), rgbToLinear(color.y), rgbToLinear(color.z))
        let xyz = displayP3ToXZY * rgb
        return .init(xyz.x, xyz.y, xyz.z, color.w)
    }
    
    private static let oklabToLMS: simd_double3x3 = .init(
        SIMD3(1.0,  0.3963377774,  0.2158037573),
        SIMD3(1.0, -0.1055613458, -0.0638541728),
        SIMD3(1.0, -0.0894841775, -1.2914855480))
    
    private static let lmsToSRGB: simd_double3x3 = .init(
        SIMD3( 4.0767416621, -3.3077115913,  0.2309699292),
        SIMD3(-1.2684380046,  2.6097574011, -0.3413193965),
        SIMD3(-0.0041960863, -0.7034186147,  1.7076147010))
    
    private static let xyztoRGB: simd_double3x3 = .init(
        SIMD3( 3.2404542,  -1.5371385, -0.4985314),
        SIMD3(-0.9692660,  1.8760108,  0.0415560),
        SIMD3( 0.0556434, -0.2040259,  1.0572252))
    
    private static let rgbToXYZ: simd_double3x3 = .init(
        SIMD3<Double>(0.4124564, 0.3575761, 0.1804375),
        SIMD3<Double>(0.2126729, 0.7151522, 0.0721750),
        SIMD3<Double>(0.0193339, 0.1191920, 0.9503041))

    private static let rgbToLMS: simd_double3x3 = .init(
        SIMD3(0.4122214708, 0.5363325363, 0.0514459929),
        SIMD3(0.2119034982, 0.6806995451, 0.1073969566),
        SIMD3(0.0883024619, 0.2817188376, 0.6299787005))

    private static let lmsToOKLAB: simd_double3x3 = .init(
        SIMD3( 0.2104542553,  0.7936177850, -0.0040720468),
        SIMD3( 1.9779984951, -2.4285922050,  0.4505937099),
        SIMD3( 0.0259040371,  0.7827717662, -0.8086757660))
    
    private static let delta = 6.0 / 29.0
    private static let threshold = delta * delta * delta
    private static let k = 3 * delta * delta
    private static let four29 = 4.0 / 29.0
    
    @inline(__always)
    private static func f(_ t: Double) -> Double {
        t > threshold ? cbrt(t) : t / k + four29
    }
    
    @inline(__always)
    private static func fInv(_ t: Double) -> Double {
        t > delta ? t * t * t : k * (t - four29)
    }
    
    private static let invGamma = 1.0 / 2.4
    
    @inline(__always)
    private static func rgbToLinear(_ c: Double) -> Double {
        let absC = abs(c)
        let res = absC <= 0.04045
            ? absC / 12.92
            : pow((absC + 0.055) / 1.055, 2.4)
        return c < 0 ? -res : res
    }
    
    @inline(__always)
    private static func rgbToNonlinear(_ c: Double) -> Double {
        let absC = abs(c)
        let res = absC <= 0.0031308
            ? 12.92 * absC
            : 1.055 * pow(absC, invGamma) - 0.055
        return c < 0 ? -res : res
    }
    
    private static func rgbToHSX(_ storage: SIMD4<Double>, isHSL: Bool = true) -> SIMD4<Double> {
        let (hue, delta, maxV, minV) = hueChromaMaxMin(red: storage.x, green: storage.y, blue: storage.z)
        if isHSL {
            let lightness = (maxV + minV) / 2
            let saturation = lightness > 0 && lightness < 1 ? delta / (1 - abs(2 * lightness - 1)) : 0
            return .init(hue, saturation, lightness, storage.w)
        }
        return .init(hue, maxV != 0 ? delta / maxV : 0, maxV, storage.w)
    }
    
    private static func hueChromaMaxMin(red: Double, green: Double, blue: Double) -> (hue: Double, delta: Double, maxV: Double, minV: Double) {
        let maxV = max(red, green, blue)
        let minV = min(red, green, blue)
        let delta = maxV - minV
        var hue: Double = 0
        if delta > 0 {
            hue = (maxV == red ? (green - blue) / delta
                : maxV == green ? (blue - red) / delta + 2
                : (red - green) / delta + 4) / 6
            if hue < 0 { hue += 1 }
        }
        return (hue, delta, maxV, minV)
    }

    private static func wrapUnit(_ x: Double) -> Double {
        let r = x.truncatingRemainder(dividingBy: 1.0)
        return r < 0 ? r + 1 : r
    }
    
    @inline(__always)
    static func hueToVector(_ h: Double) -> (x: Double, y: Double) {
        let θ = h * 2 * .pi
        return (cos(θ), sin(θ))
    }
    
    @inline(__always)
    static func hueFromVector(_ x: Double, _ y: Double) -> Double {
        let hue = atan2(y, x) / (2 * .pi)
        return hue < 0 ? hue + 1 : hue
        // return atan2(y, x) / (2 * .pi)
    }
    
    private static func hueFromVector(_ x: Double, _ y: Double, reference: Double) -> Double {
        hueFromVector(x, y) + reference - (reference - floor(reference))
    }
    
    @inline(__always)
    private static func hueFromCartesian(_ a: Double, _ b: Double) -> Double {
        var hue = atan2(b, a) / (2.0 * .pi)
        if hue < 0 { hue += 1 }
        return hue
    }
    
    @inline(__always)
    private static func cartesianFromPolar(hue: Double, chroma: Double) -> (a: Double, b: Double) {
        let hRad = hue * 2.0 * .pi
        return (chroma * cos(hRad), chroma * sin(hRad))
    }
    
    @inline(__always)
    private static func chromaFromCartesian(_ a: Double, _ b: Double) -> Double {
        sqrt(a * a + b * b)
    }
    
    private static func maxChroma(_ lightness: Double, _ hue: Double) -> Double {
        let bounds = getBounds(lightness)
        let theta = hue * 2 * Double.pi
        var minLen = Double.infinity
        for line in bounds {
            let length = line.intercept / (sin(theta) - line.slope * cos(theta))
            if length >= 0 {
                minLen = min(minLen, length)
            }
        }
        return minLen
    }
    
    private static let boundsMatrix: simd_double3x3 = .init(
        [ 3.240969941904521, -1.537383177570093, -0.498610760293     ],
        [-0.96924363628087,   1.87596750150772,   0.041555057407175 ],
        [ 0.055630079696993, -0.20397695888897,   1.056971514242878 ])
    
    private static func getBounds(_ lightness: Double) -> [(slope: Double, intercept: Double)] {
        let sub1 = pow(lightness + 16, 3) / 1560896
        let sub2 = sub1 > 0.0088564516 ? sub1 : lightness / 903.2962962
        var result: [(slope: Double, intercept: Double)] = []
        for c in 0..<3 {
            let m1 = boundsMatrix[c][0]
            let m2 = boundsMatrix[c][1]
            let m3 = boundsMatrix[c][2]
            for t in [0.0, 1.0] {
                let top1 = (284517 * m1 - 94839 * m3) * sub2
                let top2 = (838422 * m3 + 769860 * m2 + 731718 * m1) * lightness * sub2
                    - 769860 * t * lightness
                let bottom = (632260 * m3 - 126452 * m2) * sub2 + 126452 * t
                result.append((slope: top1 / bottom, intercept: top2 / bottom))
            }
        }
        return result
    }
    
    private static let xyzToDisplayP3: simd_double3x3 = .init(
        SIMD3( 2.493496911941425, -0.9313836179191239, -0.40271078445071684),
        SIMD3(-0.8294889695615747,  1.7626640603183463,  0.023624685841943577),
        SIMD3( 0.03584583024378447, -0.07617238926804182, 0.9568845240076872))
    
    private static let displayP3ToXZY: simd_double3x3 = .init(
        SIMD3(0.48657095, 0.26566769, 0.19821729),
        SIMD3(0.22897456, 0.69173852, 0.07928691),
        SIMD3(0.0,        0.04511338, 1.04394437))
    
    private enum D65 {
        static let x = 0.95047
        static let y = 1.00000
        static let z = 1.08883
        static let un = 4.0 * x / (x + y + z)
        static let vn = 9.0 * y / (x + y + z)
    }
}

extension ColorMath {
    enum JZAZBZ {
        fileprivate static let b: Double = 1.15
        fileprivate static let g: Double = 0.66
        fileprivate static let n: Double = 2610.0 / pow(2.0, 14.0)
        fileprivate static let ninv: Double = pow(2.0, 14.0) / 2610.0
        fileprivate static let c1: Double = 3424.0 / pow(2.0, 12.0)
        fileprivate static let c2: Double = 2413.0 / pow(2.0, 7.0)
        fileprivate static let c3: Double = 2392.0 / pow(2.0, 7.0)
        fileprivate static let p: Double = (1.7 * 2523.0) / pow(2.0, 5.0)
        fileprivate static let pinv: Double = pow(2.0, 5.0) / (1.7 * 2523.0)
        fileprivate static let d: Double = -0.56
        fileprivate static let d0: Double = 1.6295499532821566e-11
        
        fileprivate static let coneToXYZ: simd_double3x3 = .init(
            SIMD3(1.9242264357876067,  -1.0047923125953657,  0.037651404030618),
            SIMD3(0.35031676209499907,  0.7264811939316552, -0.06538442294808501),
            SIMD3(-0.09098281098284752, -0.3127282905230739,  1.5227665613052603))
        
        fileprivate static let iabToCone: simd_double3x3 = .init(
            SIMD3(1,                   0.13860504327153927,   0.05804731615611883),
            SIMD3(1,                  -0.1386050432715393,   -0.058047316156118904),
            SIMD3(1,                  -0.09601924202631895,  -0.81189189605603900))
        
        fileprivate static let XYZToCone: simd_double3x3 = .init(
            SIMD3(0.41478972, 0.579999, 0.0146480),
            SIMD3(-0.2015100, 1.120649, 0.0531008),
            SIMD3(-0.0166008, 0.264800, 0.6684799))
        
        fileprivate static let coneToIab: simd_double3x3 = .init(
            SIMD3(0.5, 0.5, 0.0),
            SIMD3(3.524000, -4.066708, 0.542708),
            SIMD3(0.199076, 1.096799, -1.295875))
        
        static func toXYZ(_ color: SIMD4<Double>) -> SIMD4<Double> {
            let (jz, az, bz, alpha) = (color.x, color.y, color.z, color.w)

            // 1. Recover Iz
            let iz = (jz + d0) / (1.0 + d - d * (jz + d0))
            // 2. Iab vector
            let iab = SIMD3(iz, az, bz)
            // 3. Iab → PQ-LMS
            let pqlms = iabToCone * iab
            // 4. PQ decode
            let lms = SIMD3(
                pqDecode(pqlms[0]),
                pqDecode(pqlms[1]),
                pqDecode(pqlms[2]))
            // 5. LMS → modified XYZ
            let modifiedXYZ = coneToXYZ * lms
            let za = modifiedXYZ.z
            // 6. Undo blue-curvature fix
            let xa = (modifiedXYZ.x + (b - 1.0) * za) / b
            let ya = (modifiedXYZ.y + (g - 1.0) * xa) / g
            return .init(xa, ya, za, alpha)
        }
        
        static func fromXYZ(_ xyz: SIMD4<Double>) -> SIMD4<Double> {
            // 1. Modify X and Y to minimize blue curvature
            let modifiedXYZ = SIMD3(
                b * xyz.x - (b - 1.0) * xyz.z,
                g * xyz.y - (g - 1.0) * xyz.x,
                xyz.z)
            // 2. Move to LMS cone domain using SIMD dot products
            let lms = XYZToCone * modifiedXYZ
            // 3. PQ-encode LMS
            let encodedLMS = SIMD3(
                pqEncode(lms[0]),
                pqEncode(lms[1]),
                pqEncode(lms[2]))
            // 4. Calculate Iz, az, bz via SIMD dot products
            let iab = coneToIab * encodedLMS
            // 5. Final Jz calculation
            let iz = iab[0]
            let jz = ((1.0 + d) * iz) / (1.0 + d * iz) - d0
            return .init(jz, iab[1], iab[2], xyz.w)
        }
        
        @inline(__always)
        private static func pqEncode(_ val: Double) -> Double {
            let v = val / 10000.0
            let vn = spow(v, n)
            let num = c1 + c2 * vn
            let denom = 1.0 + c3 * vn
            return spow(num / denom, p)
        }
        
        @inline(__always)
        private static func pqDecode(_ val: Double) -> Double {
            let vp = spow(val, pinv)
            let num = c1 - vp
            let denom = c3 * vp - c2
            return 10000.0 * spow(num / denom, ninv)
        }
        
        @inline(__always)
        private static func spow(_ val: Double, _ exp: Double) -> Double {
            return val < 0 ? -pow(-val, exp) : pow(val, exp)
        }
    }

}

extension ColorMath {
    enum OKLAB {
        static func fromHSX(_ storage: SIMD4<Double>, hsl: Bool) -> SIMD4<Double> {
            let (h, s, lOrV, alpha) = (storage.x, storage.y, storage.z, storage.w)
            
            let aUnit = cos(2.0 * .pi * h)
            let bUnit = sin(2.0 * .pi * h)
            
            // 1. Get Cusp and Max Saturation info
            let cusp = findCusp(a: aUnit, b: bUnit)
            let stMax = getStMax(a: aUnit, b: bUnit, cusp: cusp)
            let S_max = stMax[0]
            let T_max = stMax[1]
            let s0 = 0.5
            let k = 1 - s0 / S_max
            
            // 2. Derive L and C (Chroma)
            let L: Double
            if hsl {
                L = toeInv(lOrV) // Convert HSL Lightness back to OKLAB L
            } else {
                L = lOrV // In HSB, Value is treated as OKLAB L
            }
            
            // Saturation to Chroma formula
            let C = (s * T_max * s0) / (s0 + T_max - k * T_max * s)
            return .init(L, C * aUnit, C * bUnit, alpha)
        }
        
        static func toHSX(_ color: SIMD4<Double>, hsl: Bool) -> SIMD4<Double> {
            let (lightness, greenRed, blueYellow, alpha) = (color.x, color.y, color.z, color.w)
            let L = lightness
            let C = sqrt(greenRed * greenRed + blueYellow * blueYellow)
            
            var h = atan2(blueYellow, greenRed) / (2.0 * .pi)
            if h < 0 { h += 1 }
            
            let aUnit = C > 1e-6 ? greenRed / C : cos(2.0 * .pi * h)
            let bUnit = C > 1e-6 ? blueYellow / C : sin(2.0 * .pi * h)
            
            let cusp = findCusp(a: aUnit, b: bUnit)
            let stMax = getStMax(a: aUnit, b: bUnit, cusp: cusp)
            let S_max = stMax[0]
            let T_max = stMax[1]
            let s0 = 0.5
            let k = 1 - s0 / S_max
            
            // Chroma to Saturation formula
            let saturation = (C * (s0 + T_max)) / (T_max * s0 + T_max * k * C)
            
            // Lightness/Value component
            let light = hsl ? toe(L) : L
            return .init(h, saturation, light, alpha)
        }
        
        fileprivate static func getStMax(a: Double, b: Double, cusp: (L: Double, C: Double)) -> [Double] {
            let L = cusp.L
            let C = cusp.C
            return [C / L, C / (1.0 - L)]
        }
        
        fileprivate static func toe(_ x: Double) -> Double {
            if x <= 0 { return 0 }
            if x >= 1 { return x } // Linear for extended range > 1
            let k1 = 0.206
            let k2 = 0.03
            let k3 = (1.0 + k1) / (1.0 + k2)
            return 0.5 * (k3 * x - k1 + sqrt((k3 * x - k1) * (k3 * x - k1) + 4 * k2 * k3 * x))
        }
        
        fileprivate static func toeInv(_ x: Double) -> Double {
            if x <= 0 { return 0 }
            if x >= 1 { return x } // Linear for extended range > 1
            let k1 = 0.206
            let k2 = 0.03
            let k3 = (1.0 + k1) / (1.0 + k2)
            return (x * x + k1 * x) / (k3 * (x + k2))
        }
        
        fileprivate static func findCusp(a: Double, b: Double) -> (L: Double, C: Double) {
            let sCusp = computeMaxSaturation(a, b)
            let rgb = oklabToRGB(.init(1, sCusp * a, sCusp * b, 1))
            let maxRGB = max(rgbToLinear(rgb.x), max(rgbToLinear(rgb.y), rgbToLinear(rgb.z)))
            let lCusp = pow(1.0 / maxRGB, 1.0/3.0)
            return (lCusp, lCusp * sCusp)
        }
        
        fileprivate static func computeMaxSaturation(_ a: Double, _ b: Double) -> Double {
            let k0, k1, k2, k3, k4, wl, wm, ws: Double
            if (-1.88170328 * a - 0.80936493 * b > 1) {
                (k0, k1, k2, k3, k4) = (1.19086277, 1.76576728, 0.59662641, 0.75515197, 0.56771245)
                (wl, wm, ws) = (4.0767416621, -3.3077115913, 0.2309699292)
            } else if (1.81444104 * a - 1.19445276 * b > 1) {
                (k0, k1, k2, k3, k4) = (0.73956515, -0.45954404, 0.08285427, 0.1254107, 0.14503204)
                (wl, wm, ws) = (-1.2684380046, 2.6097574011, -0.3413193965)
            } else {
                (k0, k1, k2, k3, k4) = (1.35733652, -0.00915799, -1.1513021, -0.50559606, 0.00692167)
                (wl, wm, ws) = (-0.0041960863, -0.7034186147, 1.707614701)
            }
            
            var s = k0 + (k1 * a) + (k2 * b) + (k3 * a * a) + (k4 * a * b)
            let kl = 0.3963377774 * a + 0.2158037573 * b
            let km = -0.1055613458 * a - 0.0638541728 * b
            let ks = -0.0894841775 * a - 1.291485548 * b
            
            for _ in 0..<1 { // Halley step
                let l_ = 1 + s * kl, m_ = 1 + s * km, s_ = 1 + s * ks
                let l = l_*l_*l_, m = m_*m_*m_, sc = s_*s_*s_
                let f = wl*l + wm*m + ws*sc
                let f1 = 3 * (wl*kl*l_*l_ + wm*km*m_*m_ + ws*ks*s_*s_)
                let f2 = 6 * (wl*kl*kl*l_ + wm*km*km*m_ + ws*ks*ks*s_)
                s = s - (f * f1) / (f1 * f1 - 0.5 * f * f2)
            }
            return s
        }
    }
}

extension ColorMath {
    static func colorToRGB(_ color: SIMD4<Double>, colorspace: Anima.ColorSpace) -> SIMD4<Double> {
        switch colorspace {
        case .srgb: return color
        case .hsl:
            let hsb = hslToHSB(color)
            return hsbToRGB(hsb)
        case .hsb:
            return hsbToRGB(color)
        case .oklab:
            return oklabToRGB(color)
        case .oklch:
            let oklab = oklchToOKLAB(color)
            return oklabToRGB(oklab)
        case .okhsb:
            let oklab = okhsbToOKLAB(color)
            return oklabToRGB(oklab)
        case .okhsl:
            let oklab = okhslToOKLAB(color)
            return oklabToRGB(oklab)
        case .xyz:
            return xyzToRGB(color)
        case .lab:
            let xyz = labToXYZ(color)
            return xyzToRGB(xyz)
        case .lch:
            let lab = lchToLAB(color)
            let xyz = labToXYZ(lab)
            return xyzToRGB(xyz)
        case .luv:
            let xyz = luvToXYZ(color)
            return xyzToRGB(xyz)
        case .hpluv:
            let lchuv = hpluvTpLCHUV(color)
            let luv = lchuvToLUV(lchuv)
            let xyz = luvToXYZ(luv)
            return xyzToRGB(xyz)
        case .displayP3:
            let xyz = displayP3ToXYZ(color)
            return xyzToRGB(xyz)
        case .hwb:
            let hsb = hwbToHSB(color)
            return hsbToRGB(hsb)
        case .lchuv:
            let luv = lchuvToLUV(color)
            let xyz = luvToXYZ(luv)
            return xyzToRGB(xyz)
        case .hsluv:
            let lchuv = hsluvTOLCHUV(color)
            let luv = lchuvToLUV(lchuv)
            let xyz = luvToXYZ(luv)
            return xyzToRGB(xyz)
        case .jzczhz:
            let jzazbz = jzczhzTojzazbz(color)
            let xyz = jzazbzToXYZ(jzazbz)
            return xyzToRGB(xyz)
        case .jzazbz:
            let xyz = jzazbzToXYZ(color)
            return xyzToRGB(xyz)
        }
    }
    
    static func rgbToColorSpace(_ color: SIMD4<Double>, colorspace: Anima.ColorSpace) -> SIMD4<Double> {
        switch colorspace {
        case .srgb: return color
        case .hsl: return rgbToHSL(color)
        case .hsb:
            return rgbToHSB(color)
        case .oklab:
            return rgbToOKLAB(color)
        case .oklch:
            let oklab = rgbToOKLAB(color)
            return oklabToOKLCH(oklab)
        case .okhsb:
            let oklab = rgbToOKLAB(color)
            return oklabToOKHSB(oklab)
        case .okhsl:
            let oklab = rgbToOKLAB(color)
            return oklabToOKHSL(oklab)
        case .xyz:
            return rgbToXYZ(color)
        case .lab:
            let xyz = rgbToXYZ(color)
            return xyzToLAB(xyz)
        case .lch:
            let xyz = rgbToXYZ(color)
            let lab = xyzToLAB(xyz)
            return labToLCH(lab)
        case .luv:
            let xyz = rgbToXYZ(color)
            return xyzToLUV(xyz)
        case .hpluv:
            let xyz = rgbToXYZ(color)
            let luv = xyzToLUV(xyz)
            let lchuv = luvToLCHUV(luv)
            return lchuvToHPLUV(lchuv)
        case .displayP3:
            let xyz = rgbToXYZ(color)
            return xyzToDisplay3(xyz)
        case .hwb:
            let hsb = rgbToHSB(color)
            return hsbToHWB(hsb)
        case .lchuv:
            let xyz = rgbToXYZ(color)
            let luv = xyzToLUV(xyz)
            return luvToLCHUV(luv)
        case .hsluv:
            let xyz = rgbToXYZ(color)
            let luv = xyzToLUV(xyz)
            let lchuv = luvToLCHUV(luv)
            return lchuvToHSLUV(lchuv)
        case .jzczhz:
            let xyz = rgbToXYZ(color)
            let jzazbz = xyzToJZAZBZ(xyz)
            return jzazbzToJZCZHZ(jzazbz)
        case .jzazbz:
            let xyz = rgbToXYZ(color)
            return xyzToJZAZBZ(xyz)
        }
    }

    static func rgbToAnimatableArray(_ color: SIMD4<Double>, colorspace: Anima.ColorSpace) -> AnimatableArray<Double> {
        var color = rgbToColorSpace(color, colorspace: colorspace)
        if let hueIndex = colorspace.hueIndex {
            var vector = hueToVector(color[hueIndex])
            color[hueIndex] = vector.x
            return color.scalars + [vector.y]
        }
        return color.scalars + [0]
    }
    
    static func animatableArrayToRGB(_ array: AnimatableArray<Double>, colorspace: Anima.ColorSpace) -> SIMD4<Double> {
        var array = array
        if let hueIndex = colorspace.hueIndex {
            array[hueIndex] = hueFromVector(array[hueIndex], array[safe: 4] ?? 0)
        }
        return colorToRGB(SIMD4(array.prefix(4)), colorspace: colorspace)
    }
}

extension AnimatableArray where Element == Double {
    func toRGB() -> SIMD4<Double> {
        var elements = elements
        if elements.count < 5 {
            elements += Array(repeating: 0, count: 5 - elements.count)
        }
        if let hueIndex = colorSpace.hueIndex {
            elements[hueIndex] = ColorMath.hueFromVector(elements[hueIndex], elements[4])
        }
        return ColorMath.colorToRGB(SIMD4(elements.prefix(4)), colorspace: colorSpace)
    }
    
    init(_ simd: SIMD4<Double>, _ colorSpace: Anima.ColorSpace) {
        elements = simd.scalars
        elements.append(0)
        self.colorSpace = colorSpace
        guard let hueIndex = colorSpace.hueIndex else { return }
        let vector = ColorMath.hueToVector(elements[hueIndex])
        elements[hueIndex] = vector.x
        elements[4] = vector.y
    }
    
    func convert(to colorSpace: Anima.ColorSpace) -> Self {
        guard colorSpace != self.colorSpace else { return self }
        return .init(ColorMath.rgbToColorSpace(toRGB(), colorspace: colorSpace), colorSpace)
    }
}

/*
 import Accelerate

 /// The data for animating a color.
 public struct AnimatableColorData {
     var elements: [Double] = []
     let colorSpace: Anima.ColorSpace
     
     init(_ elements: [Double], _ colorSpace: Anima.ColorSpace = .srgb) {
         self.elements = elements
         self.colorSpace = colorSpace
     }
     
     public static let zero = Self([0,0,0,0,0])
 }

 extension AnimatableColorData: VectorArithmetic & AdditiveArithmetic {
     public static func + (lhs: Self, rhs: Self) -> Self {
         return Self(vDSP.add(lhs.elements, rhs.elements), lhs.colorSpace)
     }

     public static func - (lhs: Self, rhs: Self) -> Self {
         return Self(vDSP.subtract(lhs.elements, rhs.elements), lhs.colorSpace)
     }

     public mutating func scale(by rhs: Double) {
         elements = vDSP.multiply(rhs, elements)
     }

     public var magnitudeSquared: Double {
         vDSP.sum(vDSP.multiply(elements, elements))
     }
 }

 extension AnimatableColorData {
     func toRGB() -> SIMD4<Double> {
         var elements = elements
         if let hueIndex = colorSpace.hueIndex {
             elements[hueIndex] = ColorMath.hueFromVector(elements[hueIndex], elements[4])
         }
         return ColorMath.colorToRGB(SIMD4(elements.prefix(4)), colorspace: colorSpace)
     }
     
     func convert(to colorSpace: Anima.ColorSpace) -> Self {
         guard colorSpace != self.colorSpace else { return self }
         return .init(ColorMath.rgbToColorSpace(toRGB(), colorspace: colorSpace), colorSpace)
     }
     
     init(_ simd: SIMD4<Double>, _ colorSpace: Anima.ColorSpace) {
         elements = simd.scalars
         elements.append(0)
         self.colorSpace = colorSpace
         guard let hueIndex = colorSpace.hueIndex else { return }
         let vector = ColorMath.hueToVector(elements[hueIndex])
         elements[hueIndex] = vector.x
         elements[4] = vector.y
     }
 }
 */
