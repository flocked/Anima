//
//  Spring.swift
//
//
//  Created by Florian Zand on 28.03.24.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 A representation of a spring’s motion.

 Example usage:
 ```swift
 let spring = Spring(duration: 0.5, bounce: 0.3)

 let (dampingRatio, stiffness) = (spring.dampingRatio, spring.stiffness, spring.mass)
 // (0.7, 157.9, 1.0)

 let spring2 = Spring.bouncy
 let (response, bounce) = (spring2.response, spring2.bounce)
 // (0.5, 0.3)
 ```

 You can also use it to query a value and velocity for a given set of inputs:

 ```swift
 let value = spring.value(fromValue: 0.0, toValue: 200.0, initialVelocity: .zero, time: 0.1)
 // 84.66

 let velocity = spring.velocity(fromValue: 0.0, toValue: 200.0, initialVelocity: .zero, time: 0.1)
 // 1141.51
 ```
 */
public struct Spring: Sendable, Hashable {
    // MARK: - Getting spring characteristics

    /// The amount of oscillation the spring will exhibit (i.e. "springiness").
    public let dampingRatio: Double

    /// The stiffness of the spring, defined as an approximate duration in seconds.
    public let response: Double

    /**
     How bouncy the spring is.

     A value of `0` indicates no bounces (a critically damped spring), positive values indicate increasing amounts of bounciness up to a maximum of `1.0` (corresponding to undamped oscillation), and negative values indicate overdamped springs with a minimum value of `-1.0`.
     */
    public var bounce: Double {
        1.0 - dampingRatio
    }

    /// The spring stiffness coefficient. Increasing the stiffness reduces the number of oscillations and will reduce the settling duration.
    public let stiffness: Double

    /// The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
    public let mass: Double

    /// Defines how the spring’s motion should be damped due to the forces of friction.
    public let damping: Double

    /// The estimated duration required for the spring system to be considered at rest.
    public let settlingDuration: TimeInterval

    // MARK: - Creating a spring

