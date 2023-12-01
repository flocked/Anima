//
//  Range+.swift
//  
//
//  Created by Florian Zand on 27.09.23.
//

import Foundation

internal extension ClosedRange where Bound == Int {
    /**
     Shifts the range by the specified offset value.
     
     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shfted(by offset: Int) -> Self {
        lowerBound+offset...upperBound+offset
    }
    
    /**
     Returns a Boolean value indicating whether the given range is contained within the range.
     
     - Parameters range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: ClosedRange<Int>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     Returns a Boolean value indicating whether the given range is contained within the range.
     
     - Parameters range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: Range<Int>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     Returns a Boolean value indicating whether the given values are contained within the range.
     
     - Parameters values: The values to check for containment.
     - Returns: `true` if values are contained in the range; otherwise, `false`.
     */
    func contains<S>(_ values: S) -> Bool where S: Sequence<Int> {
        for value in values.uniqued() {
            if self.contains(value) == false {
                return false
            }
        }
        return true
    }
}

internal extension Range where Bound == Int {
    /**
     Shifts the range by the specified offset value.
     
     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shfted(by offset: Int) -> Self {
        lowerBound+offset..<upperBound+offset
    }
    
    /**
     Returns a Boolean value indicating whether the given range is contained within the range.
     
     - Parameters range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: ClosedRange<Int>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     Returns a Boolean value indicating whether the given range is contained within the range.
     
     - Parameters range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: Range<Int>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     Returns a Boolean value indicating whether the given values are contained within the range.
     
     - Parameters values: The values to check for containment.
     - Returns: `true` if values are contained in the range; otherwise, `false`.
     */
    func contains<S>(_ values: S) -> Bool where S: Sequence<Int> {
        for value in values.uniqued() {
            if self.contains(value) == false {
                return false
            }
        }
        return true
    }
}

internal extension ClosedRange where Bound: BinaryInteger {
    /// The closed range as `NSRange`.
    var nsRange: NSRange {
        let length = self.upperBound-self.lowerBound-1
        return NSRange(location: Int(self.lowerBound), length: Int(length))
    }
}

internal extension Range where Bound: BinaryInteger {
    /// The range as `NSRange`.
    var nsRange: NSRange {
        let length = self.upperBound-self.lowerBound
        return NSRange(location: Int(self.lowerBound), length: Int(length))
    }
}

internal extension ClosedRange where Bound: BinaryInteger {
    /// The range as floating range.
    func toFloating() -> ClosedRange<Float> {
        Float(self.lowerBound)...Float(self.upperBound)
    }
}

internal extension Range where Bound: BinaryInteger {
    /// The range as floating range.
    func toFloating() -> Range<Float> {
        Float(self.lowerBound)..<Float(self.upperBound)
    }
}
