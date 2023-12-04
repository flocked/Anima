# Animatable Properties

## Overview

Any type conforming to ``AnimatableProperty`` can be animated by `Anima`.

By default, lots of types already supported it:

- `Float`
- `Double`
- `CGFloat`
- `CGPoint`
- `CGSize`
- `CGRect`
- `CGColor`/`NSColor`/`UIColor`
- `CATransform3D` / `CGAffineTransform`
- ``AnimatableArray``
- … and many more.

## Setup

To conform to ``AnimatableProperty`` you have to provide:
- ``AnimatableProperty/animatableData``: A representation of the type conforming `VectorArithmetic`.
- ``AnimatableProperty/init(_:)``: Initialization of the type with the `animatableData`.
- ``AnimatableProperty/zero`` The zero value of the type.

Example:

```swift
public struct SomeStruct {
   let value1: Double
   let value2: Double
}

extension SomeStruct: AnimatableProperty {
   public var animatableData: AnimatableArray<Double> {
       [value1, value2]
   }

   public init(_ animatableData: AnimatableArray<Double>) {
       self.value1 = animatableData[0]
       self.value1 = animatableData[1]
   }

   public static var zero: Self = SomeStruct(value1: 0, value2: 0)
}
```