    /**
     Creates a spring with the specified duration and bounce.

     - Parameters:
        - duration: Defines the pace of the spring. This is approximately equal to the settling duration, but for springs with very large bounce values, will be the duration of the period of oscillation for the spring.
        - bounce: How bouncy the spring should be. A value of `0` indicates no bounces (a critically damped spring), positive values indicate increasing amounts of bounciness up to a maximum of `1.0` (corresponding to undamped oscillation), and negative values indicate overdamped springs with a minimum value of `-1.0`).
     */
    public init(duration: Double = 0.55, bounce: Double = 0.0) {
        if #available(macOS 14.0, iOS 17, tvOS 17, *) {
            self = Spring(SwiftUI.Spring(duration: duration, bounce: bounce))
        } else {
            self.init(response: duration, dampingRatio: 1.0 - bounce, mass: 1.0)
        }
    }

    /**
     Creates a spring with the given damping ratio and frequency response.

     - Parameters:
        - stiffness: The corresponding spring coefficient. The value affects how quickly the spring animation reaches its target value.  It's an alternative to configuring springs with a ``response`` value.
        - dampingRatio: The amount of oscillation the spring will exhibit (i.e. "springiness"). A value of `1.0` (critically damped) will cause the spring to smoothly reach its target value without any oscillation. Values closer to `0.0` (underdamped) will increase oscillation (and overshoot the target) before settling.
        - mass: The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public init(stiffness: Double, dampingRatio: Double, mass: Double = 1.0) {
        precondition(stiffness > 0, "The stiffness of the spring has to be > 0")
        precondition(dampingRatio > 0, "The dampingRatio of the spring has to be > 0")
        let response = Self.response(stiffness: stiffness, mass: mass)
        let damping = Self.damping(dampingRatio: dampingRatio, response: response, mass: mass)
        if #available(macOS 14.0, iOS 17, tvOS 17, *) {
            self = Spring(SwiftUI.Spring(mass: mass, stiffness: stiffness, damping: damping, allowOverDamping: true))
        } else {
            self.dampingRatio = dampingRatio
            self.stiffness = stiffness
            self.mass = mass
            self.response = response
            self.damping = damping
            settlingDuration = Self.settlingTime(dampingRatio: dampingRatio, damping: damping, stiffness: stiffness, mass: mass)
        }
    }

    /**
     Creates a spring with the given damping ratio and frequency response.

     - parameters:
        - response: Represents the frequency response of the spring. This value affects how quickly the spring animation reaches its target value. The frequency response is the duration of one period in the spring's undamped system, measured in seconds. Values closer to `0` create a very fast animation, while values closer to `1.0` create a relatively slower animation.
        - dampingRatio: The amount of oscillation the spring will exhibit (i.e. "springiness"). A value of `1.0` (critically damped) will cause the spring to smoothly reach its target value without any oscillation. Values closer to `0.0` (underdamped) will increase oscillation (and overshoot the target) before settling.
        - mass: The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public init(response: Double, dampingRatio: Double, mass: Double = 1.0) {
        precondition(dampingRatio >= 0, "The dampingRatio of the spring has to be >= 0")
        precondition(response >= 0, "The response of the spring has to be >= 0")
        if mass == 1, #available(macOS 14.0, iOS 17, tvOS 17, *) {
            self = Spring(SwiftUI.Spring(response: response, dampingRatio: dampingRatio))
        } else {
            self.dampingRatio = dampingRatio
            self.response = response
            self.mass = mass
            stiffness = Self.stiffness(response: response, mass: mass)
            
            let unbandedDampingCoefficient = Self.damping(dampingRatio: dampingRatio, response: response, mass: mass)
            
            damping = Rubberband.value(for: unbandedDampingCoefficient, range: 0 ... 60, interval: 15)
            
            settlingDuration = Self.settlingTime(dampingRatio: dampingRatio, damping: damping, stiffness: stiffness, mass: mass)
        }
    }

    /**
     Creates a spring with the specified duration and damping ratio.

     - Parameters:
        - settlingDuration: The approximate time it will take for the spring to come to rest.
        - dampingRatio: The amount of drag applied as a fraction of the amount needed to produce critical damping.
        - epsilon: The threshold for how small all subsequent values need to be before the spring is considered to have settled. The default value is `0.001`.
     */
    @available(macOS 14.0, iOS 17, tvOS 17, *)
    public init(settlingDuration: TimeInterval, dampingRatio: Double, epsilon: Double = 0.0001) {
        let spring = SwiftUI.Spring(settlingDuration: settlingDuration, dampingRatio: dampingRatio, epsilon: epsilon)
        self.init(spring)
    }
    
    /**
     Creates a spring with the specified duration and bounce.

     - Parameters:
        - settlingDuration: The approximate time it will take for the spring to come to rest.
        - bounce: How bouncy the spring should be. A value of `0` indicates no bounces (a critically damped spring), positive values indicate increasing amounts of bounciness up to a maximum of `1.0` (corresponding to undamped oscillation), and negative values indicate overdamped springs with a minimum value of `-1.0`).
        - epsilon: The threshold for how small all subsequent values need to be before the spring is considered to have settled. The default value is `0.001`.
     */
    @available(macOS 14.0, iOS 17, tvOS 17, *)
    public init(settlingDuration: TimeInterval, bounce: Double, epsilon: Double = 0.0001) {
        let spring = SwiftUI.Spring(settlingDuration: settlingDuration, dampingRatio: 1.0 - bounce, epsilon: epsilon)
        self.init(spring)
    }

    /// Creates a spring from a SwiftUI spring.
    @available(macOS 14.0, iOS 17, tvOS 17, *)
    init(_ spring: SwiftUI.Spring) {
        dampingRatio = spring.dampingRatio
        response = spring.response
        stiffness = spring.stiffness
        mass = spring.mass
        damping = spring.damping
        settlingDuration = spring.settlingDuration
    }

    // MARK: - Built-in springs

    /// A reasonable, slightly underdamped spring to use for interactive animations (like dragging an item around).
    public static let interactive = Spring(response: 0.28, dampingRatio: 0.86)

    /// A spring with a predefined duration and higher amount of bounce.
    public static let bouncy = Spring.bouncy()

    /**
     A spring with a predefined duration and higher amount of bounce that can be tuned.

     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.3.
     */
    public static func bouncy(duration: Double = 0.5, extraBounce: Double = 0.0) -> Spring {
        Spring(response: duration, dampingRatio: 0.7 - extraBounce, mass: 1.0)
    }

    /// A smooth spring with a predefined duration and no bounce.
    public static let smooth = Spring.smooth()

    /**
     A smooth spring with a predefined duration and no bounce that can be tuned.

     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.
     */
    public static func smooth(duration: Double = 0.5, extraBounce: Double = 0.0) -> Spring {
        Spring(response: duration, dampingRatio: 1.0 - extraBounce, mass: 1.0)
    }

    /// A spring with a predefined duration and small amount of bounce that feels more snappy.
    public static let snappy = Spring.snappy()

    /**
     A spring with a predefined duration and small amount of bounce that feels more snappy and can be tuned.

     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.15.
     */
    public static func snappy(duration: Double = 0.5, extraBounce: Double = 0.0) -> Spring {
        Spring(response: duration, dampingRatio: 0.85 - extraBounce, mass: 1.0)
    }

    /**
     Updates the current value and velocity of a spring.

     - Parameters:
        - value: The current value of the spring.
        - velocity: The current velocity of the spring.
        - target: The target that value is moving towards.
        - deltaTime: The amount of time that has passed since the spring was at the position specified by value.
     */
    public func update<V>(value: inout V, velocity: inout V, target: V, deltaTime: TimeInterval) where V: AnimatableProperty {
        var valueData = value.animatableData
        var velocityData = velocity.animatableData

        update(value: &valueData, velocity: &velocityData, target: target.animatableData, deltaTime: deltaTime)
        velocity = V(velocityData)
        value = V(valueData)
    }

    func update<V>(value: inout V, velocity: inout V, target: V, deltaTime: TimeInterval) where V: VectorArithmetic {
        let displacement = value - target
        let springForce = displacement * -stiffness
        let dampingForce = velocity.scaled(by: damping)
        let force = springForce - dampingForce
        let acceleration = force * (1.0 / mass)

        velocity = velocity + (acceleration * deltaTime)
        value = value + (velocity * deltaTime)
    }

    // MARK: - Getting spring value

    /**
     Calculates the value of the spring at a given time given a target amount of change.

     - Parameters:
        - target: The target that value is moving towards.
        - initialVelocity: The initial velocity of the spring.
        - time: The amount of time that has passed since start of the spring.
     */
    public func value<V>(target: V, initialVelocity: V, time: TimeInterval) -> V where V: VectorArithmetic {
        var value = V.zero
        var velocity = initialVelocity
        update(value: &value, velocity: &velocity, target: target, deltaTime: time)
        return value
    }

    /**
     Calculates the value of the spring at a given time for a starting and ending value for the spring to travel.

     - Parameters:
        - fromValue: The starting value of the spring.
        - toValue: The target that value is moving towards.
        - initialVelocity: The initial velocity of the spring.
        - time: The amount of time that has passed since start of the spring.
     */
    public func value<V>(fromValue: V, toValue: V, initialVelocity: V, time: TimeInterval) -> V where V: AnimatableProperty {
        var value = fromValue
        let target = toValue
        var velocity = initialVelocity
        update(value: &value, velocity: &velocity, target: target, deltaTime: time)
        return value
    }

    // MARK: - Getting spring velocity

    /**
     Calculates the velocity of the spring at a given time given a target amount of change.

     - Parameters:
        - target: The target that value is moving towards.
        - initialVelocity: The initial velocity of the spring.
        - time: The amount of time that has passed since start of the spring.
     */
    public func velocity<V>(target: V, initialVelocity: V, time: TimeInterval) -> V where V: VectorArithmetic {
        var value = V.zero
        var velocity = initialVelocity
        update(value: &value, velocity: &velocity, target: target, deltaTime: time)
        return velocity
    }

    /**
     Calculates the velocity of the spring at a given time given a starting and ending value for the spring to travel.

     - Parameters:
        - fromValue: The starting value of the spring.
        - toValue: The target that value is moving towards.
        - initialVelocity: The initial velocity of the spring.
        - time: The amount of time that has passed since start of the spring.
     */
    public func velocity<V>(fromValue: V, toValue: V, initialVelocity: V, time: TimeInterval) -> V where V: AnimatableProperty {
        var value = fromValue
        let target = toValue
        var velocity = initialVelocity
        update(value: &value, velocity: &velocity, target: target, deltaTime: time)
        return velocity
    }

    // MARK: - Spring calculation

    static func stiffness(response: Double, mass: Double) -> Double {
        pow(2.0 * .pi / response, 2.0) * mass
    }

    static func response(stiffness: Double, mass: Double) -> Double {
        (2.0 * .pi) / sqrt(stiffness * mass)
    }

    static func damping(dampingRatio: Double, response: Double, mass: Double) -> Double {
        4.0 * .pi * dampingRatio * mass / response
    }

    static func dampingRatio(damping: Double, stiffness: Double, mass: Double) -> Double {
        damping / (2 * sqrt(stiffness * mass))
    }

    static func settlingTime(dampingRatio: Double, damping: Double, stiffness: Double, mass: Double) -> Double {
        if #available(macOS 14.0, iOS 17, tvOS 17, *) {
            // SwiftUI`s spring calculates a more precise settling duration.
            return SwiftUI.Spring(mass: mass, stiffness: stiffness, damping: damping, allowOverDamping: true).settlingDuration
        } else {
            return Spring.settlingTime(dampingRatio: dampingRatio, stiffness: stiffness, mass: mass)
        }
    }

    static func settlingTime(dampingRatio: Double, stiffness: Double, mass: Double, epsilon: Double = defaultSettlingPercentage) -> Double {
        if stiffness == .infinity {
            // A non-animated mode (i.e. a `response` of 0) results in a stiffness of infinity, and a settling time of 0.
            // We need the settling time to be non-zero such that the display link stays alive.
            return 1.0
        }

        if dampingRatio >= 1.0 {
            let criticallyDampedSettlingTime = settlingTime(dampingRatio: 1.0 - .ulpOfOne, stiffness: stiffness, mass: mass)
            return criticallyDampedSettlingTime * 1.25
        }

        let undampedNaturalFrequency = Spring.undampedNaturalFrequency(stiffness: stiffness, mass: mass) // ωn
        return -1 * (log(epsilon) / (dampingRatio * undampedNaturalFrequency))
    }

    static let defaultSettlingPercentage = 0.001

    static func undampedNaturalFrequency(stiffness: Double, mass: Double) -> Double {
        sqrt(stiffness / mass)
    }
}

