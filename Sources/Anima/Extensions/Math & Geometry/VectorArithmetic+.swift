//
//  VectorArithmetic+.swift
//
//
//  Created by Florian Zand on 20.10.23.
//

import Foundation
import SwiftUI

internal extension VectorArithmetic {
    static func * (lhs: inout Self, rhs: Double)  {
        lhs.scale(by: rhs)
    }
    
    static func * (lhs: Self, rhs: Double) -> Self {
        return lhs.scaled(by: rhs)
    }
    
    static func / (lhs: inout Self, rhs: Double)  {
        lhs.scale(by: 1.0 / rhs)
    }
    
    static func / (lhs: Self, rhs: Double) -> Self {
        return lhs.scaled(by: 1.0 / rhs)
    }
    
    static prefix func - (lhs: Self) -> Self {
        lhs * -1
    }
}

