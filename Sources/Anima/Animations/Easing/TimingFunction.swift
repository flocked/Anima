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


/**
 The timing function maps an input time normalized to the range `[0,1]` to an output time also in the range `[0,1]`. It's used to define the pacing of an animation as a timing curve.
 
 ```swift
 let timingFunction = TimingFunction.easeIn
 let time = 0.3
 let solvedTime = timingFunction.solve(at: time)
 // 0.13
 ```

 > Tip:  ``Easing`` provides addtional timing functions.
 */
public enum TimingFunction {
    /// No easing.
    case linear
    
    /// The specified unit bezier is used to drive the timing function.
    case bezier(UnitBezier)
    
    /// The specified function is used as timing function.
    case function((Double)->(Double))
    
    /// Initializes a bezier timing function with the given control points.
    public init(x1: Double, y1: Double, x2: Double, y2: Double) {
        self = .bezier(UnitBezier(x1: x1, y1: y1, x2: x2, y2: y2))
    }
        
    /**
     Transforms the specified time.
     
     - Parameters:
        - x: The input time (ranges between 0.0 and 1.0).
        - epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated). The default value is `0.0001`.
     - Returns: The resulting output time.
     */
    public func solve(at time: Double, epsilon: Double = 0.0001) -> Double {
        switch self {
        case .linear:
            return time
        case .bezier(let unitBezier):
            return unitBezier.solve(x: time, epsilon: epsilon)
        case .function(let function):
            return function(time)
        }
    }
    
    /**
     Transforms the specified time.
     
     - Parameters:
        - x: The input time (ranges between 0.0 and 1.0).
        - duration: The duration of the solving value. It is used to calculate the required precision of the result.
     - Returns: The resulting output time.
     */
    public func solve(at time: Double, duration: Double) -> Double {
        switch self {
        case .linear:
            return time
        case .bezier(let unitBezier):
            return unitBezier.solve(x: time, epsilon: 1.0 / (duration * 1000.0))
        case .function(let function):
            return function(time)
        }
    }
}

extension TimingFunction {
    /// A `easeIn` timing function, equivalent to `kCAMediaTimingFunctionEaseIn`.
    public static var easeIn: TimingFunction {
        return TimingFunction(x1: 0.42, y1: 0.0, x2: 1.0, y2: 1.0)
    }
    
    /// A `easeOut` timing function, equivalent to `kCAMediaTimingFunctionEaseOut`.
    public static var easeOut: TimingFunction {
        return TimingFunction(x1: 0.0, y1: 0.0, x2: 0.58, y2: 1.0)
    }
    
    /// A `easeInEaseOut` timing function, equivalent to `kCAMediaTimingFunctionEaseInEaseOut`.
    public static var easeInEaseOut: TimingFunction {
        return TimingFunction(x1: 0.42, y1: 0.0, x2: 0.58, y2: 1.0)
    }
    
    /// A `swiftOut` timing function, inspired by the default curve in Google Material Design.
    public static var swiftOut: TimingFunction {
        return TimingFunction(x1: 0.4, y1: 0.0, x2: 0.2, y2: 1.0)
    }
    
    /// The system default timing function. Use this function to ensure that the timing of your animations matches that of most system animations.
    public static var `default`: TimingFunction {
        return TimingFunction(x1: 0.25, y1: 0.1, x2: 0.25, y2: 1.0)
    }
}

extension TimingFunction {
    public struct Easing {
        
        //MARK: Quadratic

        /// A `easeInQuad` timing function.
        public static var easeInQuad = TimingFunction.function({ x in
            return Easing.easeInQuad(x)
        })
        
        /// A `easeOutQuad` timing function.
        public static var easeOutQuad = TimingFunction.function({ x in
            return Easing.easeOutQuad(x)
        })
        
        /// A `easeInOutQuad` timing function.
        public static var easeInOutQuad = TimingFunction.function({ x in
            return Easing.easeInOutQuad(x)
        })
        
        //MARK: Cubic
        
        /// A `easeInCubic` timing function.
        public static var easeInCubic = TimingFunction.function({ x in
            return Easing.easeInCubic(x)
        })
        
        /// A `easeOutCubic` timing function.
        public static var easeOutCubic = TimingFunction.function({ x in
            return Easing.easeOutCubic(x)
        })
        
        /// A `easeInOutCubic` timing function.
        public static var easeInOutCubic = TimingFunction.function({ x in
            return Easing.easeInOutCubic(x)
        })
        
        //MARK: Quartic
        
        /// A `easeInQuart` timing function.
        public static var easeInQuart = TimingFunction.function({ x in
            return Easing.easeInQuart(x)
        })
        
