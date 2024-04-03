import Foundation
import SwiftUI


struct CubicFunction {
    /**
     Calculates the value of the Catmull-Rom spline at a given fraction given the control points.
     
     - Parameters:
        - p0: Control point 1.
        - p1: Control point 2.
        - p2: Control point 3.
        - p3: Control point 4.
        - t: Time along the spline.
     
     - Returns: The point along the spline for the given time.
     */
    static func catmullRom<V: VectorArithmetic>(p0: V, p1: V, p2: V, p3: V, t: Double) -> V {
        cardinalCubicFunction(p0: p0, p1: p1, p2: p2, p3: p3, tension: 0.0, t: t)
    }
    
    /**
     Calculates the value of the cardinal spline at a given fraction given the control points.

     - Parameters:
        - p0: Control point 1.
        - p1: Control point 2.
        - p2: Control point 3.
        - p3: Control point 4.
        - tension: The parameter c is a tension parameter that must be in the interval (0,1). In some sense, this can be interpreted as the "length" of the tangent. c=1 will yield all zero tangents, and c=0 yields a CatmullñRom spline.
        - t: Time along the spline.
     
     - Returns: The point along the spline for the given time.
     */
    static func cardinalCubicFunction<V: VectorArithmetic>(p0: V, p1: V, p2: V, p3: V, tension _tension: Double, t: Double) -> V {
        var tension = _tension
        if tension < 0 {
            tension = 0
        } else if tension > 1 {
            tension = 1
        }
        let t2 = t * t
        let t3 = t2 * t
        
        // (p0 - p1) * 2
        //  (p3 - p2) * 2
        
        /*
         * Formula: s(-ttt + 2tt - t)P1 + s(-ttt + tt)P2 + (2ttt - 3tt + 1)P2 + s(ttt - 2tt + t)P3 + (-2ttt + 3tt)P3 + s(ttt - tt)P4
         */
        let s: Double = (1 - tension) / 2
        let b1: Double = s * ((-t3 + (2 * t2)) - t) // s(-t3 + 2 t2 - t)P1
        let b2: Double = s * (-t3 + t2) + (2 * t3 - 3 * t2 + 1) // s(-t3 + t2)P2 + (2 t3 - 3 t2 + 1)P2
        let b3: Double = s * (t3 - 2 * t2 + t) + (-2 * t3 + 3 * t2) // s(t3 - 2 t2 + t)P3 + (-2 t3 + 3 t2)P3
        let b4: Double = s * (t3 - t2) // s(t3 - t2)P4
            
        return (p0 * b1 + p1 * b2 + p2 * b3 + p3 * b4)
    }
}
