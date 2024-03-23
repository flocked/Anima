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

/**
 The timing function maps an input time normalized to the range `[0,1]` to an output time also in the range `[0,1]`. It's used to define the pacing of an animation as a timing curve.

 Example usage:
 ```swift
 let timingFunction = TimingFunction.easeIn
 let time = 0.3
 let solvedTime = timingFunction.solve(at: time)
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
        self = Self(name, bezier: .init(x1: x1, y1: y1, x2: x2, y2: y2))
    }
                
    /// Initializes a bezier timing function.
    public init(_ name: String? = nil, bezier: UnitBezier) {
        self.function = { time, epsilon in
            bezier.solve(x: time, epsilon: epsilon)
        }
        // (4.0, 6.0)
        self.name = name ?? "\(bezier.description)"
    }
    
    /// Initializes a timing function with Core Animation timing function.
    init(_ caTimingFunction: CAMediaTimingFunction) {
        let controlPoints = caTimingFunction.controlPoints
        self.init(caTimingFunction.description, x1: controlPoints.x1, y1: controlPoints.y1, x2: controlPoints.x2, y2: controlPoints.y1)
    }
    
    /**
     Transforms the specified time.

     - Parameters:
        - time: The input time (ranges between 0.0 and 1.0).
        - epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated). The default value is `0.0001`.
     
     - Returns: The resulting output time.
     */
    public func solve(at time: Double, epsilon: Double = 0.0001) -> Double {
        function(time, epsilon)
    }

    /**
     Transforms the specified time.

     - Parameters:
        - time: The input time (ranges between 0.0 and 1.0).
        - duration: The duration of the solving value. It is used to calculate the required precision of the result.
     
     - Returns: The resulting output time.
     */
    public func solve(at time: Double, duration: Double) -> Double {
        function(time, (1.0 / (duration * 1000.0)))
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

    /// A `easeIn` timing function.
    static var easeIn: TimingFunction {
        TimingFunction("easeIn", x1: 0.42, y1: 0.0, x2: 1.0, y2: 1.0)
    }

    /// A `easeOut` timing function.
    static var easeOut: TimingFunction {
        TimingFunction("easeOut", x1: 0.0, y1: 0.0, x2: 0.58, y2: 1.0)
    }

    /// A `easeInEaseOut` timing function.
    static var easeInEaseOut: TimingFunction {
        TimingFunction("easeInEaseOut", x1: 0.42, y1: 0.0, x2: 0.58, y2: 1.0)
    }

    /// A `swiftOut` timing function, inspired by the default curve in Google Material Design.
    static var swiftOut: TimingFunction {
        TimingFunction("swiftOut", x1: 0.4, y1: 0.0, x2: 0.2, y2: 1.0)
    }
}


public extension TimingFunction {
    /// Additional easing time functions.
    enum Easing {
        // MARK: Quadratic

        /// A `easeInQuad` timing function.
        public static var easeInQuad = TimingFunction("easeInQuad") { x in
            Easing.easeInQuad(x)
        }

        /// A `easeOutQuad` timing function.
        public static var easeOutQuad = TimingFunction("easeOutQuad") { x in
            Easing.easeOutQuad(x)
        }

        /// A `easeInEaseOutQuad` timing function.
        public static var easeInEaseOutQuad = TimingFunction("easeInEaseOutQuad") { x in
            Easing.easeInEaseOutQuad(x)
        }

        // MARK: Cubic

        /// A `easeInCubic` timing function.
        public static var easeInCubic = TimingFunction("easeInCubic") { x in
            Easing.easeInCubic(x)
        }

        /// A `easeOutCubic` timing function.
        public static var easeOutCubic = TimingFunction("easeOutCubic") { x in
            Easing.easeOutCubic(x)
        }

        /// A `easeInEaseOutCubic` timing function.
        public static var easeInEaseOutCubic = TimingFunction("easeInEaseOutCubic") { x in
            Easing.easeInEaseOutCubic(x)
        }

        // MARK: Quartic

        /// A `easeInQuart` timing function.
        public static var easeInQuart = TimingFunction("easeInQuart") { x in
            Easing.easeInQuart(x)
        }

        /// A `easeOutQuart` timing function.
        public static var easeOutQuart = TimingFunction("easeOutQuart") { x in
            Easing.easeOutQuart(x)
        }

        /// A `easeInEaseOutQuart` timing function.
        public static var easeInEaseOutQuart = TimingFunction("easeInEaseOutQuart") { x in
            Easing.easeInEaseOutQuart(x)
        }

        // MARK: Quintic

        /// A `easeInQuint` timing function.
        public static var easeInQuint = TimingFunction("easeInQuint") { x in
            Easing.easeInQuint(x)
        }

        /// A `easeOutQuint` timing function.
        public static var easeOutQuint = TimingFunction("easeOutQuint") { x in
            Easing.easeOutQuint(x)
        }

        /// A `easeInEaseOutQuint` timing function.
        public static var easeInEaseOutQuint = TimingFunction("easeInEaseOutQuint") { x in
            Easing.easeInEaseOutQuint(x)
        }

        // MARK: Sinusoidal

