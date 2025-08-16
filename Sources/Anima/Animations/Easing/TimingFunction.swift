//
//  TimingFunction.swift
//
//
//  Created by Florian Zand on 20.10.23.
//
//  Adopted from:
//  Advance, https://github.com/timdonnelly/Advance
//

import Foundation
import QuartzCore
import Accelerate

/**
 The timing function maps an input time normalized to the range `[0,1]` to an output time also in the range `[0,1]`. It's used to define the pacing of an animation as a timing curve.

 Example usage:
 ```swift
 let timingFunction = TimingFunction.easeIn
 let fractionComplete = 0.3
 let solvedFractionComplete = timingFunction.solve(at: fractionComplete)
 // 0.13
 ```

 > Tip:  ``Easing`` provides addtional timing functions.
 */
public struct TimingFunction: CustomStringConvertible {
    /// The name of the timing function.
    public let name: String
    
    let function: ((Double, Double) -> (Double))
    
    /// Initializes a timing function.
    public init(_ name: String? = nil, function: @escaping ((Double) -> (Double))) {
        self.function = { time,_ in
            function(time)
        }
        self.name = name ?? "function"
    }

    /// Initializes a bezier timing function with the given control points.
    public init(_ name: String? = nil, x1: Double, y1: Double, x2: Double, y2: Double) {
        let bezier = UnitBezier(x1: x1, y1: y1, x2: x2, y2: y2)
        self.function = { time, epsilon in
            bezier.solve(x: time, epsilon: epsilon)
        }
        // (4.0, 6.0)
        self.name = name ?? "\(bezier.description)"
    }
                    
    /// Initializes a timing function with Core Animation timing function.
    public init(_ caTimingFunction: CAMediaTimingFunction) {
        let controlPoints = caTimingFunction.controlPoints
        self.init(caTimingFunction.description, x1: controlPoints.x1, y1: controlPoints.y1, x2: controlPoints.x2, y2: controlPoints.y1)
    }
    
    /**
     Transforms the specified time.

     - Parameters:
        - fractionComplete: The fraction complete (between `0.0` and `1.0`).
        - epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated). The default value is `0.0001`.
     
     - Returns: The resulting output time.
     */
    public func solve(at fractionComplete: Double, epsilon: Double = 0.0001) -> Double {
        function(fractionComplete, epsilon)
    }

    /**
     Transforms the specified time.

     - Parameters:
        - fractionComplete: The fraction complete (between `0.0` and `1.0`).
        - duration: The duration of the solving value. It is used to calculate the required precision of the result.
     
     - Returns: The resulting output time.
     */
    public func solve(at fractionComplete: Double, duration: Double) -> Double {
        function(fractionComplete, (1.0 / (duration * 1000.0)))
    }
    
    public var description: String {
        "TimingFunction: \(name)"
    }
}

public extension TimingFunction {
    /// A linear timing function.
    static var linear: TimingFunction {
        TimingFunction("linear") { $0 }
    }

    /// The system default timing function. Use this function to ensure that the timing of your animations matches that of most system animations.
    static var `default`: TimingFunction {
        TimingFunction("`default`", x1: 0.25, y1: 0.1, x2: 0.25, y2: 1.0)
    }

    /// An `easeIn` timing function.
    static var easeIn: TimingFunction {
        TimingFunction("easeIn", x1: 0.42, y1: 0.0, x2: 1.0, y2: 1.0)
    }

    /// An `easeOut` timing function.
    static var easeOut: TimingFunction {
        TimingFunction("easeOut", x1: 0.0, y1: 0.0, x2: 0.58, y2: 1.0)
    }

    /// An `easeInEaseOut` timing function.
    static var easeInEaseOut: TimingFunction {
        TimingFunction("easeInEaseOut", x1: 0.42, y1: 0.0, x2: 0.58, y2: 1.0)
    }

    /// An `swiftOut` timing function, inspired by the default curve in Google Material Design.
    static var swiftOut: TimingFunction {
        TimingFunction("swiftOut", x1: 0.4, y1: 0.0, x2: 0.2, y2: 1.0)
    }
}


