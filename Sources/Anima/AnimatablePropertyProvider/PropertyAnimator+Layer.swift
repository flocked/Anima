//
//  PropertyAnimator+Layer.swift
//
//
//  Created by Florian Zand on 12.10.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension CALayer: AnimatablePropertyProvider { }

public extension AnimatablePropertyProvider where Self: CALayer {
    /**
     Provides animatable properties of the layer.

     To animate properties change their value inside an ``Anima`` animation block. To stop their animations and to change their values imminently, update their values outside an animation block.

     See ``LayerAnimator`` for more information about how to animate and all animatable properties.
     */
    var animator: LayerAnimator<Self> { 
        getAssociatedValue("PropertyAnimator", initialValue: LayerAnimator(self))
    }
}

/**
 Provides animatable properties of `CALayer`.

 ### Animating Properties

 To animate the properties, change their values inside an ``Anima`` animation block:

 ```swift
 Anima.animate(withSpring: .smooth) {
    layer.animator.frame.size = CGSize(width: 100.0, height: 200.0)
    layer.animator.backgroundColor = .black
 }
 ```
 To stop animations and to change properties immediately, change their values outside an animation block:

 ```swift
 layer.animator.backgroundColor = .white
 ```

 ### Accessing Animations

 To access the animation for a property, use ``Anima/AnimationProvider/animation(for:)-6b22o``:

 ```swift
 if let animation = layer.animator.animation(for: \.frame) {
    animation.stop()
 }
 ```
 
 ### Accessing Animation Value and Velocity
 
 The animation returned via ``Anima/AnimationProvider/animation(for:)-6b22o`` provides the current animation value and velocity.

 ```swift
 if let animation = layer.animator.animation(for: \.frame) {
    let velocity = animation.velocity
    let value = animation.value
 }
 ```
 */
public class LayerAnimator<Layer: CALayer>: PropertyAnimator<Layer> {
    // MARK: - Animatable Properties

    /// The bounds of the layer.
    public var bounds: CGRect {
        get { self[\.bounds] }
        set { self[\.bounds] = newValue }
    }

    /// The frame of the layer.
    public var frame: CGRect {
        get { self[\.frame] }
        set { self[\.frame] = newValue }
    }

    /// The origin of the layer.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }

    /// The size of the layer. Changing the value keeps the layer centered. To change the size without centering use the layer's frame size.
    public var size: CGSize {
        get { frame.size }
        set { frame.sizeCentered = newValue }
    }

    /// The center of the layer.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }

    /// The layer’s position on the z axis.
    public var zPosition: CGFloat {
        get { self[\.zPosition] }
        set { self[\.zPosition] = newValue }
    }

    /// Defines the anchor point of the layer's bounds rectangle.
    public var anchorPoint: CGPoint {
        get { self[\._anchorPoint] }
        set { self[\._anchorPoint] = newValue }
    }

    /// The anchor point for the layer’s position along the z axis.
    public var anchorPointZ: CGFloat {
        get { self[\.anchorPointZ] }
        set { self[\.anchorPointZ] = newValue }
    }

    /// The background color of the layer.
    public var backgroundColor: CGColor? {
        get { self[\.backgroundColor] }
        set { self[\.backgroundColor] = newValue }
    }

    /// The opacity value of the layer.
    public var opacity: CGFloat {
        get { CGFloat(self[\.opacity]) }
        set { self[\.opacity] = Float(newValue) }
    }

    /// The corner radius of the layer.
    public var cornerRadius: CGFloat {
        get { self[\.cornerRadius] }
        set { self[\.cornerRadius] = newValue }
    }

    /// The border of the layer.
    public var border: BorderConfiguration {
        get { self[\.border] }
        set { 
            if object.borderColor == nil || object.borderColor.alpha == 0.0 {
                object.borderColor = newValue.color?.withAlphaComponent(0.0).cgColor
            }
            self[\.border] = newValue
        }
    }

    /// The shadow of the layer.
    public var shadow: ShadowConfiguration {
        get { self[\.shadow] }
        set { 
            if object.shadowColor == nil || object.shadowColor.alpha == 0.0 {
                object.shadowColor = newValue.color?.withAlphaComponent(0.0).cgColor
            }
            self[\.shadow] = newValue
        }
    }

