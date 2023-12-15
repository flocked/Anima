//
//  PropertyAnimation.swift
//
//
//  Created by Florian Zand on 15.12.23.
//

import AppKit

/**
 An animation that animates any type conforming to ``AnimatableProperty``.
 
 This class lets you create your own property-based animation by subclassing it.
   
 To start your animation, use ``start(afterDelay:)``. It  changes the ``state`` to `running` and ``updateAnimation(deltaTime:)`` gets called until you stop the animation.
 
 Make sure to update ``startValue`` at start. It's used as value when the position of ``stop(at:immediately:)`` is `start`.
 
 To stop an running animation either use ``stop(at:immediately:)`` or change the `state` to `ended` or `inactive`.
 
 Calling ``pause()`` changes the `state` to `inactive`.
  
 If you overwrite ``start(afterDelay:)``, ``pause()`` or ``stop(at:immediately:)`` make sure to call super.
 
 Note: Changing `state` itself isn't starting or stopping an animation. It only reflects the state of your animation. You have to use the above functions.
*/
open class PropertyAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding {
    public var groupID: UUID?
    
    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupUUID: UUID?

    /// The relative priority of the animation.
    open var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    open internal(set) var state: AnimatingState = .inactive
    
    /// The delay (in seconds) after which the animations begin.
    open internal(set) var delay: TimeInterval = 0.0
    
    /// The _current_ value of the animation. This value will change as the animation executes.
    open var value: Value {
        get { Value(_value) }
        set { _value = newValue.animatableData }
    }
    
    var _value: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _startValue = _value
        }
    }
    
    /**
     The target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    open var target: Value {
        get { Value(_target) }
        set {  _target = newValue.animatableData }
    }
    
    internal var _target: Value.AnimatableData {
        didSet {
            guard oldValue != _target else { return }
            if state == .running {
                completion?(.retargeted(from: Value(oldValue), to: target))
            }
        }
    }
            
    /// The start value of the animation.
    open var startValue: Value {
        get { Value(_startValue) }
        set { _startValue = newValue.animatableData }
    }
    
    open var _startValue: Value.AnimatableData
    
    var velocity: Value = .zero
    
    var _velocity: Value.AnimatableData = .zero
    
    var startVelocity: Value = .zero
    
    var integralizeValues: Bool = false
        
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    open var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    open var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /**
     Creates a new animation with the specified initial and target value.

     - Parameters:
        - value: The initial, starting value of the animation.
        - target: The target value of the animation.
     */
    public init(value: Value, target: Value) {
        self._value = value.animatableData
        self._startValue = _value
        self._target = target.animatableData
    }
    
    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil
    
    /// The animation type.
    let animationType: AnimationController.AnimationParameters.AnimationType = .easing
    
    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupID
    }
                
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    open func updateAnimation(deltaTime: TimeInterval) {

    }
    
    /**
     Starts the animation from its current position with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    open func start(afterDelay delay: TimeInterval = 0.0) {
        precondition(delay >= 0, "Animation start delay must be greater or equal to zero.")
        guard state != .running else { return }
        
        let start = {
            self.state = .running
            AnimationController.shared.runAnimation(self)
        }
        
        delayedStart?.cancel()
        self.delay = delay

        if delay == .zero {
            start()
        } else {
            let task = DispatchWorkItem {
                start()
            }
            delayedStart = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }
    
    /// Pauses the animation at the current position.
    open func pause() {
        guard state == .running else { return }
        AnimationController.shared.stopAnimation(self)
        state = .inactive
        delayedStart?.cancel()
        delay = 0.0
    }
    
    /**
     Stops the animation at the specified position.
     
     - Parameters:
        - position: The position at which position the animation should stop (``AnimationPosition/current``, ``AnimationPosition/start`` or ``AnimationPosition/end``). The default value is `current`.
        - immediately: A Boolean value that indicates whether the animation should stop immediately at the specified position. The default value is `true`.
     */
    open func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
        delayedStart?.cancel()
        delay = 0.0
        if immediately == false {
            switch position {
            case .start:
                target = startValue
            case .current:
                target = value
            default: break
            }
        } else {
            AnimationController.shared.stopAnimation(self)
            state = .inactive
            switch position {
            case .start:
                value = startValue
                valueChanged?(value)
            case .end:
                value = target
                valueChanged?(value)
            default: break
            }
            reset()
            completion?(.finished(at: value))
        }
    }
    
    /// Resets the animation.
    func reset() {

    }
}
