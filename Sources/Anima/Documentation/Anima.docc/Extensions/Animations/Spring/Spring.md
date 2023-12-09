# ``Spring``

## Topics

### Creating Spring

- ``init(duration:bounce:)``
- ``init(response:dampingRatio:mass:)``
- ``init(settlingDuration:dampingRatio:epsilon:)``
- ``init(stiffness:dampingRatio:mass:)``

### Built-in springs

- ``bouncy``
- ``bouncy(duration:extraBounce:)``
- ``interactive``
- ``smooth``
- ``smooth(duration:extraBounce:)``
- ``snappy``
- ``snappy(duration:extraBounce:)``

### Getting spring characteristics

- ``bounce``
- ``damping``
- ``dampingRatio``
- ``mass``
- ``response``
- ``settlingDuration``
- ``stiffness``

### Updating spring value and velocity

- ``update(value:velocity:target:deltaTime:)``

### Getting spring value

- ``value(fromValue:toValue:initialVelocity:time:)``
- ``value(target:initialVelocity:time:)``

### Getting spring velocity

- ``velocity(fromValue:toValue:initialVelocity:time:)``
- ``velocity(target:initialVelocity:time:)``

### Getting spring force

- ``force(fromValue:toValue:position:velocity:)``
- ``force(target:position:velocity:)``

### Getting spring settling duration

- ``settlingDuration(fromValue:toValue:initialVelocity:epsilon:)``
- ``settlingDuration(target:initialVelocity:epsilon:)``
