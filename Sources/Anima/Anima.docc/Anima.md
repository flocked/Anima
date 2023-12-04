# ``Anima``

Anima is an animation framework for iOS, tvOS, and macOS. It can animate properties using spring, easing and decay animations.

## Overview

Anima lets you easily animate properties of objects like `NSView`, `UIView`, `CALayer` and `NSLayoutConstraint`. 

To animate properties you change their values inside an Anima animation block using the objects ``AnimatablePropertyProvider/animator``.

```swift
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

## Topics

### Animatable Property

- <doc:AnimatableProperties>
- ``AnimatableProperty``
- ``AnimatableArray``

### Animatable Provider

- ``AnimatablePropertyProvider``
- ``PropertyAnimator``
- ``LayerAnimator``
- ``LayoutAnimator``
- ``ViewAnimator``
- ``WindowAnimator``
- ``AnimationOptions``

### Animating

- <doc:Animating-Properties>
- ``Anima``

### Anmations

- <doc:Animations>
- ``AnimationProviding``
- ``PropertyAnimationProviding``
- ``AnimationEvent``
- ``AnimationState``
- ``AnimationPosition``

### Decay Animation

- ``DecayAnimation``
- ``DecayFunction``

### Easing Animation

- ``EasingAnimation``
- ``TimingFunction``
- ``UnitBezier``

### Spring Animation

- ``SpringAnimation``
- ``Spring``

### Additions

- ``CAKeyframeAnimationEmittable``
- ``CAKeyframeAnimationValueConvertible``
- ``ContentConfiguration``
- ``FloatingPointInitializable``
- ``Rubberband``
