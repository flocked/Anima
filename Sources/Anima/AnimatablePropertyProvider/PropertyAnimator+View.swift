//
//  PropertyAnimator+View.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Decomposed

extension NSUIView: AnimatablePropertyProvider { }

extension AnimatablePropertyProvider where Self: NSUIView {
    /**
     Provides animatable properties of the view.
     
     To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update their values outside an animation block.
     
     See ``ViewAnimator`` for more information about usage and all animatable properties.
     */
    public var animator: ViewAnimator<Self> {
        get { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: ViewAnimator(self)) }
    }
}

/**
 Provides animatable properties of an view.
 
 ### Animating Properties

 To animate the properties, change their values inside an ``Anima`` animation block:

 ```swift
 Anima.animate(withSpring: .smooth) {
    view.animator.frame.size = CGSize(width: 100.0, height: 200.0)
    view.animator.backgroundColor = .systemBlue
 }
 ```
 To stop animations and to change properties immediately, change their values outside an animation block:

 ```swift
 view.animator.backgroundColor = .systemRed
 ```
 
 ### Accessing Animations
 
 To access the animation for a property, use ``animation(for:)``:
 
 ```swift
 if let animation = view.animator.animation(for: \.frame) {
    animation.stop()
 }
 ```
 
 ### Accessing Animation Velocity
 
 To access the animation velocity for a property, use ``animationVelocity(for:)``.
 */
public class ViewAnimator<View: NSUIView>: PropertyAnimator<View> {
    
    // MARK: - Animatable Properties
    
    /// The bounds of the view.
    public var bounds: CGRect {
        get { self[\.bounds] }
        set { self[\.bounds] = newValue }
    }
    
    /// The frame of the view.
    public var frame: CGRect {
        get { self[\.frame] }
        set { self[\.frame] = newValue }
    }
    
    /// The origin of the view.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
        
    /// The size of the view. Changing the value keeps the view centered. To change the size without centering use the view's frame size.
    public var size: CGSize {
        get { frame.size }
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
    }
    
    /// The center of the view.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    /// The background color of the view.
    public var backgroundColor: NSUIColor? {
        get { object.optionalLayer?.animator.backgroundColor?.nsUIColor }
        set {
            object.optionalLayer?.animator.backgroundColor = newValue?.resolvedColor(for: object).cgColor
            #if os(macOS)
            object.dynamicColors.background = newValue
            #endif
        }
    }
    
    /// The alpha value of the view.
    public var alpha: CGFloat {
        get { object.optionalLayer?.animator.opacity ?? 1.0 }
        set { object.optionalLayer?.animator.opacity = newValue }
    }
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat {
        get { object.optionalLayer?.animator.cornerRadius ?? 0.0 }
        set { object.optionalLayer?.animator.cornerRadius = newValue }
    }
    
    /// The border color of the view.
    public var borderColor: NSUIColor? {
        get { object.optionalLayer?.animator.borderColor?.nsUIColor }
        set { object.optionalLayer?.animator.borderColor = newValue?.resolvedColor(for: object).cgColor
            #if os(macOS)
            object.dynamicColors.border = newValue
            #endif
        }
    }
    
    /// The border width of the view.
    public var borderWidth: CGFloat {
        get { object.optionalLayer?.animator.borderWidth ?? 0.0 }
        set { object.optionalLayer?.animator.borderWidth = newValue }
    }
    
    /// The shadow of the view.
    public var shadow: ShadowConfiguration {
        get { object.optionalLayer?.animator.shadow ?? .none() }
        set { 
            #if os(macOS)
            object.dynamicColors.shadow = newValue.color
            #endif
            var newValue = newValue
            newValue.color = newValue.color?.resolvedColor(for: object)
            object.optionalLayer?.animator.shadow = newValue }
    }
    
    /// The inner shadow of the view.
    public var innerShadow: ShadowConfiguration {
        get { object.optionalLayer?.animator.innerShadow ?? .none() }
        set {
            #if os(macOS)
            object.dynamicColors.innerShadow = newValue.color
            #endif
            var newValue = newValue
            newValue.color = newValue.color?.resolvedColor(for: object)
            object.optionalLayer?.animator.innerShadow = newValue
        }
    }
    
