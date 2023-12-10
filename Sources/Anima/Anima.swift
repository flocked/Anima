//
//  Anima.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import CoreGraphics
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/**
 Performs animations on animatable properties of objects conforming to ``AnimatablePropertyProvider``.
 
 Many objects provide animatable properties.
 - macOS: `NSView`, `NSWindow`, `NSTextField`, `NSImageView`, `NSLayoutConstraint`, `CALayer` and many more.
 - iOS: `UIView`, `UILabel`, `UIImageView`, `NSLayoutConstraint`, `CALayer`  and many more.
 
 To animate values, you must set the values on the objects's ``AnimatablePropertyProvider/animator`` inside an Anima animation block, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.
 
 ## Animations
 
 There are three different types of animations :
 - **Decay:** ``animate(withDecay:decelerationRate:delay:options:animations:completion:)``
 - **Easing:** ``animate(withEasing:duration:delay:options:animations:completion:)``
 - **Spring:** ``animate(withSpring:gestureVelocity:delay:options:animations:completion:)``
 
 Example usage with a spring animation:
 
 ```swift
 Anima.animate(withSpring: .bouncy) {
    myView.animator.center = newCenterPoint
    myView.animator.backgroundColor = .systemBlue
 }
 ```
 ### Stop Animations
 
 Changing an `animator` property outside an animation block stops its animation and changes its value immediately.

 ```swift
 // outside of an animation block
 myView.animator.center = newCenterPoint
 myView.animator.backgroundColor = .black
 ```
 
 To stop all animations use ``stopAllAnimations(immediately:)``.
 
 ```swift
 Anima.stopAllAnimations()
 ```
 
 - Note: All animations are to run and be interfaced with on the main thread only. There is no support for threading of any kind.
 */
public class Anima {
    /**
     Performs spring animations based on the specified ``Spring``.
     
     Example usage:
     ```swift
     Anima.animate(withSpring: .bouncy) {
        myView.animator.center = view.center
        myView.animator.backgroundColor = .systemBlue
     }
     ```
     
     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`. For a list of all objects that provide animatable properties check ``Anima``.

     - Parameters:
        - spring: The ``Spring`` used to determine the timing curve and duration of the animation.
        - gestureVelocity: If provided, this value will be used to set the spring ``SpringAnimation/velocity`` of whatever underlying animations run in the `animations` block and that animate `CGPoint` or `CGRect` values. This should be primarily used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.
        - delay: An optional delay, in seconds, after which to start the animation.
        - options: The options to apply to the animations. For a list of options, see ``AnimationOptions``. The default value is `[]`.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's ``AnimatablePropertyProvider/animator``, not just the object itself.
        - completion: An optional block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withSpring spring: Spring,
        gestureVelocity: CGPoint? = nil,
        delay: TimeInterval = 0,
        options: AnimationOptions = [],
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        let settings = AnimationController.AnimationParameters(
            groupID: UUID(),
            delay: delay,
            animationType: .spring(spring: spring, gestureVelocity: gestureVelocity),
            options: options,
            completion: completion
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /**
     Performs easing animations based on the specified ``TimingFunction``.
     
     Example usage:
     ```swift
     Anima.animate(withEasing: .easeInEaseOut), duration: 3.0) {
        myView.animator.center = view.center
        myView.animator.backgroundColor = .systemBlue
     }
     ```
     
     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`. For a list of all objects that provide animatable properties check ``Anima``.

     - Parameters:
        - timingFunction: The ``TimingFunction`` used to determine the timing curve.
        - duration: The duration of the animation.
        - delay: An optional delay, in seconds, after which to start the animation.
        - options: The options to apply to the animations. For a list of options, see ``AnimationOptions``. The default value is `[]`.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's ``AnimatablePropertyProvider/animator``, not just the object itself.
        - completion: An optional block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withEasing timingFunction: TimingFunction,
        duration: TimeInterval,
        delay: TimeInterval = 0,
        options: AnimationOptions = [],
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        let settings = AnimationController.AnimationParameters(
            groupID: UUID(),
            delay: delay,
            animationType: .easing(timingFunction: timingFunction, duration: duration),
            options: options,
            completion: completion
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /**
     Performs animations with a decaying acceleration.
     
     There are two decay modes:
     - **value:** The properties will animate to your values with a decelerating acceleration.
     - **velocity:**:  The properties will increase or decrease depending on the values applied and will slow to a stop.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.
     
     Example usage:
     ```swift
     // Value based decay animation
     Anima.animate(withDecay: .value, animations: {
        // Animates the view's origin to the point with a decelerating rate.
        view.animator.frame.origin = CGPoint(x: 50, y: 50)
     })
     
     // Velocity based decay animation
     Anima.animate(withDecay: .velocity, animations: {
        // Increaes the view's origin by 50 points with a decelerating rate.
        view.animator.frame.origin = CGPoint(x: 50, y: 50)
     })
     ```
     
     - Note: For animations to work correctly, you must set values on the objects's ``AnimatablePropertyProvider/animator``, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`. For a list of all objects that provide animatable properties check ``Anima``.

     - Parameters:
        - mode: The mode how the animation should animate properties:
            - ``DecayAnimationMode/value`` will animate properties to the applied values with a decaying acceleration.
            - ``DecayAnimationMode/velocity`` will increase or decrease properties depending on the values applied and will slow to a stop.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.
        - decelerationRate: The rate at which the animation decelerates over time. The default value decelerates like scrollviews.
        - delay: An optional delay, in seconds, after which to start the animation.
        - options: The options to apply to the animations. For a list of options, see ``AnimationOptions``. The default value is `[]`.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's ``AnimatablePropertyProvider/animator``, not just the object itself.
        - completion: An optional block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withDecay mode: DecayAnimationMode,
        decelerationRate: Double = DecayFunction.ScrollViewDecelerationRate,
        delay: TimeInterval = 0,
        options: AnimationOptions = [],
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        let settings = AnimationController.AnimationParameters(
            groupID: UUID(),
            delay: delay,
            animationType: .decay(mode: mode, decelerationRate: decelerationRate),
            options: options,
            completion: completion
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /**
     Stops all animations.
     
     - Parameter immediately: A Boolean value indicating whether the animations should stop immediately at their values. The default value is `true`.
     */
    public static func stopAllAnimations(immediately: Bool = true) {
        AnimationController.shared.stopAllAnimations(immediately: immediately)
    }
    
