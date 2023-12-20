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
 
 Example usage:
 ```swift
 let timingFunction = TimingFunction.easeIn
 let time = 0.3
 let solvedTime = timingFunction.solve(at: time)
 // 0.13
 ```

 > Tip:  ``Easing`` provides addtional timing functions.
 */
public enum TimingFunction {
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
        case .bezier(let unitBezier):
            return unitBezier.solve(x: time, epsilon: 1.0 / (duration * 1000.0))
        case .function(let function):
            return function(time)
        }
    }
}

extension TimingFunction {
    /// A linear timing function.
    public static var linear: TimingFunction {
        return TimingFunction.function { $0 }
    }
    
    /// The system default timing function. Use this function to ensure that the timing of your animations matches that of most system animations.
    public static var `default`: TimingFunction {
        return TimingFunction(x1: 0.25, y1: 0.1, x2: 0.25, y2: 1.0)
    }
    
    /// A `easeIn` timing function.
    public static var easeIn: TimingFunction {
        return TimingFunction(x1: 0.42, y1: 0.0, x2: 1.0, y2: 1.0)
    }
    
    /// A `easeOut` timing function.
    public static var easeOut: TimingFunction {
        return TimingFunction(x1: 0.0, y1: 0.0, x2: 0.58, y2: 1.0)
    }
    
    /// A `easeInEaseOut` timing function.
    public static var easeInEaseOut: TimingFunction {
        return TimingFunction(x1: 0.42, y1: 0.0, x2: 0.58, y2: 1.0)
    }
    
    /// A `swiftOut` timing function, inspired by the default curve in Google Material Design.
    public static var swiftOut: TimingFunction {
        return TimingFunction(x1: 0.4, y1: 0.0, x2: 0.2, y2: 1.0)
    }
}

extension TimingFunction {
    /// Additional easing time functions.
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
        