        /// A `easeOutQuart` timing function.
        public static var easeOutQuart = TimingFunction.function({ x in
            return Easing.easeOutQuart(x)
        })
        
        /// A `easeInOutQuart` timing function.
        public static var easeInOutQuart = TimingFunction.function({ x in
            return Easing.easeInOutQuart(x)
        })
        
        //MARK: Quintic
        
        /// A `easeInQuint` timing function.
        public static var easeInQuint = TimingFunction.function({ x in
            return Easing.easeInQuint(x)
        })
        
        /// A `easeOutQuint` timing function.
        public static var easeOutQuint = TimingFunction.function({ x in
            return Easing.easeOutQuint(x)
        })
        
        /// A `easeInOutQuint` timing function.
        public static var easeInOutQuint = TimingFunction.function({ x in
            return Easing.easeInOutQuint(x)
        })
        
        //MARK: Sinusoidal
        
        /// A `easeInSine` timing function.
        public static var easeInSine = TimingFunction.function({ x in
            return Easing.easeInSine(x)
        })
        
        /// A `easeOutSine` timing function.
        public static var easeOutSine = TimingFunction.function({ x in
            return Easing.easeOutSine(x)
        })
        
        /// A `easeInOutSine` timing function.
        public static var easeInOutSine = TimingFunction.function({ x in
            return Easing.easeInOutSine(x)
        })
        
        //MARK: Exponential
        
        /// A `easeInExpo` timing function.
        public static var easeInExpo = TimingFunction.function({ x in
            return Easing.easeInExpo(x)
        })
        
        /// A `easeOutExpo` timing function.
        public static var easeOutExpo = TimingFunction.function({ x in
            return Easing.easeOutExpo(x)
        })
        
        /// A `easeInOutExpo` timing function.
        public static var easeInOutExpo = TimingFunction.function({ x in
            return Easing.easeInOutExpo(x)
        })
        
        //MARK: Circular
        
        /// A `easeInCirc` timing function.
        public static var easeInCirc = TimingFunction.function({ x in
            return Easing.easeInCirc(x)
        })
        
        /// A `easeOutCirc` timing function.
        public static var easeOutCirc = TimingFunction.function({ x in
            return Easing.easeOutCirc(x)
        })
        
        /// A `easeInOutCirc` timing function.
        public static var easeInOutCirc = TimingFunction.function({ x in
            return Easing.easeInOutCirc(x)
        })
        
        //MARK: Bounce
        
        /// A `easeInBounce` timing function.
        public static var easeInBounce = TimingFunction.function({ x in
            return Easing.easeInBounce(x)
        })
        
        /// A `easeOutBounce` timing function.
        public static var easeOutBounce = TimingFunction.function({ x in
            return Easing.easeOutBounce(x)
        })
        
        /// A `easeInOutBounce` timing function.
        public static var easeInOutBounce = TimingFunction.function({ x in
            return Easing.easeInOutBounce(x)
        })
        
        //MARK: Elastic
        
        /// A `easeInElastic` timing function.
        public static var easeInElastic = TimingFunction.function({ x in
            return Easing.easeInElastic(x)
        })
        
        /// A `easeOutElastic` timing function.
        public static var easeOutElastic = TimingFunction.function({ x in
            return Easing.easeOutElastic(x)
        })
        
        /// A `easeInOutElastic` timing function.
        public static var easeInOutElastic = TimingFunction.function({ x in
            return Easing.easeInOutElastic(x)
        })
        
        //MARK: Back
        
        /// A `easeInBack` timing function.
        public static var easeInBack = TimingFunction.function({ x in
            return Easing.easeInBack(x)
        })
        
        /// A `easeOutBack` timing function.
        public static var easeOutBack = TimingFunction.function({ x in
            return Easing.easeOutBack(x)
        })
        
        /// A `easeInOutBack` timing function.
        public static var easeInOutBack = TimingFunction.function({ x in
            return Easing.easeInOutBack(x)
        })
    }
}

extension TimingFunction.Easing {
    //MARK: Quadratic
    
    internal static func easeInQuad(_ t: Double) -> Double {
        return t * t
    }
    
    internal static func easeOutQuad(_ t: Double) -> Double {
        return -t * (t - 2)
    }
    