    /// The preferred framerate of the animations. The default value is `nil` which uses the default frame rate of the display.
    @available(macOS 14.0, iOS 15.0, tvOS 15.0, *)
    public var preferredFrameRateRange: CAFrameRateRange? {
        get { AnimationController.shared.preferredFrameRateRange }
        set { AnimationController.shared.preferredFrameRateRange = newValue }
    }
    
    /**
     Updates the animation velocities for decay and spring animations.

     Example usage:
     ```swift
     Anima.updateVelocity() {
        myView.animator.frame.origin.y += 1000
     }
     ```
     
     - Parameter changes: A block containing the updated velocities.
     
     - Note: For a list of all objects that provide animatable properties check ``Anima``.
     */
    static func updateVelocity(changes: () -> Void) {
        let settings = AnimationController.AnimationParameters(
            groupID: UUID(),
            animationType: .velocityUpdate
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: changes, completion: nil)
    }
    
    /**
     Performs the specified changes non animated.
     
     Use it to immediately update values of properties. For properties that are currently animated, the animations stop. You can also update values non animated by using the ``AnimatablePropertyProvider/animator-54mpy`` outside of any ``Anima`` animation block.
     
     ```swift
     Anima.nonAnimate() {
        myView.animator.center = newCenterPoint
     }
     
     // or outside an animation block
     myView.animator.center = newCenterPoint
     ```
     
     - Note: For a list of all objects that provide animatable properties check ``Anima``.
     
     - Parameter changes: A block containing the changes to your objects animatable properties that get updated non animated.
     */
    static func nonAnimate(changes: () -> Void) {
        let settings = AnimationController.AnimationParameters(
            groupID: UUID(),
            animationType: .nonAnimated
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: changes, completion: nil)
    }
}
