# Animatable Properties

Make properties animatable by conforming it to `AnimatableProperty`.

## Overview

Any type conforming to ``AnimatableProperty`` can be animated by `Anima`.

By default, lots of types already supported it:

- `Float`
- `Double`
- `CGFloat`
- `CGPoint`
- `CGSize`
- `CGRect`
- `CGColor` / `NSColor` / `UIColor`
- `CATransform3D` / `CGAffineTransform`
- ``AnimatableArray``
- … and many more.

## How to conform to AnimatableProperty

To conform to ``AnimatableProperty`` you have to provide:
- ``AnimatableProperty/animatableData``: A representation of the type conforming `VectorArithmetic`.
- ``AnimatableProperty/init(_:)``: Initialization of the type with the `animatableData`.
- ``AnimatableProperty/zero`` The zero value of the type.

Example:

```swift
struct MyStruct {
   let value: Double
   let point: CGPoint
}

extension MyStruct: AnimatableProperty {
   init(_ animatableData: AnimatableArray<Double>) {
       value = animatableData[0]
       point = CGPoint(x: animatableData[1], y: animatableData[2])
   }

   var animatableData: AnimatableArray<Double> {
       [value, point.x, point.y]
   }

   static let zero = MyStruct(value: 0, point: .zero)
}
```

You can optionally also provide ``AnimatableProperty/scaledIntegral``, a scaled integral of the value. It is used to integralize the value to the screen's pixel boundaries on animations where ``AnimationOptions/integralizeValues`` is active. This helps prevent drawing frames between pixels, causing aliasing issues.

```swift
var scaledIntegral: MyStruct {
    let scaledIntegralPoint = CGPoint(x: point.x.scaledIntegral, y: y.scaledIntegral)
    return MyStruct(value: value.scaledIntegral, point: scaledIntegralPoint)
}
```
