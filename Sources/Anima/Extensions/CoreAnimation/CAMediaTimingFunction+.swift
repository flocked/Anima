//
//  CAMediaTimingFunction+.swift
//
//
//  Created by Florian Zand on 23.03.24.
//

#if canImport(QuartzCore)
import Foundation
import QuartzCore

extension CAMediaTimingFunction {
    var controlPoints: (x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        var rawValues: [Float] = [0.0, 0.0]
        getControlPoint(at: 1, values: &rawValues)
        let x1 = CGFloat(rawValues[0])
        let y1 = CGFloat(rawValues[1])
        getControlPoint(at: 2, values: &rawValues)
        let x2 = CGFloat(rawValues[0])
        let y2 = CGFloat(rawValues[1])
        return (x1, y1, x2, y2)
    }
}
#endif