    internal static func easeInOutQuad(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t
        }
        _t -= 1.0
        return -0.5 * (_t * (_t - 2.0) - 1.0)
    }
    
    //MARK: Cubic
    
    internal static func easeInCubic(_ t: Double) -> Double {
        return t * t * t
    }
    
    internal static func easeOutCubic(_ t: Double) -> Double {
        let _t = t - 1.0
        return _t * _t * _t + 1
    }
    
    internal static func easeInOutCubic(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t * _t
        }
        _t -= 2.0
        return 0.5 * (_t * _t * _t + 2.0)
    }
    
    //MARK: Quartic
    
    internal static func easeInQuart(_ t: Double) -> Double {
        return t * t * t * t
    }
    
    internal static func easeOutQuart(_ t: Double) -> Double {
        let _t = t - 1.0
        return -(_t * _t * _t * _t + 1)
    }
    
    internal static func easeInOutQuart(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t * _t * _t
        }
        _t -= 2.0
        return -0.5 * (_t * _t * _t * _t - 2.0)
    }
    
    //MARK: Quintic
    
    internal static func easeInQuint(_ t: Double) -> Double {
        return t * t * t * t * t
    }
    
    internal static func easeOutQuint(_ t: Double) -> Double {
        let _t = t - 1.0
        return _t * _t * _t * _t * _t + 1
    }
    
    internal static func easeInOutQuint(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t * _t * _t * _t
        }
        _t -= 2.0
        return 0.5 * (_t * _t * _t * _t * _t + 2.0)
    }
    
    //MARK: Sinusoidal
    
    internal static func easeInSine(_ t: Double) -> Double {
        return -cos(t * (Double.pi/2.0)) + 1.0
    }
    
    internal static func easeOutSine(_ t: Double) -> Double {
        return sin(t * (Double.pi/2.0))
    }
    
    internal static func easeInOutSine(_ t: Double) -> Double {
        return -0.5 * (cos(Double.pi * t) - 1.0)
    }
    
    //MARK: Exponential
    
    internal static func easeInExpo(_ t: Double) -> Double {
        return pow(2.0, 10.0 * (t - 1.0))
    }
    
    internal static func easeOutExpo(_ t: Double) -> Double {
        return (-pow(2.0, -10.0 * t) + 1.0)
    }
    
    internal static func easeInOutExpo(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * pow(2.0, 10.0 * (_t - 1.0))
        }
        _t -= 1.0
        return 0.5 * (-pow(2.0, -10.0 * _t) + 2.0)
    }
    
    //MARK: Circular
    
    internal static func easeInCirc(_ t: Double) -> Double {
        return -(sqrt(1.0 - t * t) - 1.0)
    }
    
    internal static func easeOutCirc(_ t: Double) -> Double {
        let _t = t - 1.0
        return sqrt(1.0 - _t * _t)
    }
    
    internal static func easeInOutCirc(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return -0.5 * (sqrt(1.0 - _t * _t) - 1.0)
        }
        _t -= 2.0
        return 0.5 * (sqrt(1.0 - _t * _t) + 1.0)
    }
    
    //MARK: Bounce
    
    internal static func easeInBounce(_ x: Double) -> Double {
        return 1 - easeOutBounce(1 - x)
    }
    
    internal static func easeOutBounce(_ x: Double) -> Double {
        if (x < 1 / 2.75) {
            return 7.5625 * x * x
        } else if (x < 2 / 2.75) {
            return 7.5625 * (x - 1.5 / 2.75) * (x - 1.5) + 0.75
        } else if (x < 2.5 / 2.75) {
            return 7.5625 * (x - 2.25 / 2.75) * (x - 2.25) + 0.9375
        } else {
            return 7.5625 * (x - 2.625 / 2.75) * (x - 2.625) + 0.984375
        }
    }
    
    internal static func easeInOutBounce(_ x: Double) -> Double {
        if (x < 0.5) {
            return (1 - easeOutBounce(1 - 2 * x)) / 2
        } else {
            return (1 + easeOutBounce(2 * x - 1)) / 2
        }
    }
    
    //MARK: Elastic
    
    internal static func easeInElastic(_ x: Double) -> Double {
        if (x == 0) {
            return 0
        } else if (x == 1) {
            return 1
        } else {
            return 0 - pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * ((2 * .pi) / 3))
        }
    }

    internal static func easeOutElastic(_ x: Double) -> Double {
        if (x == 0) {
            return 0
        } else if (x == 1) {
            return 1
        } else {
            return pow(2, -10 * x) * sin((x * 10 - 0.75) * ((2 * .pi) / 3)) + 1
        }
    }

    internal static func easeInOutElastic(_ x: Double) -> Double {
        if (x == 0) {
            return 0
        } else if (x == 1) {
            return 1
        } else if (x < 0.5) {
            return 0 - (pow(2, 20 * x - 10) * sin((20 * x - 11.125) * ((2 * .pi) / 4.5))) / 2
        } else {
            return (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * ((2 * .pi) / 4.5))) / 2 + 1
        }
    }
    
    //MARK: Back
    
    internal static func easeInBack(_ x: Double) -> Double {
        return 2.70158 * x * x * x - 1.70158 * x * x
    }

    internal static func easeOutBack(_ x: Double) -> Double {
        return 1 + 2.70158 * pow(x - 1, 3) + 1.70158 * pow(x - 1, 2)
    }

    internal static func easeInOutBack(_ x: Double) -> Double {
        if (x < 0.5) {
            return (pow(2 * x, 2) * (7.189819 * x - 2.5949095)) / 2
        } else {
            return (pow(2 * x - 2, 2) * (3.5949095 * (x * 2 - 2) + 2.5949095) + 2) / 2
        }
    }
}

