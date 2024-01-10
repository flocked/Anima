//
//  Comparable+Clamp.swift
//  
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

extension Comparable {
    /**
     Clamps the value to the specified closed range.
     
     - Parameter range: The closed range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(self, range.upperBound))
    }
}

extension Comparable where Self: ExpressibleByIntegerLiteral {
    /**
     Clamps the value to a minimum value.

     - Parameter minValue: The minimum value to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(min minValue: Self) -> Self {
        max(minValue, self)
    }

    /**
     Clamps the value to a maximum value. It uses 0 as minimum value.
     
     - Parameter maxValue: The maximum value to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(max maxValue: Self) -> Self {
        clamped(to: 0 ... maxValue)
    }
}