public extension TimingFunction {
    /// Additional easing time functions.
    enum Easing {
        // MARK: Quadratic

        /// An `easeInQuadic` timing function.
        public static var easeInQuadic = TimingFunction("easeInQuadic") { x in
            Easing.easeInQuadic(x)
        }

        /// An `easeOutQuadic` timing function.
        public static var easeOutQuadic = TimingFunction("easeOutQuadic") { x in
            Easing.easeOutQuadic(x)
        }

        /// An `easeInEaseOutQuadic` timing function.
        public static var easeInEaseOutQuadic = TimingFunction("easeInEaseOutQuadic") { x in
            Easing.easeInEaseOutQuadic(x)
        }

        // MARK: Cubic

        /// An `easeInCubic` timing function.
        public static var easeInCubic = TimingFunction("easeInCubic") { x in
            Easing.easeInCubic(x)
        }

        /// An `easeOutCubic` timing function.
        public static var easeOutCubic = TimingFunction("easeOutCubic") { x in
            Easing.easeOutCubic(x)
        }

        /// An `easeInEaseOutCubic` timing function.
        public static var easeInEaseOutCubic = TimingFunction("easeInEaseOutCubic") { x in
            Easing.easeInEaseOutCubic(x)
        }

        // MARK: Quartic

        /// An `easeInQuartic` timing function.
        public static var easeInQuartic = TimingFunction("easeInQuartic") { x in
            Easing.easeInQuartic(x)
        }

        /// An `easeOutQuartic` timing function.
        public static var easeOutQuartic = TimingFunction("easeOutQuartic") { x in
            Easing.easeOutQuartic(x)
        }

        /// An `easeInEaseOutQuartic` timing function.
        public static var easeInEaseOutQuartic = TimingFunction("easeInEaseOutQuartic") { x in
            Easing.easeInEaseOutQuartic(x)
        }

        // MARK: Quintic

        /// An `easeInQuintic` timing function.
        public static var easeInQuintic = TimingFunction("easeInQuintic") { x in
            Easing.easeInQuintic(x)
        }

        /// An `easeOutQuintic` timing function.
        public static var easeOutQuintic = TimingFunction("easeOutQuintic") { x in
            Easing.easeOutQuintic(x)
        }

        /// An `easeInEaseOutQuintic` timing function.
        public static var easeInEaseOutQuintic = TimingFunction("easeInEaseOutQuintic") { x in
            Easing.easeInEaseOutQuintic(x)
        }

        // MARK: Sinusoidal

        /// An `easeInSine` timing function.
        public static var easeInSine = TimingFunction("easeInSine") { x in
            Easing.easeInSine(x)
        }

        /// An `easeOutSine` timing function.
        public static var easeOutSine = TimingFunction("easeOutSine") { x in
            Easing.easeOutSine(x)
        }

        /// An `easeInEaseOutSine` timing function.
        public static var easeInEaseOutSine = TimingFunction("easeInEaseOutSine") { x in
            Easing.easeInEaseOutSine(x)
        }

        // MARK: Exponential

        /// An `easeInExpo` timing function.
        public static var easeInExponential = TimingFunction("easeInExponential") { x in
            Easing.easeInExponential(x)
        }

        /// An `easeOutExponential` timing function.
        public static var easeOutExponential = TimingFunction("easeOutExponential") { x in
            Easing.easeOutExponential(x)
        }

        /// An `easeInEaseOutExponential` timing function.
        public static var easeInEaseOutExponential = TimingFunction("easeInEaseOutExponential") { x in
            Easing.easeInEaseOutExponential(x)
        }

        // MARK: Circular

        /// An `easeInCircular` timing function.
        public static var easeInCircular = TimingFunction("easeInCircular") { x in
            Easing.easeInCircular(x)
        }

        /// An `easeOutCircular` timing function.
        public static var easeOutCircular = TimingFunction("easeOutCircullar") { x in
            Easing.easeOutCircular(x)
        }

        /// An `easeInEaseOutCircular` timing function.
        public static var easeInEaseOutCircular = TimingFunction("easeInEaseOutCircular") { x in
            Easing.easeInEaseOutCircular(x)
        }