        /// A `easeInSine` timing function.
        public static var easeInSine = TimingFunction("easeInSine") { x in
            Easing.easeInSine(x)
        }

        /// A `easeOutSine` timing function.
        public static var easeOutSine = TimingFunction("easeOutSine") { x in
            Easing.easeOutSine(x)
        }

        /// A `easeInEaseOutSine` timing function.
        public static var easeInEaseOutSine = TimingFunction("easeInEaseOutSine") { x in
            Easing.easeInEaseOutSine(x)
        }

        // MARK: Exponential

        /// A `easeInExpo` timing function.
        public static var easeInExpo = TimingFunction("easeInExpo") { x in
            Easing.easeInExpo(x)
        }

        /// A `easeOutExpo` timing function.
        public static var easeOutExpo = TimingFunction("easeOutExpo") { x in
            Easing.easeOutExpo(x)
        }

        /// A `easeInEaseOutExpo` timing function.
        public static var easeInEaseOutExpo = TimingFunction("easeInEaseOutExpo") { x in
            Easing.easeInEaseOutExpo(x)
        }

        // MARK: Circular

        /// A `easeInCirc` timing function.
        public static var easeInCirc = TimingFunction("easeInCirc") { x in
            Easing.easeInCirc(x)
        }

        /// A `easeOutCirc` timing function.
        public static var easeOutCirc = TimingFunction("easeOutCirc") { x in
            Easing.easeOutCirc(x)
        }

        /// A `easeInEaseOutCirc` timing function.
        public static var easeInEaseOutCirc = TimingFunction("easeInEaseOutCirc") { x in
            Easing.easeInEaseOutCirc(x)
        }

        // MARK: Bounce

        /// A `easeInBounce` timing function.
        public static var easeInBounce = TimingFunction("easeInBounce") { x in
            Easing.easeInBounce(x)
        }

        /// A `easeOutBounce` timing function.
        public static var easeOutBounce = TimingFunction("easeOutBounce") { x in
            Easing.easeOutBounce(x)
        }

        /// A `easeInEaseOutBounce` timing function.
        public static var easeInEaseOutBounce = TimingFunction("easeInEaseOutBounce") { x in
            Easing.easeInEaseOutBounce(x)
        }

        // MARK: Elastic

        /// A `easeInElastic` timing function.
        public static var easeInElastic = TimingFunction("easeInElastic") { x in
            Easing.easeInElastic(x)
        }

        /// A `easeOutElastic` timing function.
        public static var easeOutElastic = TimingFunction("easeOutElastic") { x in
            Easing.easeOutElastic(x)
        }

        /// A `easeInEaseOutElastic` timing function.
        public static var easeInEaseOutElastic = TimingFunction("easeInEaseOutElastic") { x in
            Easing.easeInEaseOutElastic(x)
        }

        // MARK: Back

        /// A `easeInBack` timing function.
        public static var easeInBack = TimingFunction("easeInBack") { x in
            Easing.easeInBack(x)
        }

        /// A `easeOutBack` timing function.
        public static var easeOutBack = TimingFunction("easeOutBack") { x in
            Easing.easeOutBack(x)
        }

        /// A `easeInEaseOutBack` timing function.
        public static var easeInEaseOutBack = TimingFunction("easeInEaseOutBack") { x in
            Easing.easeInEaseOutBack(x)
        }
    }
}

extension TimingFunction.Easing {
    // MARK: Quadratic

    static func easeInQuad(_ t: Double) -> Double {
        t * t
    }

    static func easeOutQuad(_ t: Double) -> Double {
        -t * (t - 2)
    }

    static func easeInEaseOutQuad(_ t: Double) -> Double {
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

    static func easeInQuart(_ t: Double) -> Double {
        t * t * t * t
    }

    static func easeOutQuart(_ t: Double) -> Double {
        let _t = t - 1.0
        return -(_t * _t * _t * _t + 1)
    }

    static func easeInEaseOutQuart(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t * _t * _t
        }
        _t -= 2.0
        return -0.5 * (_t * _t * _t * _t - 2.0)
    }

    // MARK: Quintic

    static func easeInQuint(_ t: Double) -> Double {
        t * t * t * t * t
    }

    static func easeOutQuint(_ t: Double) -> Double {
        let _t = t - 1.0
        return _t * _t * _t * _t * _t + 1
    }

    static func easeInEaseOutQuint(_ t: Double) -> Double {
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

    static func easeInExpo(_ t: Double) -> Double {
        pow(2.0, 10.0 * (t - 1.0))
    }

    static func easeOutExpo(_ t: Double) -> Double {
        -pow(2.0, -10.0 * t) + 1.0
    }

    static func easeInEaseOutExpo(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * pow(2.0, 10.0 * (_t - 1.0))
        }
        _t -= 1.0
        return 0.5 * (-pow(2.0, -10.0 * _t) + 2.0)
    }

    // MARK: Circular

    static func easeInCirc(_ t: Double) -> Double {
        -(sqrt(1.0 - t * t) - 1.0)
    }

    static func easeOutCirc(_ t: Double) -> Double {
        let _t = t - 1.0
        return sqrt(1.0 - _t * _t)
    }

    static func easeInEaseOutCirc(_ t: Double) -> Double {
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