@available(macOS 14.0, iOS 17, tvOS 17, *)
public extension Spring {
    /// A SwiftUI representation of the spring.
    internal var swiftUI: SwiftUI.Spring {
        SwiftUI.Spring(mass: mass, stiffness: stiffness, damping: damping, allowOverDamping: true)
    }

    // MARK: - Calculating forces and durations

    /// Calculates the force upon the spring given a current position, target, and velocity amount of change.
    func force<V: VectorArithmetic>(target: V, position: V, velocity: V) -> V {
        swiftUI.force(target: target, position: position, velocity: velocity)
    }

    /// Calculates the force upon the spring given a current position, velocity, and divisor from the starting and end values for the spring to travel.
    func force<V: AnimatableProperty>(fromValue: V, toValue: V, position: V, velocity: V) -> V {
        let fromValue = AnimatableProxy(fromValue)
        let toValue = AnimatableProxy(toValue)
        let position = AnimatableProxy(position)
        let velocity = AnimatableProxy(velocity)
        let force = swiftUI.force(fromValue: fromValue, toValue: toValue, position: position, velocity: velocity)
        return V(force.animatableData)
    }

    /// The estimated duration required for the spring system to be considered at rest.
    func settlingDuration<V: VectorArithmetic>(target: V, initialVelocity: V = .zero, epsilon: Double = 0.001) -> Double {
        swiftUI.settlingDuration(target: target, initialVelocity: initialVelocity, epsilon: epsilon)
    }

    /// The estimated duration required for the spring system to be considered at rest.
    func settlingDuration<V: AnimatableProperty>(fromValue: V, toValue: V, initialVelocity: V, epsilon: Double = 0.001) -> Double {
        let fromValue = AnimatableProxy(fromValue)
        let toValue = AnimatableProxy(toValue)
        let initialVelocity = AnimatableProxy(initialVelocity)
        return swiftUI.settlingDuration(fromValue: fromValue, toValue: toValue, initialVelocity: initialVelocity, epsilon: epsilon)
    }
}

extension Spring: CustomStringConvertible {
    public var description: String {
        """
        Spring(
            response: \(response)
            dampingRatio: \(dampingRatio)
            mass: \(mass)

            settlingDuration: \(String(format: "%.3f", settlingDuration))
            damping: \(damping)
            stiffness: \(String(format: "%.3f", stiffness))
            animated: \(response != .zero)
        )
        """
    }
}

/// Provides `Animatable` conformance to an `AnimatableProperty`.
struct AnimatableProxy<Value: AnimatableProperty>: Animatable {
    var animatableData: Value.AnimatableData

    init(_ value: Value) {
        animatableData = value.animatableData
    }
}
