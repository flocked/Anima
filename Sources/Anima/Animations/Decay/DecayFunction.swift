//
//  DecayFunction.swift
//  
//  Adopted from:
//  Motion. Created by Adam Bell on 8/20/20.
//
//  Created by Florian Zand on 09.11.23.
//

import Foundation
import SwiftUI

/// The default deceleration rate for a scroll view.
public let ScrollViewDecelerationRate = 0.998

/// A fast deceleration rate for a scroll view.
public let ScrollViewDecelerationRateFast = 0.99

/**
 The decay function calculates values with a decaying acceleration.

 Example usage:
 ```swift
 let destination = DecayFunction.destination(value: 5.0, velocity: 100.0)
 // 54.95
 
 let duration = DecayFunction.duration(value: 5.0, velocity: 100.0)
 // 3.05
 
 let velocity = DecayFunction.velocity(fromValue: 5.0, toValue: 200.0)
 // 390.4
 ```
 */
public struct DecayFunction: Hashable {
    /// The rate at which the velocity decays over time.
    public var decelerationRate: Double {
        didSet {
            updateConstants()
        }
    }

    /// A cached invocation of `1.0 / (log(decelerationRate) * 1000.0)`
    private(set) public var one_ln_decelerationRate_1000: Double = 0.0
    
    /**
      Initializes a decay function.

      - Parameters:
         - decelerationRate: The rate at which the velocity decays over time. Defaults to ``ScrollViewDecelerationRate``.
      */
    public init(decelerationRate: Double = ScrollViewDecelerationRate) {
         self.decelerationRate = decelerationRate
         updateConstants()
     }

     fileprivate mutating func updateConstants() {
         self.one_ln_decelerationRate_1000 =  1.0 / (log(decelerationRate) * 1000.0)
     }
    
    /// Updates the current value and velocity of a decay animation.
    public func update<V>(value: inout V, velocity: inout V, deltaTime: TimeInterval) where V : VectorArithmetic {
        let d_1000_dt = pow(decelerationRate, deltaTime * 1000.0)
        
        // Analytic decay equation with constants extracted out.
        value = value + velocity.scaled(by:  ((d_1000_dt - 1.0) * one_ln_decelerationRate_1000))
        
        // Velocity is the derivative of the above equation
        velocity = velocity.scaled(by: d_1000_dt)
    }
    
    /// Updates the current value and velocity of a decay animation.
    public func update<V>(value: inout V, velocity: inout V, deltaTime: TimeInterval) where V : AnimatableProperty {
        var valueAnimatableData = value.animatableData
        var velocityAnimatableData = velocity.animatableData
        update(value: &valueAnimatableData, velocity: &velocityAnimatableData, deltaTime: deltaTime)
        value = V(valueAnimatableData)
        velocity = V(velocityAnimatableData)
    }
}

extension DecayFunction {
    /**
     Solves the destination for the specified value and starting velocity.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decelerationRate: The decay constant.

     - Returns: The destination when the decay reaches zero velocity.
     */
    public static func destination<V>(value: V, velocity: V, decelerationRate: Double = ScrollViewDecelerationRate) -> V where V : VectorArithmetic {
        let decay = log(decelerationRate) * 1000
        let toValue = value - velocity.scaled(by: 1.0 / decay)
        return toValue
    }
    
    /**
     Solves the destination for the specified value and starting velocity.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decelerationRate: The decay constant.
        - integralizeValue: A Boolean value that indicates whether the destionation value should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues. The default value is 'false'.

     - Returns: The destination when the decay reaches zero velocity.
     */
    public static func destination<V>(value: V, velocity: V, decelerationRate: Double = ScrollViewDecelerationRate, integralizeValue: Bool = false) -> V where V : AnimatableProperty {
        if integralizeValue {
            return V(self.destination(value: value.animatableData, velocity: velocity.animatableData, decelerationRate: decelerationRate)).scaledIntegral
        }
        return V(self.destination(value: value.animatableData, velocity: velocity.animatableData, decelerationRate: decelerationRate))
    }
    
    /**
     Solves the velocity required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decelerationRate: The decay constant.

     - Returns: The velocity required to reach `toValue`.
     */
    public static func velocity<V>(fromValue: V, toValue: V, decelerationRate: Double = ScrollViewDecelerationRate) -> V where V : VectorArithmetic {
        let decay = log(decelerationRate) * 1000.0
        return (fromValue - toValue).scaled(by: decay)
    }
    
    /**
     Solves the velocity required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decelerationRate: The decay constant.

     - Returns: The velocity required to reach `toValue`.
     */
    public static func velocity<V>(fromValue: V, toValue: V, decelerationRate: Double = ScrollViewDecelerationRate) -> V where V : AnimatableProperty {
        V(self.velocity(fromValue: fromValue.animatableData, toValue: toValue.animatableData, decelerationRate: decelerationRate))
    }
    
    /**
     Solves the duration required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decelerationRate: The decay constant.

     - Returns: The duration required to reach `toValue`.
     */
    public static func duration<Value: VectorArithmetic>(value: Value, velocity: Value, decelerationRate: Double = ScrollViewDecelerationRate) -> TimeInterval {
        var value = value
        var velocity = velocity
        let decayFunction = DecayFunction(decelerationRate: decelerationRate)
        let deltaTime = 1.0 / 60.0
        var duration: TimeInterval = 0.0
        let velocityThreshold: Double = 0.05
        
        while velocity.magnitudeSquared > velocityThreshold {
            decayFunction.update(value: &value, velocity: &velocity, deltaTime: deltaTime)
            duration = duration + deltaTime
        }
        return duration
    }
    
    /**
     Solves the duration required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decelerationRate: The decay constant.

     - Returns: The duration required to reach `toValue`.
     */
    public static func duration<Value: VectorArithmetic>(fromValue value: Value, toValue: Value, decelerationRate: Double = ScrollViewDecelerationRate) -> TimeInterval {
        let velocity = DecayFunction.velocity(fromValue: value, toValue: toValue)
        return self.duration(value: value, velocity: velocity, decelerationRate: decelerationRate)
    }
    
    /**
     Solves the duration required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - velocity: The starting velocity of the decay.
        - decelerationRate: The decay constant.

     - Returns: The duration required to reach `toValue`.
     */
    public static func duration<Value: AnimatableProperty>(value: Value, velocity: Value, decelerationRate: Double = ScrollViewDecelerationRate) -> TimeInterval {
        return duration(value: value.animatableData, velocity: velocity.animatableData, decelerationRate: decelerationRate)
    }
    
    /**
     Solves the duration required to reach a desired destination for a decay function based on the given parameters.

     - Parameters:
        - value: The starting value.
        - toValue: The desired destination for the decay.
        - decelerationRate: The decay constant.

     - Returns: The duration required to reach `toValue`.
     */
    public static func duration<Value: AnimatableProperty>(fromValue value: Value, toValue: Value, decelerationRate: Double = ScrollViewDecelerationRate) -> TimeInterval {
        return duration(fromValue: value.animatableData, toValue: toValue.animatableData, decelerationRate: decelerationRate)
    }
}
