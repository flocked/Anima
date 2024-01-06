# Anima

Anima is an animation framework for iOS, tvOS, and macOS. It lets you animate properties with using spring, easing and decay animations.

**For a full documentation take a look at the** [Online Documentation](https://swiftpackageindex.com/flocked/Anima/main/documentation/anima).

## Animatable Properties

Any type conforming to `AnimatableProperty` can be animated by `Anima`.

By default, lots of types already conform to it:

- `Float`
- `Double`
- `CGFloat`
- `CGPoint`
- `CGSize`
- `CGRect`
- `CGColor`/`NSColor`/`UIColor`
- `CATransform3D` / `CGAffineTransform`
- Arrays with `AnimatableProperty` values
- … and many more.

## Animations

There are two ways you can can create animations: **block-based** and **property-based**.

### Block-Based Animations

Block-based animation lets you easily animate properties of objects conforming to `AnimatablePropertyProvider`.

Many objects already conform to it and provide animatable properties:
 - macOS: `NSView`, `NSWindow`, `NSTextField`, `NSImageView` and many more.
 - iOS: `UIView`, `UILabel`, `UIImageView` and many more.
 - Shared: `NSLayoutConstraint` and `CALayer`
 
The properties can can be accessed via the object's `animator`. To animate them change their values inside an animation block using `Anima.animate(…)`. For example:

```swift
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
    textField.animator.fontSize = 20
}
```
To stop the animation of a property and to update it immediately, change it's value outside an animation block. For example:

```swift
view.animator.backgroundColor = .systemRed
```

#### Spring Animation

A spring based animation for fluid animations.

You provide a `Spring` which describes the spring configuration. `Spring` offers many predefined configurations like `bouncy`, `smooth`, `snappy` or `Spring(duration: CGFloat, bouncy: CGFloat)`).

```swift
Anima.animate(withSpring: .bouncy) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

When changing the value of a property that is currently animated, the animation’s velocity is preserved to provide fluid animations. That's why spring animation is the recommended animation for a responsive and interactive UI.

You can provide a gesture velocity for spring animations. This can be used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.  If you apply a velocity of type `CGPoint` it's used for animating properties of type `GGPoint` and `CGRect`.

```swift
let velocity = panGestureRecognizer.velocity(in: view)

Anima.animate(withSpring: .snappy, gestureVelocity: velocity) {
    view.frame.origin = CGPoint(x: 200, y: 200)
}
```

#### Easing Animation

An easing based animation.

You provide a `TimingFunction` which describes the easing of the animation (e.g. `easeIn`, `easeInOut` or `linear`) and a duration.

```swift
Anima.animate(withEasing: .easeIn, duration: 3.0) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

#### Decay Animation

Performs animations with a decaying acceleration.

You either provide **values** and the animation will animate the properties to the values with a decelerating acceleration.

```swift
Anima.animate(withDecay: .value) {
    view.animator.frame = newFrame
    view.animator.backgroundColor = .systemBlue
}
```

Or you provide **velocity** values. The properties will increase or decrease depending on the velocity values and will slow to a stop. This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.

```swift
Anima.animate(withDecay: .velocity) {
    // The origin's y value will increase 200 points. (e.g. if the origin`s y value is 250 it will move to 450)
    view.animator.frame.origin.y = 200
}
```

### Property-Based Animations

While the block-based API is often most convenient, you may want to animate an object that doesn't provide animatable properties. Or, you may want the flexibility of getting the intermediate values of an animation and driving an animation yourself.

To create an property-based animation you provide an initial value, target value and `valueChanged`, a block that gets called whenever the animation's current value changes.

#### Spring Animation 

```swift
let value = CGPoint(x: 0, y: 0)
let target = CGPoint(x: 100, y: 100)

let springAnimation = SpringAnimation(spring: .bouncy, value: value, target: target)
springAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
springAnimation.start()
```

#### Easing Animation

```swift
let easingAnimation = EasingAnimation(timingFunction: .easeIn, duration: 2.0, value: value, target: target)
easingAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
easingAnimation.start()
```

#### Decay Animation

```swift
// Decay animation with target
let decayAnimation = DecayAnimation(value: value, target: target)
decayAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
decayAnimation.start()

// Decay animation with velocity
let decayVelocityAnimation = DecayAnimation(value: value, velocity: velocity)
```

#### PropertyAnimation

To create your own animations overwrite this `PropertyAnimation`. The class isn't animating and you have to provide your own animation logic.

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

## Acknowledgement

Anima is partly based on [Wave](https://github.com/jtrivedi/Wave) and [Motion](https://github.com/b3ll/Motion). It uses `Waves` spring calculation and some of the animation logic and `Motion`s decay and easing calculation.

Without these libraries Anima wouldn't have been possible. 

## Installation

Add Anima to your app's Package.swift file, or selecting File -> Add Packages in Xcode:

```swift
.package(url: "https://github.com/flocked/Anima")
```

If you clone the repo, you can run the sample app, which contains a few interactive demos to understand what Anima provides.

Note: To enable high frame-rate animations on ProMotion devices (i.e. 120 fps animation), you'll need to add a key/value pair in your Info.plist. Set the key `CADisableMinimumFrameDuration` to `true. Without this entry, animations will be capped at 60 fps.