    /// The three-dimensional transform of the view.
    public var transform3D: CATransform3D {
        get { object.optionalLayer?.transform ?? CATransform3DIdentity }
        set { object.optionalLayer?.transform = newValue }
    }
    
    /// The scale transform of the view.
    public var scale: CGPoint {
        get { object.optionalLayer?.animator.scale ?? CGPoint(1, 1) }
        set { object.optionalLayer?.animator.scale = newValue  }
    }
    
    /// The rotation transform of the view.
    public var rotation: CGQuaternion {
        get { object.optionalLayer?.animator.rotation ?? .zero }
        set { object.optionalLayer?.animator.rotation = newValue }
    }
    
    /// The translation transform of the view.
    public var translation: CGPoint {
        get { object.optionalLayer?.animator.translation ?? .zero }
        set { object.optionalLayer?.animator.translation = newValue }
    }
    
    // MARK: - Accessing animations
    
    /**
     The current animation for the property at the specified keypath, or `nil` if the property isn't animated.

     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<ViewAnimator, Value>) -> AnimationProviding? {
        return layerAnimation(for: keyPath) ?? animations[keyPath.stringValue]
    }
    
    /**
     The current animation velocity for the property at the specified keypath, or `nil` if the property isn't animated or doesn't support velocity values.

     - Parameter keyPath: The keypath to an animatable property.
     */
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<ViewAnimator, Value>) -> Value? {
        var velocity: Value?
        Anima.updateVelocity {
            velocity = self[keyPath: keyPath]
        }
        return velocity
    }
}

#if os(macOS)

extension ViewAnimator where View: NSTextField {
    /// The text color of the text field.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
    
    /// The font size of the text field.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

extension ViewAnimator where View: NSTextView {
    /// The font size of the text view.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
    
    /// The text color of the text view.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
}

extension ViewAnimator where View: NSStackView {
    /// The minimum spacing, in points, between adjacent views in the stack view.
    public var spacing: CGFloat {
        get {  self[\.spacing] }
        set { self[\.spacing] = newValue }
    }
    
    /// The geometric padding, in points, inside the stack view, surrounding its views.
    public var edgeInsets: NSEdgeInsets {
        get { self[\.edgeInsets] }
        set { self[\.edgeInsets] = newValue }
    }
}

extension ViewAnimator where View: NSScrollView {
    /// The point at which the origin of the content view is offset from the origin of the scroll view.
    public var documentOffset: CGPoint {
        get { self[\.contentOffset] }
        set { self[\.contentOffset] = newValue }
    }
    
    /// The amount by which the content is currently scaled.
    public var magnification: CGFloat {
        get {  self[\.magnificationCentered] }
        set {
            object.animationCenterPoint = nil
            self[\.magnificationCentered] = newValue }
    }
    
    /// Magnify the content by the given amount and center the result on the given point.
    public func setMagnification(_ magnification: CGFloat, centeredAt point: CGPoint) {
        object.animationCenterPoint = point
        self[\.magnificationCentered] = magnification
    }
}

extension ViewAnimator where View: NSImageView {
    /// The tint color of the image.
    public var contentTintColor: NSColor? {
        get { self[\.contentTintColor] }
        set { self[\.contentTintColor] = newValue }
    }
}

extension ViewAnimator where View: NSButton {
    /// The tint color of the button.
    public var contentTintColor: NSColor? {
        get { self[\.contentTintColor] }
        set { self[\.contentTintColor] = newValue }
    }
}


extension ViewAnimator where View: NSControl {
    /// The double value of the control.
    public var doubleValue: Double {
        get { self[\.doubleValue] }
        set { self[\.doubleValue] = newValue }
    }
    
    /// The float value of the control.
    public var floatValue: Float {
        get { self[\.floatValue] }
        set { self[\.floatValue] = newValue }
    }
}

extension ViewAnimator where View: NSColorWell {
    /// The selected color for the color well.
    public var color: NSColor {
        get { self[\.color] }
        set { self[\.color] = newValue }
    }
}

extension ViewAnimator where View: NSBox {
    /// The color of the box’s background when the box is a custom box with a simple line border.
    public var fillColor: NSColor {
        get { self[\.fillColor] }
        set { self[\.fillColor] = newValue }
    }
    