    /// The inner shadow of the layer.
    public var innerShadow: ShadowConfiguration {
        get { self[\.innerShadow] }
        set { 
            if object.innerShadow.color == nil || object.innerShadow.color?.alphaComponent == 0.0 {
                object.innerShadow.color = newValue.color?.withAlphaComponent(0.0)
            }
            self[\.innerShadow] = newValue
        }
    }

    /// The three-dimensional transform of the layer.
    public var transform: CATransform3D {
        get { self[\.transform] }
        set { self[\.transform] = newValue }
    }

    /// The scale transform of the layer.
    public var scale: Scale {
        get { transform.scale.scale }
        set { transform.scale = newValue.vector }
    }

    /// The translation transform of the layer.
    public var translation: CGPoint {
        get { CGPoint(transform.translation.x, transform.translation.y) }
        set { transform.translation = Translation(newValue.x, newValue.y, transform.translation.z)
        }
    }

    /// The rotation of the layer's transform as euler angles in degrees.
    public var rotation: Rotation {
        get { transform.eulerAnglesDegrees.rotation }
        set { transform.eulerAnglesDegrees = newValue.vector }
    }

    /// The rotation of the layer's transform as euler angles in radians.
    public var rotationInRadians: Rotation {
        get { transform.eulerAngles.rotation }
        set { transform.eulerAngles = newValue.vector }
    }

    /// The perspective of the layer's transform (e.g. .m34).
    public var perspective: Perspective {
        get { transform.perspective }
        set { transform.perspective = newValue }
    }

    /// The shearing of the layer's transform.
    public var skew: Skew {
        get { transform.skew }
        set { transform.skew = newValue }
    }
}

public extension LayerAnimator where Layer: CAShapeLayer {
    /// The color used to fill the shape’s path.
    var fillColor: CGColor? {
        get { self[\.fillColor] }
        set { self[\.fillColor] = newValue }
    }

    /// The dash pattern applied to the shape’s path when stroked.
    var lineDashPattern: [Double] {
        get { self[\._lineDashPattern] }
        set { self[\._lineDashPattern] = newValue }
    }

    /// The dash phase applied to the shape’s path when stroked.
    var lineDashPhase: CGFloat {
        get { self[\.lineDashPhase] }
        set { self[\.lineDashPhase] = newValue }
    }

    /// Specifies the line width of the shape’s path.
    var lineWidth: CGFloat {
        get { self[\.lineWidth] }
        set { self[\.lineWidth] = newValue }
    }

    /// The miter limit used when stroking the shape’s path.
    var miterLimit: CGFloat {
        get { self[\.miterLimit] }
        set { self[\.miterLimit] = newValue }
    }

    /// The color used to stroke the shape’s path.
    var strokeColor: CGColor? {
        get { self[\.strokeColor] }
        set { self[\.strokeColor] = newValue }
    }

    /// The relative location at which to begin stroking the path.
    var strokeStart: CGFloat {
        get { self[\.strokeStart] }
        set { self[\.strokeStart] = newValue }
    }

    /// The relative location at which to stop stroking the path.
    var strokeEnd: CGFloat {
        get { self[\.strokeEnd] }
        set { self[\.strokeEnd] = newValue }
    }
}

public extension LayerAnimator where Layer: CAReplicatorLayer {
    /// Specifies the delay, in seconds, between replicated copies.
    var instanceDelay: CGFloat {
        get { self[\.instanceDelay] }
        set { self[\.instanceDelay] = newValue }
    }

    /// The transform matrix applied to the previous instance to produce the current instance.
    var instanceTransform: CATransform3D {
        get { self[\.instanceTransform] }
        set { self[\.instanceTransform] = newValue }
    }

    /// Defines the color used to multiply the source object.
    var instanceColor: CGColor? {
        get { self[\.instanceColor] }
        set { self[\.instanceColor] = newValue }
    }

    /// Defines the offset added to the red component of the color for each replicated instance. Animatable.
    var instanceRedOffset: CGFloat {
        get { CGFloat(self[\.instanceRedOffset]) }
        set { self[\.instanceRedOffset] = Float(newValue) }
    }

    /// Defines the offset added to the green component of the color for each replicated instance. Animatable.
    var instanceGreenOffset: CGFloat {
        get { CGFloat(self[\.instanceGreenOffset]) }
        set { self[\.instanceGreenOffset] = Float(newValue) }
    }