        // MARK: Bounce

        /// An `easeInBounce` timing function.
        public static var easeInBounce = TimingFunction("easeInBounce") { x in
            Easing.easeInBounce(x)
        }

        /// An `easeOutBounce` timing function.
        public static var easeOutBounce = TimingFunction("easeOutBounce") { x in
            Easing.easeOutBounce(x)
        }

        /// An `easeInEaseOutBounce` timing function.
        public static var easeInEaseOutBounce = TimingFunction("easeInEaseOutBounce") { x in
            Easing.easeInEaseOutBounce(x)
        }

        // MARK: Elastic

        /// An `easeInElastic` timing function.
        public static var easeInElastic = TimingFunction("easeInElastic") { x in
            Easing.easeInElastic(x)
        }

        /// An `easeOutElastic` timing function.
        public static var easeOutElastic = TimingFunction("easeOutElastic") { x in
            Easing.easeOutElastic(x)
        }

        /// An `easeInEaseOutElastic` timing function.
        public static var easeInEaseOutElastic = TimingFunction("easeInEaseOutElastic") { x in
            Easing.easeInEaseOutElastic(x)
        }

        // MARK: Back

        /// An `easeInBack` timing function.
        public static var easeInBack = TimingFunction("easeInBack") { x in
            Easing.easeInBack(x)
        }

        /// An `easeOutBack` timing function.
        public static var easeOutBack = TimingFunction("easeOutBack") { x in
            Easing.easeOutBack(x)
        }

        /// An `easeInEaseOutBack` timing function.
        public static var easeInEaseOutBack = TimingFunction("easeInEaseOutBack") { x in
            Easing.easeInEaseOutBack(x)
        }
    }
}

extension TimingFunction.Easing {
    // MARK: Quadratic

    static func easeInQuadic(_ t: Double) -> Double {
        t * t
    }

    static func easeOutQuadic(_ t: Double) -> Double {
        -t * (t - 2)
    }

