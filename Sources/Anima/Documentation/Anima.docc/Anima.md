# ``Anima``

An animation framework for iOS, tvOS, and macOS.

## Overview

Anima is an animation framework for iOS, tvOS, and macOS. It can animate properties using spring, easing and decay animations.

There are two ways you can animate with Anima, depending on your needs.

#### Block-Based Animation

The easiest way to animate is by using Anima’s block-based APIs. It lets you animate properties of objects like `NSView`, `UIView`, `CALayer`, `NSLayoutConstraint`, `NSWindow` or any other object conforming to ``AnimatablePropertyProvider``.

The animatable properties can be accessed via the object's ``AnimatablePropertyProvider/animator``. To animate them, change their values inside an animation block using `Anima.animate(…)`.

Example of a spring animation:
```swift
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

**Animation types**

- **Decay:** ``Anima/animate(withDecay:decelerationRate:delay:options:animations:completion:)``.
    - Animates with a decaying acceleration.
- **Easing:** ``Anima/animate(withEasing:duration:delay:options:animations:completion:)``
    - Animates with a timing function like `easeIn`, `easeOut` or `linear`.
- **Spring:** ``Anima/animate(withSpring:gestureVelocity:delay:options:animations:completion:)``
    - Animates with a spring.

**Stop Animations**

Updating a property outside an animation block, stops its animation and its value is changed immediately:

 ```swift
 view.animator.backgroundColor = .systemRed
 ```

*For more details about block-based animations take a look at <doc:Animating-Properties>.*

**Preferred Framerate Range**


You can change the preferred framerate range via ``Anima/preferredFrameRateRange``:

```swift
Anima.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 45, preferred: 30)
```

Note: To enable high frame-rate animations on ProMotion devices (i.e. 120 fps animation), you'll need to add a key/value pair in your Info.plist. Set the key `CADisableMinimumFrameDuration` to `true. Without this entry, animations will be capped at 60 fps.

#### Property-Based Animation

While the block-based API is often most convenient, you may want to animate something that the block-based API doesn’t yet support. Or, you may want the flexibility of getting the intermediate values of an animation.

Any type conforming to ``AnimatableProperty`` can be animated. Many types already conform to it: `Double`, `CGFlpat`, `CGPoint`, `CGSize`, `CGRect`, `CGColor`, `NSColor`, `UIColor`, `CATransform3D`, …

There are three types of animations:
- ``DecayAnimation``
- ``EasingAnimation``
- ``SpringAnimation``

To create an animation you provide an initial value, target value and ``ValueAnimation/valueChanged``, a block that gets called whenever the animation's current value changes.

Example of a spring animation:
```swift
let animation = SpringAnimation(spring: .bouncy, value: view.frame.size, target: CGSize(width: 500, height: 500))
animation.valueChanged = { newSize in 
    view.frame.size = newSize
}
animation.start()
```

*For more details about how to make a type animatable, take a look at <doc:AnimatableProperties>.*

*For more details about the different animation types and how to set them up, take a look at <doc:Animations>.*

#### Creating your own animations

Subclassing ``ValueAnimation`` let's you create your own animations. Itself isn't animating and your have to provide your own animation implemention.

## Topics

### Animating

- <doc:Animating-Properties>
- ``Anima``

### Animatable Property

- <doc:AnimatableProperties>
- ``AnimatableProperty``

### Animatable Property Provider

- ``AnimatablePropertyProvider``
- ``PropertyAnimator``
- ``LayerAnimator``
- ``LayoutAnimator``
- ``ViewAnimator``
- ``PopoverAnimator``
- ``WindowAnimator``

### Animations

- <doc:Animations>
- ``BaseAnimation``
- ``ValueAnimation``

### Decay Animation

- ``DecayAnimation``
- ``DecayFunction``

### Easing Animation

- ``EasingAnimation``
- ``TimingFunction``

### Spring Animation

- ``SpringAnimation``
- ``Spring``

### Additions

- ``AnimationProvider``
- ``BorderConfiguration``
- ``ShadowConfiguration``
- ``FloatingPointInitializable``
- ``Rubberband``
- ``AnimatableArray``

### CoreAnimation Additions

- ``CAKeyframeAnimationEmittable``
- ``CAKeyframeAnimationValueConvertible``
- ``CGVector3``
- ``CGVector4``
- ``CGQuaternion``
- ``Perspective``
- ``Scale``
- ``Skew``
- ``Translation``
