# ``Anima``

Anima is an animation framework for iOS, tvOS, and macOS. It can animate properties using spring, easing and decay animations.

## Overview

There are two ways you can animate with Anima, depending on your needs.

#### Block-Based Animation

The easiest way to animate is by using Anima’s block-based APIs. It lets you animate properties of objects like `NSView/UIView`, `NSWindow`, `CALayer`, `NSLayoutConstraint` and any object conforming to ``AnimatablePropertyProvider``.

The animatable properties can can be accessed via the object's ``AnimatablePropertyProvider/animator``. To animate them, change their values inside an animation block using `Anima.animate(…)`.

**Animation types**

There are three animation types:
- **Decay:** ``Anima/animate(withDecay:decelerationRate:delay:options:animations:completion:)``.
    - Animates with a decaying acceleration.
- **Easing:** ``Anima/animate(withEasing:duration:delay:options:animations:completion:)``
    - Animates with a timing function like `easeIn`, `easeOut` or `linear`.
- **Spring:** ``Anima/animate(withSpring:gestureVelocity:delay:options:animations:completion:)``
    - Animates with a spring.

Example spring animation:
```swift
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

**Stop Animations**

Updating a property outside an animation block stops its animation and updates it immediately:

 ```swift
 view.animator.backgroundColor = .systemRed
 ```

*For more details about block-based animations take a look at <doc:Animating-Properties>.*

#### Property-Based Animation

While the block-based API is often most convenient, you may want to animate something that the block-based API doesn’t yet support. Or, you may want the flexibility of getting the intermediate values of an animation.

Any type conforming to ``AnimatableProperty`` can be animated. Many types already conform to it: `Double`, `CGFöpat`, `CGPoint`, `CGSize`, `CGRect`, `CGColor`, `NSColor`, `UIColor`.

There are three animation types:
- ``DecayAnimation``
- ``EasingAnimation``
- ``SpringAnimation``

Example spring animation:
```swift
let animation = SpringAnimation(spring: .bouncy, value: view.frame.size, target: CGSize(width: 500, height: 500))
animation.valueChanged = { newSize in 
    view.frame.size = newSize
}
animation.start(afterDelay: 0.0)
```

*For more details about how to make a type animatable by conforming to `AnimatableProperty`, take a look at <doc:AnimatableProperties>.*

*For more details about the different animation types and how to set them up, take a look at <doc:Animations>.*

## Topics

### Animatable Property

- <doc:AnimatableProperties>
- ``AnimatableProperty``
- ``AnimatableArray``

### Animatable Property Provider

- ``AnimatablePropertyProvider``
- ``PropertyAnimator``
- ``LayerAnimator``
- ``LayoutAnimator``
- ``ViewAnimator``
- ``WindowAnimator``

### Animating

- <doc:Animating-Properties>
- ``Anima``
- ``Anima/AnimationOptions``

### Anmations

- <doc:Animations>
- ``AnimationProviding``
- ``AnimationEvent``
- ``AnimationPosition``
- ``AnimatingState``

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

- ``CAKeyframeAnimationEmittable``
- ``CAKeyframeAnimationValueConvertible``
- ``FloatingPointInitializable``
- ``Rubberband``
- ``ShadowConfiguration``