    static func easeInEaseOutQuadic(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t
        }
        _t -= 1.0
        return -0.5 * (_t * (_t - 2.0) - 1.0)
    }

    // MARK: Cubic

    static func easeInCubic(_ t: Double) -> Double {
        t * t * t
    }

    static func easeOutCubic(_ t: Double) -> Double {
        let _t = t - 1.0
        return _t * _t * _t + 1
    }

    static func easeInEaseOutCubic(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t * _t
        }
        _t -= 2.0
        return 0.5 * (_t * _t * _t + 2.0)
    }

    // MARK: Quartic

    static func easeInQuartic(_ t: Double) -> Double {
        t * t * t * t
    }

    static func easeOutQuartic(_ t: Double) -> Double {
        let _t = t - 1.0
        return -(_t * _t * _t * _t + 1)
    }

    static func easeInEaseOutQuartic(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t * _t * _t
        }
        _t -= 2.0
        return -0.5 * (_t * _t * _t * _t - 2.0)
    }

    // MARK: Quintic

    static func easeInQuintic(_ t: Double) -> Double {
        t * t * t * t * t
    }

    static func easeOutQuintic(_ t: Double) -> Double {
        let _t = t - 1.0
        return _t * _t * _t * _t * _t + 1
    }

    static func easeInEaseOutQuintic(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t * _t * _t * _t
        }
        _t -= 2.0
        return 0.5 * (_t * _t * _t * _t * _t + 2.0)
    }

    // MARK: Sinusoidal

    static func easeInSine(_ t: Double) -> Double {
        -cos(t * (Double.pi / 2.0)) + 1.0
    }

    static func easeOutSine(_ t: Double) -> Double {
        sin(t * (Double.pi / 2.0))
    }

    static func easeInEaseOutSine(_ t: Double) -> Double {
        -0.5 * (cos(Double.pi * t) - 1.0)
    }

    // MARK: Exponential

    static func easeInExponential(_ t: Double) -> Double {
        pow(2.0, 10.0 * (t - 1.0))
    }

    static func easeOutExponential(_ t: Double) -> Double {
        -pow(2.0, -10.0 * t) + 1.0
    }

    static func easeInEaseOutExponential(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * pow(2.0, 10.0 * (_t - 1.0))
        }
        _t -= 1.0
        return 0.5 * (-pow(2.0, -10.0 * _t) + 2.0)
    }

    // MARK: Circular

    static func easeInCircular(_ t: Double) -> Double {
        -(sqrt(1.0 - t * t) - 1.0)
    }

    static func easeOutCircular(_ t: Double) -> Double {
        let _t = t - 1.0
        return sqrt(1.0 - _t * _t)
    }

    static func easeInEaseOutCircular(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return -0.5 * (sqrt(1.0 - _t * _t) - 1.0)
        }
        _t -= 2.0
        return 0.5 * (sqrt(1.0 - _t * _t) + 1.0)
    }

    // MARK: Bounce

    static func easeInBounce(_ x: Double) -> Double {
        1 - easeOutBounce(1 - x)
    }

    static func easeOutBounce(_ x: Double) -> Double {
        if x < 1 / 2.75 {
            return 7.5625 * x * x
        } else if x < 2 / 2.75 {
            return 7.5625 * (x - 1.5 / 2.75) * (x - 1.5) + 0.75
        } else if x < 2.5 / 2.75 {
            return 7.5625 * (x - 2.25 / 2.75) * (x - 2.25) + 0.9375
        } else {
            return 7.5625 * (x - 2.625 / 2.75) * (x - 2.625) + 0.984375
        }
    }

    static func easeInEaseOutBounce(_ x: Double) -> Double {
        if x < 0.5 {
            return (1 - easeOutBounce(1 - 2 * x)) / 2
        } else {
            return (1 + easeOutBounce(2 * x - 1)) / 2
        }
    }

    // MARK: Elastic

    static func easeInElastic(_ x: Double) -> Double {
        if x == 0 {
            return 0
        } else if x == 1 {
            return 1
        } else {
            return 0 - pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * ((2 * .pi) / 3))
        }
    }

    static func easeOutElastic(_ x: Double) -> Double {
        if x == 0 {
            return 0
        } else if x == 1 {
            return 1
        } else {
            return pow(2, -10 * x) * sin((x * 10 - 0.75) * ((2 * .pi) / 3)) + 1
        }
    }

    static func easeInEaseOutElastic(_ x: Double) -> Double {
        if x == 0 {
            return 0
        } else if x == 1 {
            return 1
        } else if x < 0.5 {
            return 0 - (pow(2, 20 * x - 10) * sin((20 * x - 11.125) * ((2 * .pi) / 4.5))) / 2
        } else {
            return (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * ((2 * .pi) / 4.5))) / 2 + 1
        }
    }

    // MARK: Back

    static func easeInBack(_ x: Double) -> Double {
        2.70158 * x * x * x - 1.70158 * x * x
    }

    static func easeOutBack(_ x: Double) -> Double {
        1 + 2.70158 * pow(x - 1, 3) + 1.70158 * pow(x - 1, 2)
    }

    static func easeInEaseOutBack(_ x: Double) -> Double {
        if x < 0.5 {
            return (pow(2 * x, 2) * (7.189819 * x - 2.5949095)) / 2
        } else {
            return (pow(2 * x - 2, 2) * (3.5949095 * (x * 2 - 2) + 2.5949095) + 2) / 2
        }
    }
}

extension TimingFunction {
    /// A bezier curve that can be used to calculate timing functions.
    struct UnitBezier: Hashable, Sendable, CustomStringConvertible {
        /// The first point of the bezier.
        public var first: CGPoint {
            didSet {
                first = CGPoint(first.x.clamped(max: 1.0), first.y.clamped(max: 1.0))
            }
        }

        /// The second point of the bezier.
        public var second: CGPoint {
            didSet {
                second = CGPoint(second.x.clamped(max: 1.0), second.y.clamped(max: 1.0))
            }
        }

