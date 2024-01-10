//
//  Rubberband.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import QuartzCore

/// Calculates the rubberbanding of a value.
public enum Rubberband {
    /// The default rubberbanding constant for a scroll view.
    public static let ScrollViewRubberBandingConstant = 0.55

    /**
     Rubberbands a floating point value based on the specified range and interval.

     - Parameters:
        - value: The floating point value to rubberband.
        - range: The range over which the value won't rubberband.
        - interval: The interval of the value.
        - coefficient: A multiplier to decay the value when it's being rubberbanded. Defaults to ``ScrollViewRubberBandingConstant``.
     */
    public static func value<Value: FloatingPointInitializable>(for value: Value, range: ClosedRange<Value>, interval: Value, coefficient: Value = Value(ScrollViewRubberBandingConstant)) -> Value {
        // * x = distance from the edge
        // * c = constant value, UIScrollView uses 0.55
        // * d = dimension, either width or height
        // b = (1.0 – (1.0 / ((x * c / d) + 1.0))) * d

        if range.contains(value) {
            return value
        }

        let d = interval

        if value > range.upperBound {
            let x = value - range.upperBound
            let x1 = ((x * coefficient / d) + 1.0)
            let b = (1.0 - (1.0 / x1)) * d
            return range.upperBound + b
        } else {
            let x = range.lowerBound - value
            let x1 = ((x * coefficient / d) + 1.0)
            let b = (1.0 - (1.0 / x1)) * d
            return range.lowerBound - b
        }
    }

    /**
     Rubberbands a floating point value based on the specified bounds size and content size.

     - Parameters:
        - value: The floating point value to rubberband.
        - boundsSize: The viewport dimension (i.e. the bounds along the axis of a scroll view)).
        - contentSize: The size of the content over which the value won't rubberband (i.e. the contentSize along the axis of a scroll view).
        - coefficient: A multiplier to decay the value when it's being rubberbanded. Defaults to ``ScrollViewRubberBandingConstant``.

     ```swift
     bounds.origin.x = rubberband(bounds.origin.x - translation.x, boundsSize: bounds.size.width, contentSize: contentSize.width)
     ```
     */
    public static func value<Value: FloatingPointInitializable>(for value: Value, boundsSize: Value, contentSize: Value, coefficient: Value = Value(ScrollViewRubberBandingConstant)) -> Value {
        var exceededContentsPositively = false
        let x: Value
        if (value + boundsSize) > contentSize {
            x = abs(contentSize - boundsSize - value)
            exceededContentsPositively = true
        } else if value < 0.0 {
            x = -value
        } else {
            return value
        }

        // (1.0 - (1.0 / ((x * c / d) + 1.0))) * d

        // Without this, the swift type checker is super slow.
        let x1 = (x * coefficient / boundsSize) + 1.0

        let rubberBandedAmount = ((1.0 - (1.0 / x1)) * boundsSize)

        // We're beyond the range
        if exceededContentsPositively {
            return rubberBandedAmount + contentSize - boundsSize
        } else { // We're beyond the range in the opposite direction
            return -rubberBandedAmount
        }
    }

    /**
     Rubberbands the frame inside the bounds.

     - Parameters:
        - frame: The frame to rubberband.
        - bounds: The bounds over which the frame won't rubberband.
        - coefficient: A multiplier to decay the value when it's being rubberbanded. Defaults to ``ScrollViewRubberBandingConstant``.
     */
    public static func value(for frame: CGRect, bounds: CGRect, coefficient: Double = ScrollViewRubberBandingConstant) -> CGRect {
        let x = value(for: frame.origin.x, boundsSize: frame.width, contentSize: bounds.width, coefficient: coefficient)
        let y = value(for: frame.origin.y, boundsSize: frame.height, contentSize: bounds.height, coefficient: coefficient)
        return CGRect(origin: CGPoint(x, y), size: frame.size)
    }
}
