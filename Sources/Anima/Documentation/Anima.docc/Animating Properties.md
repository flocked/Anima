# Animating Properties

Animate properties of objects like `NSView`, `UIView`, `CALayer` and `NSLayoutConstraint`. 

## Overview

Anima lets you easily animate properties of objects conforming to ``AnimatablePropertyProvider``.

Many objects already conform to it and provide animatable properties:
 - macOS: `NSView`, `NSWindow`, `NSTextField`, `NSImageView` and many more.
 - iOS: `UIView`, `UILabel`, `UIImageView` and many more.
 - Shared: `NSLayoutConstraint` and `CALayer`

The properties can can be accessed via the object's ``AnimatablePropertyProvider/animator``. Change their values inside an animation block using `Anima.animate(…)` to animate them.

### Spring Animation

``Anima/animate(withSpring:gestureVelocity:delay:options:animations:completion:)``

A spring based animation for fluid animations.

You provide a ``Spring`` which describes the spring configuration. `Spring` offers many predefined configurations like ``Spring/bouncy``, ``Spring/smooth``, ``Spring/snappy`` or ``Spring/init(duration:bounce:)``).

```swift
// Spring animation
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

When changing values of properties that are currently spring animated, the animation’s velocity is preserved for providing fluid animations. That's why spring animations are the recommended animation for a responsive and interactive UI.

You can provide a gesture velocity for spring animations that animate `CGPoint` or `CGRect` values. This can be used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.

```swift
let velocity = panGestureRecognizer.velocity(in: view)

Anima.animate(withSpring: .snappy, gestureVelocity: velocity) {
    view.frame.origin = CGPoint(x: 200, y: 200)
}
```

### Easing Animation

``Anima/animate(withEasing:duration:delay:options:animations:completion:)``

An easing based animation.

You provide a ``TimingFunction`` which describes the easing of the animation (e.g. `easeIn` or `easeInEaseOut` or `linear`) and a duration.

```swift
Anima.animate(withEasing: .easeIn, duration: 3.0) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

### Decay Animation

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

### Stopping of animations

Updating a property outside an animation block stops its animation and updates it immediately:

 ```swift
 view.animator.backgroundColor = .systemRed
 ```

You can also stop all animations at the current values:

```swift
Anima.stopAllAnimations()
```

### Changing the velocity

You can change the velocity of running decay or spring animation:

```swift
Anima.updateVelocity {
    view.animator.frame.origin.y += 200
}
```
