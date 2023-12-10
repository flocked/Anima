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
import Decomposed

extension CALayer: AnimatablePropertyProvider { }

extension AnimatablePropertyProvider where Self: CALayer {
    /**
     Provides animatable properties of the layer.
     
     To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update their values outside an animation block.
     
     See ``LayerAnimator`` for more information.
     */
    public var animator: LayerAnimator<Self> {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: LayerAnimator(self)) }
    }
}

/**
 Provides animatable properties of an layer.
 
 ### Animating properties

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
 
 To access the animation for a specific property, use ``animation(for:)``:
 
 ```swift
 if let animation = layer.animator.animation(for: \.frame) {
    animation.stop()
 }
 ```
 
 ### Accessing Animation Velocity
 
 To access the animation velocity for a specific property, use ``animationVelocity(for:)`.
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
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
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
        get { self[\.anchorPoint] }
        set { self[\.anchorPoint] = newValue }
    }
    
    /// The background color of the layer.
    public var backgroundColor: CGColor? {
        get { self[\.backgroundColor] }
        set { self[\.backgroundColor] = newValue }
    }
    
    /// The anchor point for the layer’s position along the z axis.
    public var anchorPointZ: CGFloat {
        get { self[\.anchorPointZ] }
        set { self[\.anchorPointZ] = newValue }
    }
        
    /// The opacity value of the layer.
    public var opacity: CGFloat {
        get { CGFloat(self[\.opacity]) }
        set { self[\.opacity] = Float(newValue) }
    }
    
    /// The three-dimensional transform of the layer.
    public var transform: CATransform3D {
        get { self[\.transform] }
        set { self[\.transform] = newValue }
    }
    
    /// The scale of the layer.
    public var scale: CGPoint {
        get { CGPoint(self.transform.scale.x, self.transform.scale.y) }
        set { self.transform.scale = Scale(newValue.x, newValue.y, transform.scale.z) }
    }
    
    /// The rotation of the layer.
    public var rotation: CGQuaternion {
        get { self[\.rotation] }
        set { self[\.rotation] = newValue }
    }
    
    /// The translation transform of the layer.
    public var translation: CGPoint {
        get { CGPoint(self.transform.translation.x, self.transform.translation.y) }
        set { self.transform.translation = Translation(newValue.x, newValue.y, self.transform.translation.z)
        }
    }
    
    /// The corner radius of the layer.
    public var cornerRadius: CGFloat {
        get { self[\.cornerRadius] }
        set { self[\.cornerRadius] = newValue }
    }
    
    /// The border color of the layer.
    public var borderColor: CGColor? {
        get { self[\.borderColor] }
        set { self[\.borderColor] = newValue }
    }
    
    /// The border width of the layer.
    public var borderWidth: CGFloat {
        get { self[\.borderWidth] }
        set { self[\.borderWidth] = newValue }
    }
    
    /// The shadow of the layer.
    public var shadow: ShadowConfiguration {
        get { self[\.shadow] }
        set { self[\.shadow] = newValue }
    }
    
    /// The inner shadow of the layer.
    public var innerShadow: ShadowConfiguration {
        get { self[\.innerShadow] }
        set { self[\.innerShadow] = newValue }
    }
    
    // MARK: - Accessing animations

    /**
     The current animation for the property at the specified keypath, or `nil` if the property isn't animated.

     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<LayerAnimator, Value>) -> AnimationProviding? {
        return animations[keyPath.stringValue]
    }
    
    /**
     The current animation velocity for the property at the specified keypath, or `nil` if the property isn't animated or doesn't support velocity values.

     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<LayerAnimator, Value>) -> Value? {
        return (animation(for: keyPath) as? any ConfigurableAnimationProviding)?.velocity as? Value
    }
}

extension LayerAnimator where Layer: CAShapeLayer {
    
    /// The color used to fill the shape’s path.
    public var fillColor: CGColor? {
        get { self[\.fillColor] }
        set { self[\.fillColor] = newValue }
    }
        
    /// The dash pattern applied to the shape’s path when stroked.
    public var lineDashPattern: [Double] {
        get { self[\._lineDashPattern] }
        set { self[\._lineDashPattern] = newValue }
    }
    
    /// The dash phase applied to the shape’s path when stroked.
    public var lineDashPhase: CGFloat {
        get { self[\.lineDashPhase] }
        set { self[\.lineDashPhase] = newValue }
    }
    
    /// Specifies the line width of the shape’s path.
    public var lineWidth: CGFloat {
        get { self[\.lineWidth] }
        set { self[\.lineWidth] = newValue }
    }
    
    /// The miter limit used when stroking the shape’s path.
    public var miterLimit: CGFloat {
        get { self[\.miterLimit] }
        set { self[\.miterLimit] = newValue }
    }
        
    /// The color used to stroke the shape’s path.
    public var strokeColor: CGColor? {
        get { self[\.strokeColor] }
        set { self[\.strokeColor] = newValue }
    }
    
    /// The relative location at which to begin stroking the path.
    public var strokeStart: CGFloat {
        get { self[\.strokeStart] }
        set { self[\.strokeStart] = newValue }
    }
    
    /// The relative location at which to stop stroking the path.
    public var strokeEnd: CGFloat {
        get { self[\.strokeEnd] }
        set { self[\.strokeEnd] = newValue }
    }
}

extension LayerAnimator where Layer: CAReplicatorLayer {

    /// Specifies the delay, in seconds, between replicated copies.
    public var instanceDelay: CGFloat {
        get { self[\.instanceDelay] }
        set { self[\.instanceDelay] = newValue }
    }
    
    /// The transform matrix applied to the previous instance to produce the current instance.
    public var instanceTransform: CATransform3D {
        get { self[\.instanceTransform] }
        set { self[\.instanceTransform] = newValue }
    }
    
    /// Defines the color used to multiply the source object.
    public var instanceColor: CGColor? {
        get { self[\.instanceColor] }
        set { self[\.instanceColor] = newValue }
    }
    
    /// Defines the offset added to the red component of the color for each replicated instance. Animatable.
    public var instanceRedOffset: CGFloat {
        get { CGFloat(self[\.instanceRedOffset]) }
        set { self[\.instanceRedOffset] = Float(newValue) }
    }
    
    /// Defines the offset added to the green component of the color for each replicated instance. Animatable.
    public var instanceGreenOffset: CGFloat {
        get { CGFloat(self[\.instanceGreenOffset]) }
        set { self[\.instanceGreenOffset] = Float(newValue) }
    }
    
    /// Defines the offset added to the blue component of the color for each replicated instance. Animatable.
    public var instanceBlueOffset: CGFloat {
        get { CGFloat(self[\.instanceBlueOffset]) }
        set { self[\.instanceBlueOffset] = Float(newValue) }
    }
    
    /// Defines the offset added to the alpha component of the color for each replicated instance. Animatable.
    public var instanceAlphaOffset: CGFloat {
        get { CGFloat(self[\.instanceAlphaOffset]) }
        set { self[\.instanceAlphaOffset] = Float(newValue) }
    }
}

extension LayerAnimator where Layer: CATiledLayer {
    /// The maximum size of each tile used to create the layer's content.
    public var tileSize: CGSize {
        get { self[\.tileSize] }
        set { self[\.tileSize] = newValue }
    }
}

extension LayerAnimator where Layer: CAGradientLayer {
    /// The fill color of the layer.
    public var colors: [CGColor] {
        get { self[\._colors] }
        set { self[\._colors] = newValue }
    }
    
    /// The locations of each gradient stop.
    public var locations: [CGFloat] {
        get { self[\._locations] }
        set { self[\._locations] = newValue }
    }
    
    /// The start point of the gradient when drawn in the layer’s coordinate space.
    public var startPoint: CGPoint {
        get { self[\.startPoint] }
        set { self[\.startPoint] = newValue }
    }
    
    /// The end point of the gradient when drawn in the layer’s coordinate space.
    public var endPoint: CGPoint {
        get { self[\.endPoint] }
        set { self[\.endPoint] = newValue }
    }
}

extension LayerAnimator where Layer: CAEmitterLayer {
    /// The position of the center of the particle emitter.
    public var emitterPosition: CGPoint {
        get { self[\.emitterPosition] }
        set { self[\.emitterPosition] = newValue }
    }
    
    /// Specifies the center of the particle emitter shape along the z-axis.
    public var emitterZPosition: CGFloat {
        get { self[\.emitterZPosition] }
        set { self[\.emitterZPosition] = newValue }
    }
    
    /// Determines the depth of the emitter shape.
    public var emitterDepth: CGFloat {
        get { self[\.emitterDepth] }
        set { self[\.emitterDepth] = newValue }
    }
    
    /// Determines the size of the particle emitter shape.
    public var emitterSize: CGSize {
        get { self[\.emitterSize] }
        set { self[\.emitterSize] = newValue }
    }
    
    /// Defines a multiplier applied to the cell-defined particle spin.
    public var spin: CGFloat {
        get { CGFloat(self[\.spin]) }
        set { self[\.spin] = Float(newValue) }
    }
    
    /*
    /// Defines a multiplier applied to the cell-defined particle velocity.
    public var velocity: CGFloat {
        get { CGFloat(self[\.velocity]) }
        set { self[\.velocity] = Float(newValue) }
    }
    */
    
    /// Defines a multiplier that is applied to the cell-defined birth rate.
    public var birthRate: CGFloat {
        get { CGFloat(self[\.birthRate]) }
        set { self[\.birthRate] = Float(newValue) }
    }
    
    /// Defines a multiplier applied to the cell-defined lifetime range when particles are created.
    public var lifetime: CGFloat {
        get { CGFloat(self[\.lifetime]) }
        set { self[\.lifetime] = Float(newValue) }
    }
}

extension CAGradientLayer {
    var _locations: [CGFloat] {
        get { locations?.compactMap({$0.doubleValue}) ?? []  }
        set { locations = newValue as [NSNumber] }
    }
}

fileprivate extension CAShapeLayer {
    var _lineDashPattern: [Double] {
        get {lineDashPattern?.compactMap({$0.doubleValue}) ?? [] }
        set { lineDashPattern = newValue as [NSNumber] }
    }
}

fileprivate extension CAGradientLayer {
    var _colors: [CGColor] {
        get { return (self.colors as? [CGColor]) ??  [] }
        set { self.colors = newValue }
    }
}

extension LayerAnimator {

}