    /// Defines the offset added to the blue component of the color for each replicated instance. Animatable.
    var instanceBlueOffset: CGFloat {
        get { CGFloat(self[\.instanceBlueOffset]) }
        set { self[\.instanceBlueOffset] = Float(newValue) }
    }

    /// Defines the offset added to the alpha component of the color for each replicated instance. Animatable.
    var instanceAlphaOffset: CGFloat {
        get { CGFloat(self[\.instanceAlphaOffset]) }
        set { self[\.instanceAlphaOffset] = Float(newValue) }
    }
}

public extension LayerAnimator where Layer: CATiledLayer {
    /// The maximum size of each tile used to create the layer's content.
    var tileSize: CGSize {
        get { self[\.tileSize] }
        set { self[\.tileSize] = newValue }
    }
}

public extension LayerAnimator where Layer: CAGradientLayer {
    /// The fill color of the layer.
    var colors: [CGColor] {
        get { self[\._colors] }
        set { self[\._colors] = newValue }
    }

    /// The locations of each gradient stop.
    var locations: [CGFloat] {
        get { self[\._locations] }
        set { self[\._locations] = newValue }
    }

    /// The start point of the gradient when drawn in the layer’s coordinate space.
    var startPoint: CGPoint {
        get { self[\.startPoint] }
        set { self[\.startPoint] = newValue }
    }

    /// The end point of the gradient when drawn in the layer’s coordinate space.
    var endPoint: CGPoint {
        get { self[\.endPoint] }
        set { self[\.endPoint] = newValue }
    }
}

public extension LayerAnimator where Layer: CAEmitterLayer {
    /// The position of the center of the particle emitter.
    var emitterPosition: CGPoint {
        get { self[\.emitterPosition] }
        set { self[\.emitterPosition] = newValue }
    }

    /// Specifies the center of the particle emitter shape along the z-axis.
    var emitterZPosition: CGFloat {
        get { self[\.emitterZPosition] }
        set { self[\.emitterZPosition] = newValue }
    }

    /// Determines the depth of the emitter shape.
    var emitterDepth: CGFloat {
        get { self[\.emitterDepth] }
        set { self[\.emitterDepth] = newValue }
    }

    /// Determines the size of the particle emitter shape.
    var emitterSize: CGSize {
        get { self[\.emitterSize] }
        set { self[\.emitterSize] = newValue }
    }

    /// Defines a multiplier applied to the cell-defined particle spin.
    var spin: CGFloat {
        get { CGFloat(self[\.spin]) }
        set { self[\.spin] = Float(newValue) }
    }

    /// Defines a multiplier applied to the cell-defined particle velocity.
    var velocity: CGFloat {
        get { CGFloat(self[\.velocity]) }
        set { self[\.velocity] = Float(newValue) }
    }

    /// Defines a multiplier that is applied to the cell-defined birth rate.
    var birthRate: CGFloat {
        get { CGFloat(self[\.birthRate]) }
        set { self[\.birthRate] = Float(newValue) }
    }

    /// Defines a multiplier applied to the cell-defined lifetime range when particles are created.
    var lifetime: CGFloat {
        get { CGFloat(self[\.lifetime]) }
        set { self[\.lifetime] = Float(newValue) }
    }
    
    /// Adds the layer animated by fading it in.
    func addSublayer(_ layer: CALayer) {
        guard layer !== object else { return }
        layer.removeSuperlayer = nil
        Anima.nonAnimated {
            layer.animator.opacity = 0.0
        }
        object.addSublayer(layer)
        layer.animator.opacity = 1.0
    }
    
    /**
     Removes the layer from it's superlayer by fading it out.
     
     The layer is removed after the fade out animation finishes.
     */
    func removeFromSuperlayer() {
        guard let superlayer = object.superlayer else { return }
        object.removeSuperlayer = superlayer
        object.animator.opacity = 0.0
    }
}

extension CAGradientLayer {
    var _locations: [CGFloat] {
        get { locations?.compactMap({$0.doubleValue}) ?? [] }
        set { locations = newValue as [NSNumber] }
    }
}

private extension CAShapeLayer {
    var _lineDashPattern: [Double] {
        get { lineDashPattern?.compactMap({$0.doubleValue}) ?? [] }
        set { lineDashPattern = newValue as [NSNumber] }
    }
}

private extension CAGradientLayer {
    var _colors: [CGColor] {
        get { (colors as? [CGColor]) ?? [] }
        set { colors = newValue }
    }
}