        /// Creates a new `UnitBezier` instance with the specified points.
        public init(first: CGPoint, second: CGPoint) {
            self.first = CGPoint(first.x.clamped(max: 1.0), first.y.clamped(max: 1.0))
            self.second = CGPoint(second.x.clamped(max: 1.0), second.y.clamped(max: 1.0))
        }

        /// Creates a new `UnitBezier` instance with the specified points.
        public init(x1: Double, y1: Double, x2: Double, y2: Double) {
            self.init(first: CGPoint(x1, y1), second: CGPoint(x2, y2))
        }

        /**
         Calculates the resulting `y` for given `x`.

         - Parameters:
            - x: The value to solve for.
            - epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated).
         - Returns: The solved `y` value.
         */
        public func solve(x: Double, epsilon: Double) -> Double {
            UnitBezierSolver(p1x: first.x, p1y: first.y, p2x: second.x, p2y: second.y).solve(x: x, eps: epsilon)
        }

        /**
         Calculates the resulting `y` for given `x`.

         - Parameters:
            - x: The value to solve for.
            - duration: The duration of the solving value. It is used to calculate the required precision of the result.
         - Returns: The solved `y` value.
         */
        public func solve(x: Double, duration: Double) -> Double {
            UnitBezierSolver(p1x: first.x, p1y: first.y, p2x: second.x, p2y: second.y).solve(x: x, eps: 1.0 / (duration * 1000.0))
        }
        
        public var description: String {
            "((\(first.x), \(first.y)), (\(second.x), \(second.y)))"
        }
    }
}

private struct UnitBezierSolver {
    private let ax: Double
    private let bx: Double
    private let cx: Double

    private let ay: Double
    private let by: Double
    private let cy: Double

    init(p1x: Double, p1y: Double, p2x: Double, p2y: Double) {
        // Calculate the polynomial coefficients, implicit first and last control points are (0,0) and (1,1).
        cx = 3.0 * p1x
        bx = 3.0 * (p2x - p1x) - cx
        ax = 1.0 - cx - bx

        cy = 3.0 * p1y
        by = 3.0 * (p2y - p1y) - cy
        ay = 1.0 - cy - by
    }

    func solve(x: Double, eps: Double) -> Double {
        sampleCurveY(t: solveCurveX(x: x, eps: eps))
    }
    
    func velocity(x: Double, eps: Double = 1e-6) -> Double {
        let t = solveCurveX(x: x, eps: eps)
        let dx = sampleCurveDerivativeX(t: t)
        let dy = sampleCurveDerivativeY(t: t)

        guard dx != 0 else { return 0.0 }
        return dy / dx
    }

    private func sampleCurveDerivativeY(t: Double) -> Double {
        (3.0 * ay * t + 2.0 * by) * t + cy
    }

    private func sampleCurveX(t: Double) -> Double {
        ((ax * t + bx) * t + cx) * t
    }

    private func sampleCurveY(t: Double) -> Double {
        ((ay * t + by) * t + cy) * t
    }

    private func sampleCurveDerivativeX(t: Double) -> Double {
        (3.0 * ax * t + 2.0 * bx) * t + cx
    }

    private func solveCurveX(x: Double, eps: Double) -> Double {
        var t0 = 0.0
        var t1 = 0.0
        var t2 = 0.0
        var x2 = 0.0
        var d2 = 0.0

        // First try a few iterations of Newton's method -- normally very fast.
        t2 = x
        for _ in 0 ..< 8 {
            x2 = sampleCurveX(t: t2) - x
            if abs(x2) < eps {
                return t2
            }
            d2 = sampleCurveDerivativeX(t: t2)
            if abs(d2) < 1e-6 {
                break
            }
            t2 = t2 - x2 / d2
        }

        // Fall back to the bisection method for reliability.
        t0 = 0.0
        t1 = 1.0
        t2 = x

        if t2 < t0 {
            return t0
        }
        if t2 > t1 {
            return t1
        }

        while t0 < t1 {
            x2 = sampleCurveX(t: t2)
            if abs(x2 - x) < eps {
                return t2
            }
            if x > x2 {
                t0 = t2
            } else {
                t1 = t2
            }
            t2 = (t1 - t0) * 0.5 + t0
        }

        return t2
    }
}
