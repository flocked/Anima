//
//  Rubberband.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import QuartzCore

/// The standard rubberbanding constant for `UIScrollView`/`NSScrollView`.
public let ScrollViewRubberBandingConstant = 0.55

public func rubberband<Value: FloatingPointInitializable>(value: Value, range: ClosedRange<Value>, interval: Value, c: Value = Value(ScrollViewRubberBandingConstant)) -> Value {
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
        let x1 = ((x * c / d) + 1.0)
        let b = (1.0 - (1.0 / x1)) * d
        return range.upperBound + b
    } else {
        let x = range.lowerBound - value
        let x1 = ((x * c / d) + 1.0)
        let b = (1.0 - (1.0 / x1)) * d
        return range.lowerBound - b
    }
}


/**
 Rubberbands a floating point value based on a given coefficient and range.

 - Parameters:
   - value: The floating point value to rubberband.
   - coefficient: A multiplier to decay the value when it's being rubberbanded. Defaults to `UIScrollViewRubberBandingConstant`.
   - boundsSize: The viewport dimension (i.e. the bounds along the axis of a scroll view)).
   - contentSize: The size of the content over which the value won't rubberband (i.e. the contentSize along the axis of a scroll view).

 ```swift
 bounds.origin.x = rubberband(bounds.origin.x - translation.x, boundsSize: bounds.size.width, contentSize: contentSize.width)
 ```
 */
public func rubberband<Value: FloatingPointInitializable>(_ value: Value, coefficient: Value = Value(ScrollViewRubberBandingConstant), boundsSize: Value, contentSize: Value) -> Value {
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