    /// The distances between the border and the content view.
    public var contentViewMargins: CGSize {
        get { self[\.contentViewMargins] }
        set { self[\.contentViewMargins] = newValue }
    }
    
    /// The font size of the title.
    public var titleFontSize: CGFloat {
        get {  self[\.titleFontSize] }
        set { self[\.titleFontSize] = newValue }
    }
}

extension ViewAnimator where View: NSProgressIndicator {
    /// The current value of the progress indicator.
    public var doubleValue: Double {
        get {  self[\.doubleValue] }
        set { self[\.doubleValue] = newValue }
    }
    
    /// The minimum value for the progress indicator.
    public var minValue: Double {
        get {  self[\.minValue] }
        set { self[\.minValue] = newValue }
    }
    
    /// The maximum value for the progress indicator.
    public var maxValue: Double {
        get {  self[\.maxValue] }
        set { self[\.maxValue] = newValue }
    }
}

extension NSView {
    func insertSubview(_ view: NSUIView, aboveSubview siblingSubview: NSUIView) {
        guard subviews.contains(siblingSubview) else { return }
        addSubview(view, positioned: .above, relativeTo: siblingSubview)
    }
    
    func insertSubview(_ view: NSUIView, belowSubview siblingSubview: NSUIView) {
        guard subviews.contains(siblingSubview) else { return }
        addSubview(view, positioned: .below, relativeTo: siblingSubview)
    }
}

extension NSUIScrollView {
    var magnificationCentered: CGFloat {
        get { magnification }
        set {
            if let animationCenterPoint = animationCenterPoint {
                self.setMagnification(newValue, centeredAt: animationCenterPoint)
            } else {
                magnification = newValue
            }
        }
    }
    
    var animationCenterPoint: CGPoint? {
        get { getAssociatedValue(key: "animationCenterPoint", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "animationCenterPoint", object: self) }
    }
}

extension NSBox {
    var titleFontSize: CGFloat {
        get { titleFont.pointSize }
        set { titleFont = titleFont.withSize(newValue) }
    }
}

#elseif canImport(UIKit)
extension ViewAnimator where View: UITextField {
    /// The text color of the text field.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
    
    /// The font size of the text field.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

extension ViewAnimator where View: UITextView {
    /// The font size of the text view.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
    
    /// The text color of the text view.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
}

extension ViewAnimator where View: UIScrollView {
    /// The point at which the origin of the content view is offset from the origin of the scroll view.
    public var contentOffset: CGPoint {
        get { self[\.contentOffset] }
        set { self[\.contentOffset] = newValue }
    }
    
    /// The scale factor applied to the scroll view’s content.
    public var zoomScale: CGFloat {
        get { self[\.zoomScaleCentered] }
        set {
            object.animationCenterPoint = nil
            self[\.zoomScaleCentered] = newValue }
    }
    
    /// The size of the content view.
    public var contentSize: CGSize {
        get { self[\.contentSize] }
        set { self[\.contentSize] = newValue }
    }
    
    /// The custom distance that the content view is inset from the safe area or scroll view edges.
    public var contentInset: UIEdgeInsets {
        get { self[\.contentInset] }
        set { self[\.contentInset] = newValue }
    }
}

extension ViewAnimator where View: UIStackView {
    /// The minimum spacing, in points, between adjacent views in the stack view.
    public var spacing: CGFloat {
        get {  self[\.spacing] }
        set { self[\.spacing] = newValue }
    }
}

extension ViewAnimator where View: UIView {
    /// The default spacing to use when laying out content in a view,
    public var directionalLayoutMargins: NSDirectionalEdgeInsets {
        get { self[\.directionalLayoutMargins] }
        set { self[\.directionalLayoutMargins] = newValue }
    }
}

extension PropertyAnimator<UIView> {
    var preventsUserInteractions: Bool {
        get { getAssociatedValue(key: "preventsUserInteractions", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "preventsUserInteractions", object: self) }
    }
    
