# Animations

Anima provides Decay, Easing and Spring Animations.

## Overview

There are three animations types: Decay, Easing and Spring. They let you animate properties conforming to ``AnimatableProperty``.

You provide the inital and target value of the animation. 

To change the state of the animation, use      ``AnimationProviding/start(afterDelay:)``, ``AnimationProviding/pause()`` and ``AnimationProviding/stop(at:immediately:)``.

``SpringAnimation/valueChanged`` gets called whenever the current value of the animation changes.

```swift
let animation = SpringAnimation(spring: .bouncy, value: view.frame.size, target: CGSize(width: 500, height: 500))
animation.valueChanged = { newSize in 
    view.frame.size = newSize
}
animation.start(afterDelay: 0.0)
```

``SpringAnimation/completion`` gets called when the animation either finishes, or "re-targets" to a new target value.

```swift
animation.completion = { event in 
    if event.isFinished {
        // handle finished state
    }
}
```

## Animation Types

### Spring Animation

A spring based animation for fluid animations.

You provide a ``Spring`` which describes the spring configuration. `Spring` offers many predefined configurations like ``Spring/bouncy``, ``Spring/smooth`` or ``Spring/snappy``.

```swift
let value = CGPoint(x: 0, y: 0)
let target = CGPoint(x: 100, y: 100)

let springAnimation = SpringAnimation(spring: .bouncy, value: value, target: target)
springAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
springAnimation.start()
```

When changing the target while the animation is runniong, the animation’s velocity is preserved for providing fluid animations.

### Easing Animation

An easing based animation.

You provide it ``TimingFunction`` which describes the easing of the animation (e.g. `easeIn` or `linear`) and a duration.

```swift
let easingAnimation = EasingAnimation(timingFunction: .easeIn, duration: 2.0, value: value, target: target)
easingAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
easingAnimation.start()
```

### Decay Animation

Performs animations with a decaying acceleration. There are two ways ways to create a decay animation:

- **target**: You provide a target and the animation will animate it's value to the target with a decaying acceleration.

```swift
let decayAnimation = DecayAnimation(value: value, target: target)
decayAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
decayAnimation.start()
```

- **velocity**: You provide a velocity and the animation will increase or decrease it's value depending on the velocity and will slow to a stop. This essentially provides the same "decaying" that a scroll view does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.

```swift
let decayAnimation = DecayAnimation(value: value, velocity: velocity)
decayAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
}
decayAnimation.start()
```