extension TimingFunction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: TimingFunction, rhs: TimingFunction) -> Bool {
        switch (lhs, rhs) {
        case (.linear, .linear), (.easeOut, .easeOut), (.easeInEaseOut, .easeInEaseOut), (.swiftOut, .swiftOut), (.easeIn, .easeIn):
            return true
        case (.bezier(let bezier1), .bezier(let bezier2)):
            return bezier1 == bezier2
        default:
            return false
        }
    }
}

extension TimingFunction: CustomStringConvertible {
    /// The name of the timing function.
    public var name: String {
        switch self {
        case .linear:
            return "Linear"
        case .easeIn:
            return "EaseIn"
        case .easeOut:
            return "EaseOut"
        case .easeInEaseOut:
            return "EaseInEaseOut"
        case .swiftOut:
            return "SwiftOut"
        case TimingFunction.Easing.easeInCirc:
            return "EaseInCirc"
        case TimingFunction.Easing.easeOutCirc:
            return "EaseOutCirc"
        case TimingFunction.Easing.easeInOutCirc:
            return "EaseInOutCirc"
        case TimingFunction.Easing.easeInCubic:
            return "EaseInCubic"
        case TimingFunction.Easing.easeOutCubic:
            return "EaseOutCubic"
        case TimingFunction.Easing.easeInOutCubic:
            return "EaseInOutCubic"
        case TimingFunction.Easing.easeInBack:
            return "EaseInBack"
        case TimingFunction.Easing.easeOutBack:
            return "EaseOutBack"
        case TimingFunction.Easing.easeInOutBack:
            return "EaseInOutBack"
        case TimingFunction.Easing.easeInQuint:
            return "EaseInQuint"
        case TimingFunction.Easing.easeOutQuint:
            return "EaseOutQuint"
        case TimingFunction.Easing.easeInOutQuint:
            return "EaseInOutQuint"
        case TimingFunction.Easing.easeInBounce:
            return "EaseInBounce"
        case TimingFunction.Easing.easeOutBounce:
            return "EaseOutBounce"
        case TimingFunction.Easing.easeInOutBounce:
            return "EaseInOutBounce"
        case TimingFunction.Easing.easeInElastic:
            return "EaseInElastic"
        case TimingFunction.Easing.easeOutElastic:
            return "EaseOutElastic"
        case TimingFunction.Easing.easeInOutElastic:
            return "EaseInOutElastic"
        case TimingFunction.Easing.easeInQuart:
            return "EaseInQuart"
        case TimingFunction.Easing.easeOutQuart:
            return "EaseOutQuart"
        case TimingFunction.Easing.easeInOutQuart:
            return "EaseInOutQuart"
        case TimingFunction.Easing.easeInExpo:
            return "EaseInExpo"
        case TimingFunction.Easing.easeOutExpo:
            return "EaseOutExpo"
        case TimingFunction.Easing.easeInOutExpo:
            return "EaseInOutExpo"
        case TimingFunction.Easing.easeInSine:
            return "EaseInSine"
        case TimingFunction.Easing.easeOutSine:
            return "EaseOutSine"
        case TimingFunction.Easing.easeInOutSine:
            return "EaseInOutSine"
        case .function(_):
            return "Function"
        case .bezier(let unitBezier):
            return "Bezier(x1: \(unitBezier.first.x),  y1: \(unitBezier.first.y), x2: \(unitBezier.second.x), y2: \(unitBezier.second.y))"
        }
    }
    
    public var description: String {
        return "TimingFunction: \(name)"
    }
}

#if canImport(QuartzCore)

import QuartzCore

extension TimingFunction {
    /// Initializes a timing function with a unit bezier derived from the given Core Animation timing function.
    public init(_ coreAnimationTimingFunction: CAMediaTimingFunction) {
        let controlPoints: [(x: Double, y: Double)] = (0...3).map { (index) in
            var rawValues: [Float] = [0.0, 0.0]
            coreAnimationTimingFunction.getControlPoint(at: index, values: &rawValues)
            return (x: Double(rawValues[0]), y: Double(rawValues[1]))
        }
        
        self.init(
            x1: controlPoints[1].x,
            y1: controlPoints[1].y,
            x2: controlPoints[2].x,
            y2: controlPoints[2].y)
    }
}

#endif