    /// Collects the animations that are configurated to prevent user interactions. If the set isn't empty the user interactions get disabled. When all animations finishes and the collection is empty, user interaction gets enabled again.
    var preventingUserInteractionAnimations: Set<UUID> {
        get { getAssociatedValue(key: "preventingAnimations", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "preventingAnimations", object: self)
            if !preventingUserInteractionAnimations.isEmpty, object.isUserInteractionEnabled, !preventsUserInteractions {
                object.isUserInteractionEnabled = false
                preventsUserInteractions = true
            } else if preventingUserInteractionAnimations.isEmpty, preventsUserInteractions {
                object.isUserInteractionEnabled = true
                preventsUserInteractions = false
            }
        }
    }
}

extension ViewAnimator where View: UIImageView {
    /// The tint color of the image.
    public var tintColor: UIColor {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue }
    }
}

extension ViewAnimator where View: UIButton {
    /// The tint color of the button.
    public var tintColor: UIColor {
        get { self[\.tintColor] }
        set { self[\.tintColor] = newValue }
    }
}

extension ViewAnimator where View: UILabel {
    /// The text color of the label.
    public var textColor: UIColor {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
    
    /// The font size of the label.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
}

@available(iOS 14.0, *)
extension ViewAnimator where View: UIColorWell {
    /// The selected color in the color picker.
    public var selectedColor: UIColor? {
        get { self[\.selectedColor] }
        set { self[\.selectedColor] = newValue }
    }
}

extension ViewAnimator where View: UIProgressView {
    /// The current progress of the progress view.
    public var progress: Float {
        get { self[\.progress] }
        set { self[\.progress] = newValue }
    }
}

extension UIScrollView {
    var zoomScaleCentered: CGFloat {
        get { zoomScale }
        set {
            if let animationCenterPoint = animationCenterPoint {
                self.setZoomScale(newValue, centeredAt: animationCenterPoint)
            } else {
                zoomScale = newValue
            }
        }
    }
    
    var animationCenterPoint: CGPoint? {
        get { getAssociatedValue(key: "animationCenterPoint", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "animationCenterPoint", object: self) }
    }
    
    func setZoomScale(_ scale: CGFloat, centeredAt point: CGPoint) {
        var scale = CGFloat.minimum(scale, maximumZoomScale)
        scale = CGFloat.maximum(scale, self.minimumZoomScale)
        var translatedZoomPoint : CGPoint = .zero
        translatedZoomPoint.x = point.x + contentOffset.x
        translatedZoomPoint.y = point.y + contentOffset.y
        
        let zoomFactor = 1.0 / zoomScale
        
        translatedZoomPoint.x *= zoomFactor
        translatedZoomPoint.y *= zoomFactor
        
        var destinationRect : CGRect = .zero
        destinationRect.size.width = frame.width / scale
        destinationRect.size.height = frame.height / scale
        destinationRect.origin.x = translatedZoomPoint.x - destinationRect.width * 0.5
        destinationRect.origin.y = translatedZoomPoint.y - destinationRect.height * 0.5
        
        zoom(to: destinationRect, animated: false)
    }
}
#endif

extension ViewAnimator {
    internal func layerAnimation(for keyPath: PartialKeyPath<ViewAnimator>) -> (any ConfigurableAnimationProviding)? {
        switch keyPath {
        case \.backgroundColor: return object.optionalLayer?.animator.animation(for: \.backgroundColor)
        case \.borderColor: return object.optionalLayer?.animator.animation(for: \.borderColor)
        case \.borderWidth: return object.optionalLayer?.animator.animation(for: \.borderWidth)
        case \.shadow: return object.optionalLayer?.animator.animation(for: \.shadow)
        case \.innerShadow: return object.optionalLayer?.animator.animation(for: \.innerShadow)
        case \.alpha: return object.optionalLayer?.animator.animation(for: \.opacity)
        case \.cornerRadius: return object.optionalLayer?.animator.animation(for: \.cornerRadius)
        case \.transform3D: return object.optionalLayer?.animator.animation(for: \.transform)
        case \.scale: return object.optionalLayer?.animator.animation(for: \.scale)
        case \.translation: return object.optionalLayer?.animator.animation(for: \.translation)
        case \.rotation: return object.optionalLayer?.animator.animation(for: \.rotation)
        default: return nil
        }
    }
}

