# Anima

Anima is an animation engine for iOS, iPadOS, and macOS. It allows animating properties with spring, easing and decay animation.

It is partly based on [Wave](https://github.com/jtrivedi/Wave) and [Motion](https://github.com/b3ll/Motion). Without these libraries Anima wouldn't have been possible.

## Animatable properties

Any type conforming to `AnimatableProperty` can be animated by `Anima`.

By default, lots of types already supported it:

- `Float`
- `Double`
- `CGFloat`
- `CGPoint`
- `CGSize`
- `CGRect`
- `CGColor`/`NSColor`/`UIColor`
- `CATransform3D`
- Arrays with `AnimatableProperty` values
- … and many more.

## Animations

Many objects provide animatable properties:
 - macOS: `NSView`, `NSWindow`, `NSTextField`, `NSImageView` and many more.
 - iOS: `UIView`, `UILabel`, `UIImageView` and many more.
 - Shared: `NSLayoutConstraint` and `CALayer`

They can can be accessed via the object's `animator`. Use `Anima.animate()` to animate them.

```swift
// Spring animation
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animation.backgroundColor = .systemBlue
}

// Easing animation
Anima.animate(withEasing: .easeIn, duration: 3.0) {
    view.animator.frame = newFrame
    view.animation.backgroundColor = .systemBlue
}

// Decay animation
Anima.animate(withDecay: .value) {
    view.animator.frame = newFrame
    view.animation.backgroundColor = .systemBlue
}
```

Updating a property outside an animation block stops its animation and updates it immediately:
 ```swift
 view.animation.backgroundColor = .systemRed
 ```
 
#### Retargeting of spring animated values
 
When changing values of properties that are currently spring animated, the animation’s velocity is preserved. It provides fluid animations. That's why spring animations are the recommended animation for a responsive and interactive UI.

You can provide a gesture velocity for spring animations that animate `CGPoint` or `CGRect` values. This can be used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.

```swift
let velocity = panGestureRecognizer.velocity(in: view)

Anima.animate(withSpring: .snappy, gestureVelocity: velocity) {
    view.frame.origin = CGPoint(x: 200, y: 200)
}
```

### Spring Animation

A spring based animation for fluid animations.

You provide a `Spring` which describes the spring configuration. `Spring` offers many predefined configurations like `bouncy`, `smooth`, `snappy` or `Spring(duration: CGFloat, bouncy: CGFloat)`).

```swift
let value = CGPoint(x: 0, y: 0)
let target = CGPoint(x: 100, y: 100)

let springAnimation = SpringAnimation(spring: .bouncy, value: value, target: target)
springAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
springAnimation.start()
```

### Easing Animation

An easing based animation.

You provide it `TimeFunction` which describes the easing of the animation (e.g. `easeIn`, `easeInOut` or `linear`).

```swift
let easingAnimation = EasingAnimation(timingFunction: .easeIn, duration: 2.0, value: value, target: target)
easingAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
easingAnimation.start()
```

### Decay Animation

Performs animations with a decaying acceleration.

You either provide a **target** value and the animation will animate the value to the target with a decelerating acceleration.

```swift
let decayAnimation = DecayAnimation(value: value, target: target)
decayAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
decayAnimation.start()
```

Or you provide a **velocity** value. The property will increase or decrease depending on the velocity value and will slow to a stop.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.

```swift
// The origin's y value will increase 200 points.
let velocity = CGPoint(x: 0, y: 200)

let decayAnimation = DecayAnimation(value: value, velocity: velocity)
decayAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
decayAnimation.start()
```

## Additions

### CAKeyframeAnimationEmittable

All animations in Anima conform to `CAKeyframeAnimationEmittable` and provide a `CAKeyframeAnimation` via `keyframeAnimation` that mirrors the animation. The duration, keyframes and everything else is automatically calculated. The only difference is `valueChanged` and `completion` cannot be used, and you must specify a keypath to animate.

For example:

```swift
let springAnimation = SpringAnimation<CGRect>(spring: .bouncy, value: frame, target: targetFrame)

let keyframeAnimation = springAnimation.keyframeAnimation()
keyframeAnimation.keyPath = "frame"

layer.add(keyframeAnimation, forKey: "MyAnimation")
```

**Note**: If you remove or interrupt the animation and you want it to stay in place on screen, much like all other Core Animation animations, you'll need to grab the value from the layer's `presentationLayer` and apply that to the layer (as well as worry about `fillMode`).

### Rubberbanding

Rubberbanding is the act of making values appear to be on a rubberband (they stretch and slip based on interaction). `UIScrollView` does this when you're pulling past the contentSize and by using the rubberband functions in Motion you can re-create this interaction for yourself.

```swift
 bounds.origin.x = rubberband(bounds.origin.x - translation.x, boundsSize: bounds.size.width, contentSize: contentSize.width)
```

## Installation

Add Anima to your app's Package.swift file, or selecting File -> Add Packages in Xcode:

```swift
.package(url: "https://github.com/flocked/Anima")
```

If you clone the repo, you can run the sample app, which contains a few interactive demos to understand what Anima provides.

Note: To enable high frame-rate animations on ProMotion devices (i.e. 120 fps animation), you'll need to add a key/value pair in your Info.plist. Set the key `CADisableMinimumFrameDuration` to true. Without this entry, animations will be capped at 60 fps.
