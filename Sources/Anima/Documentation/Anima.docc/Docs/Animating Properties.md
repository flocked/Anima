# Animating Properties

Animate properties of objects like `NSView`, `UIView`, `CALayer` and `NSLayoutConstraint` using block-based animations.

## Overview

Anima lets you easily animate properties of objects conforming to ``AnimatablePropertyProvider``.

Many objects already conform to it and provide animatable properties:
 - macOS: `NSView`, `NSWindow`, `NSTextField`, `NSImageView` and many more.
 - iOS: `UIView`, `UILabel`, `UIImageView` and many more.
 - Shared: `NSLayoutConstraint` and `CALayer`

The animatable properties can can be accessed via the object's ``AnimatablePropertyProvider/animator``.

#### Animating Properties

To animate properties change their values inside an animation block using `Anima.animate(…)`. For example:

```swift
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```
To update properties immediately and to stop their animations, change their values outside an animation block. For example:

```swift
view.animator.backgroundColor = .systemRed
```

You can also stop all animations at their current values:

```swift
Anima.stopAllAnimations()
```

### Animation Types

#### Spring Animation

``Anima/animate(withSpring:gestureVelocity:delay:options:animations:completion:)``

A spring based animation for fluid animations.

You provide a ``Spring`` which describes the spring configuration. `Spring` offers many predefined configurations like ``Spring/bouncy``, ``Spring/smooth``, ``Spring/snappy`` or ``Spring/init(duration:bounce:)``).

```swift
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

When changing values of properties that are currently spring animated, the animation’s velocity is preserved to provide fluid animations. That's why spring animation is the recommended animation for a responsive and interactive UI.

You can provide a gesture velocity for spring animations that animate `CGPoint` or `CGRect` values. This can be used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.

```swift
let velocity = panGestureRecognizer.velocity(in: view)

Anima.animate(withSpring: .snappy, gestureVelocity: velocity) {
    view.frame.origin = CGPoint(x: 200, y: 200)
}
```

#### Easing Animation

``Anima/animate(withEasing:duration:delay:options:animations:completion:)``

An easing based animation.

You provide a ``TimingFunction`` which describes the easing of the animation (e.g. `easeIn` or `easeInEaseOut` or `linear`) and a duration.

```swift
Anima.animate(withEasing: .easeIn, duration: 3.0) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

#### Decay Animation

``Anima/animate(withDecay:decelerationRate:delay:options:animations:completion:)``.

Performs animations with a decaying acceleration. There are two types of decay animations:

- **value**: You provide a value and the animation will animate the value to the target with a decaying acceleration.

```swift
Anima.animate(withDecay: .value) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

- **velocity**: You provide a velocity and the animation will increase or decrease the initial value depending on the velocity and will slow to a stop. This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.

```swift
Anima.animate(withDecay: .velocity) {
    // The origin's y value will increase 200 points. (e.g. if the origin`s y value is 250 it will move to 450)
    view.animator.frame.origin.y = 200
}
```