        /// A `easeInEaseOutQuad` timing function.
        public static var easeInEaseOutQuad = TimingFunction.function({ x in
            return Easing.easeInEaseOutQuad(x)
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
        
        /// A `easeInEaseOutCubic` timing function.
        public static var easeInEaseOutCubic = TimingFunction.function({ x in
            return Easing.easeInEaseOutCubic(x)
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
        
        /// A `easeInEaseOutQuart` timing function.
        public static var easeInEaseOutQuart = TimingFunction.function({ x in
            return Easing.easeInEaseOutQuart(x)
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
        
        /// A `easeInEaseOutQuint` timing function.
        public static var easeInEaseOutQuint = TimingFunction.function({ x in
            return Easing.easeInEaseOutQuint(x)
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
        
        /// A `easeInEaseOutSine` timing function.
        public static var easeInEaseOutSine = TimingFunction.function({ x in
            return Easing.easeInEaseOutSine(x)
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
        
        /// A `easeInEaseOutExpo` timing function.
        public static var easeInEaseOutExpo = TimingFunction.function({ x in
            return Easing.easeInEaseOutExpo(x)
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
        
        /// A `easeInEaseOutCirc` timing function.
        public static var easeInEaseOutCirc = TimingFunction.function({ x in
            return Easing.easeInEaseOutCirc(x)
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
        
        /// A `easeInEaseOutBounce` timing function.
        public static var easeInEaseOutBounce = TimingFunction.function({ x in
            return Easing.easeInEaseOutBounce(x)
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
        
        /// A `easeInEaseOutElastic` timing function.
        public static var easeInEaseOutElastic = TimingFunction.function({ x in
            return Easing.easeInEaseOutElastic(x)
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
        
        /// A `easeInEaseOutBack` timing function.
        public static var easeInEaseOutBack = TimingFunction.function({ x in
            return Easing.easeInEaseOutBack(x)
        })
    }
}

extension TimingFunction.Easing {
    //MARK: Quadratic
    
    static func easeInQuad(_ t: Double) -> Double {
        return t * t
    }
    
    static func easeOutQuad(_ t: Double) -> Double {
        return -t * (t - 2)
    }
    
    static func easeInEaseOutQuad(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * _t * _t
        }
        _t -= 1.0
        return -0.5 * (_t * (_t - 2.0) - 1.0)
    }
    
    //MARK: Cubic
    
    static func easeInCubic(_ t: Double) -> Double {
        return t * t * t
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
    
    //MARK: Quartic
    
    static func easeInQuart(_ t: Double) -> Double {
        return t * t * t * t
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
    
    //MARK: Quintic
    
    static func easeInQuint(_ t: Double) -> Double {
        return t * t * t * t * t
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
    
    //MARK: Sinusoidal
    
    static func easeInSine(_ t: Double) -> Double {
        return -cos(t * (Double.pi/2.0)) + 1.0
    }
    
    static func easeOutSine(_ t: Double) -> Double {
        return sin(t * (Double.pi/2.0))
    }
    
    static func easeInEaseOutSine(_ t: Double) -> Double {
        return -0.5 * (cos(Double.pi * t) - 1.0)
    }
    
    //MARK: Exponential
    
    static func easeInExpo(_ t: Double) -> Double {
        return pow(2.0, 10.0 * (t - 1.0))
    }
    
    static func easeOutExpo(_ t: Double) -> Double {
        return (-pow(2.0, -10.0 * t) + 1.0)
    }
    
    static func easeInEaseOutExpo(_ t: Double) -> Double {
        var _t = t / 0.5
        if _t < 1.0 {
            return 0.5 * pow(2.0, 10.0 * (_t - 1.0))
        }
        _t -= 1.0
        return 0.5 * (-pow(2.0, -10.0 * _t) + 2.0)
    }
    
    //MARK: Circular
    
    static func easeInCirc(_ t: Double) -> Double {
        return -(sqrt(1.0 - t * t) - 1.0)
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
    
    //MARK: Bounce
    
    static func easeInBounce(_ x: Double) -> Double {
        return 1 - easeOutBounce(1 - x)
    }
    
    static func easeOutBounce(_ x: Double) -> Double {
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
    
    static func easeInEaseOutBounce(_ x: Double) -> Double {
        if (x < 0.5) {
            return (1 - easeOutBounce(1 - 2 * x)) / 2
        } else {
            return (1 + easeOutBounce(2 * x - 1)) / 2
        }
    }
    
    //MARK: Elastic
    
    static func easeInElastic(_ x: Double) -> Double {
        if (x == 0) {
            return 0
        } else if (x == 1) {
            return 1
        } else {
            return 0 - pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * ((2 * .pi) / 3))
        }
    }

    static func easeOutElastic(_ x: Double) -> Double {
        if (x == 0) {
            return 0
        } else if (x == 1) {
            return 1
        } else {
            return pow(2, -10 * x) * sin((x * 10 - 0.75) * ((2 * .pi) / 3)) + 1
        }
    }

    static func easeInEaseOutElastic(_ x: Double) -> Double {
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
    
    static func easeInBack(_ x: Double) -> Double {
        return 2.70158 * x * x * x - 1.70158 * x * x
    }

    static func easeOutBack(_ x: Double) -> Double {
        return 1 + 2.70158 * pow(x - 1, 3) + 1.70158 * pow(x - 1, 2)
    }

    static func easeInEaseOutBack(_ x: Double) -> Double {
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
        if lhs.name != "Function", lhs.name == rhs.name {
            return true
        }
        return false
    }
}

extension TimingFunction: CustomStringConvertible {
    /// The name of the timing function.
    public var name: String {
        switch self {
        case .linear:
            return "Linear"
        case .default:
            return "default"
        case .easeIn:
            return "EaseIn"
        case .easeOut:
            return "EaseOut"
        case .easeInEaseOut:
            return "EaseInEaseOut"
        case .swiftOut:
            return "SwiftOut"
        case Easing.easeInCirc:
            return "EaseInCirc"
        case Easing.easeOutCirc:
            return "EaseOutCirc"
        case Easing.easeInEaseOutCirc:
            return "EaseInEaseOutCirc"
        case Easing.easeInCubic:
            return "EaseInCubic"
        case Easing.easeOutCubic:
            return "EaseOutCubic"
        case Easing.easeInEaseOutCubic:
            return "EaseInEaseOutCubic"
        case Easing.easeInBack:
            return "EaseInBack"
        case Easing.easeOutBack:
            return "EaseOutBack"
        case Easing.easeInEaseOutBack:
            return "EaseInEaseOutBack"
        case Easing.easeInQuint:
            return "EaseInQuint"
        case Easing.easeOutQuint:
            return "EaseOutQuint"
        case Easing.easeInEaseOutQuint:
            return "EaseInEaseOutQuint"
        case Easing.easeInBounce:
            return "EaseInBounce"
        case Easing.easeOutBounce:
            return "EaseOutBounce"
        case Easing.easeInEaseOutBounce:
            return "EaseInEaseOutBounce"
        case Easing.easeInElastic:
            return "EaseInElastic"
        case Easing.easeOutElastic:
            return "EaseOutElastic"
        case Easing.easeInEaseOutElastic:
            return "EaseInEaseOutElastic"
        case Easing.easeInQuart:
            return "EaseInQuart"
        case Easing.easeOutQuart:
            return "EaseOutQuart"
        case Easing.easeInEaseOutQuart:
            return "EaseInEaseOutQuart"
        case Easing.easeInExpo:
            return "EaseInExpo"
        case Easing.easeOutExpo:
            return "EaseOutExpo"
        case Easing.easeInEaseOutExpo:
            return "EaseInEaseOutExpo"
        case Easing.easeInSine:
            return "EaseInSine"
        case Easing.easeOutSine:
            return "EaseOutSine"
        case Easing.easeInEaseOutSine:
            return "EaseInEaseOutSine"
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
