//
//  UnitBezier.swift
//
//
//  Created by Florian Zand on 20.10.23.
//
//  Adopted from:
//  Advance, https://github.com/timdonnelly/Advance
//

import Accelerate
import Foundation

public extension TimingFunction {
    /// A bezier curve that can be used to calculate timing functions.
    struct UnitBezier: Hashable, Sendable {
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
