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

#if os(macOS)
    extension NSView: AnimatablePropertyProvider {}

    public extension AnimatablePropertyProvider where Self: NSView {
        /**
         Provides animatable properties of the view.

         To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update their values outside an animation block.

         See ``ViewAnimator`` for more information about how to animate and all animatable properties.
         */
        var animator: ViewAnimator<Self> { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: ViewAnimator(self)) }
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

     ```swift
     if let velocity = view.animator.animation(for: \.origin) {

     }
     ```

     */
    public class ViewAnimator<View: NSView>: PropertyAnimator<View> {
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
            set { frame.sizeCentered = newValue }
        }

        /// The center of the view.
        public var center: CGPoint {
            get { frame.center }
            set { frame.center = newValue }
        }

        /// The anchor point of the view.
        public var anchorPoint: CGPoint {
            get { object.optionalLayer?.animator.anchorPoint ?? .zero }
            set { object.optionalLayer?.animator.anchorPoint = newValue }
        }

        /// The background color of the view.
        public var backgroundColor: NSColor? {
            get { object.optionalLayer?.animator.backgroundColor?.nsUIColor }
            set {
                object.optionalLayer?.animator.backgroundColor = newValue?.resolvedColor(for: object).cgColor
                object.dynamicColors.background = newValue
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

        /// The border of the view.
        public var border: BorderConfiguration {
            get { object.optionalLayer?.animator.border ?? .zero }
            set {
                object.dynamicColors.border = newValue.color
                var newValue = newValue
                newValue.color = newValue.color?.resolvedColor(for: object)
                object.optionalLayer?.animator.border = newValue
            }
        }

        /*
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
          */

        /// The shadow of the view.
        public var shadow: ShadowConfiguration {
            get { object.optionalLayer?.animator.shadow ?? .none }
            set {
                object.dynamicColors.shadow = newValue.color
                var newValue = newValue
                newValue.color = newValue.color?.resolvedColor(for: object)
                object.optionalLayer?.animator.shadow = newValue
            }
        }

        /// The inner shadow of the view.
        public var innerShadow: ShadowConfiguration {
            get { object.optionalLayer?.animator.innerShadow ?? .none }
            set {
                object.dynamicColors.innerShadow = newValue.color
                var newValue = newValue
                newValue.color = newValue.color?.resolvedColor(for: object)
                object.optionalLayer?.animator.innerShadow = newValue
            }
        }

        /// The three-dimensional transform of the view.
        public var transform3D: CATransform3D {
            get { object.optionalLayer?.animator.transform ?? CATransform3DIdentity }
            set { object.optionalLayer?.animator.transform = newValue }
        }

        /// The scale transform of the view.
        public var scale: CGPoint {
            get { object.optionalLayer?.animator.scale ?? CGPoint(1, 1) }
            set { object.optionalLayer?.animator.scale = newValue }
        }

        /// The translation transform of the view.
        public var translation: CGPoint {
            get { object.optionalLayer?.animator.translation ?? .zero }
            set { object.optionalLayer?.animator.translation = newValue }
        }

        /// The rotation of the view as euler angles in degrees.
        public var rotation: CGVector3 {
            get { object.optionalLayer?.animator.rotation ?? .zero }
            set { object.optionalLayer?.animator.rotation = newValue }
        }

        /// The rotation of the view as euler angles in radians.
        public var rotationInRadians: CGVector3 {
            get { object.optionalLayer?.animator.rotationInRadians ?? .zero }
            set { object.optionalLayer?.animator.rotationInRadians = newValue }
        }

        /// The perspective of the view's transform (e.g. .m34).
        public var perspective: Perspective {
            get { object.optionalLayer?.animator.perspective ?? .zero }
            set { object.optionalLayer?.animator.perspective = newValue }
        }

        /// The shearing of the view's transform.
        public var skew: Skew {
            get { object.optionalLayer?.animator.skew ?? .zero }
            set { object.optionalLayer?.animator.skew = newValue }
        }

        // MARK: - Accessing animations

        /**
         The current animation for the property at the specified keypath, or `nil` if the property isn't animated.

         - Parameter keyPath: The keypath to an animatable property.
         */
        public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<ViewAnimator, Value>) -> AnimationProviding? {
            object.optionalLayer?.animator.lastAccessedPropertyKey = ""
            lastAccessedPropertyKey = ""
            _ = self[keyPath: keyPath]
           return object.optionalLayer?.animator.lastAccessedProperty ?? lastAccessedProperty ?? animation(for: keyPath.stringValue)
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
        
        /**
         The current animation value for the specified property, or the value of the property if it isn't animated.

         - Parameter keyPath: The keypath to an animatable property.
         */
        public func animationValue<Value: AnimatableProperty>(for keyPath: WritableKeyPath<ViewAnimator, Value>) -> Value {
            (animation(for: keyPath) as? (any ConfigurableAnimationProviding))?.value as? Value ?? self[keyPath: keyPath]
        }
    }
#else
    extension UIView: AnimatablePropertyProvider {}

    public extension AnimatablePropertyProvider where Self: UIView {
        /**
         Provides animatable properties of the view.

         To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update their values outside an animation block.

         See ``ViewAnimator`` for more information about how to animate and all animatable properties.
         */
        var animator: ViewAnimator<Self> { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: ViewAnimator(self)) }
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

     ```swift
     if let velocity = view.animator.animation(for: \.origin) {

     }
     ```

     */
    public class ViewAnimator<View: UIView>: PropertyAnimator<View> {
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
            set { frame.sizeCentered = newValue }
        }

        /// The center of the view.
        public var center: CGPoint {
            get { frame.center }
            set { frame.center = newValue }
        }

        /// The anchor point of the view.
        public var anchorPoint: CGPoint {
            get { object.optionalLayer?.animator.anchorPoint ?? .zero }
            set { object.optionalLayer?.animator.anchorPoint = newValue }
        }

        /// The background color of the view.
        public var backgroundColor: UIColor? {
            get { object.optionalLayer?.animator.backgroundColor?.nsUIColor }
            set {
                object.optionalLayer?.animator.backgroundColor = newValue?.resolvedColor(for: object).cgColor
            }
        }

        /// The tint color of the view.
        public var tintColor: UIColor {
            get { self[\.tintColor] }
            set { self[\.tintColor] = newValue }
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

        /// The border of the view.
        public var border: BorderConfiguration {
            get { object.optionalLayer?.animator.border ?? .zero }
            set {
                var newValue = newValue
                newValue.color = newValue.color?.resolvedColor(for: object)
                object.optionalLayer?.animator.border = newValue
            }
        }

        /*
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
          */

        /// The shadow of the view.
        public var shadow: ShadowConfiguration {
            get { object.optionalLayer?.animator.shadow ?? .none }
            set {
                var newValue = newValue
                newValue.color = newValue.color?.resolvedColor(for: object)
                object.optionalLayer?.animator.shadow = newValue
            }
        }

        /// The inner shadow of the view.
        public var innerShadow: ShadowConfiguration {
            get { object.optionalLayer?.animator.innerShadow ?? .none }
            set {
                var newValue = newValue
                newValue.color = newValue.color?.resolvedColor(for: object)
                object.optionalLayer?.animator.innerShadow = newValue
            }
        }

        /// The three-dimensional transform of the view.
        public var transform3D: CATransform3D {
            get { object.optionalLayer?.animator.transform ?? CATransform3DIdentity }
            set { object.optionalLayer?.animator.transform = newValue }
        }

        /// The scale transform of the view.
        public var scale: CGPoint {
            get { object.optionalLayer?.animator.scale ?? CGPoint(1, 1) }
            set { object.optionalLayer?.animator.scale = newValue }
        }

        /// The translation transform of the view.
        public var translation: CGPoint {
            get { object.optionalLayer?.animator.translation ?? .zero }
            set { object.optionalLayer?.animator.translation = newValue }
        }

        /// The rotation of the view as euler angles in degrees.
        public var rotation: CGVector3 {
            get { object.optionalLayer?.animator.rotation ?? .zero }
            set { object.optionalLayer?.animator.rotation = newValue }
        }

        /// The rotation of the view as euler angles in radians.
        public var rotationInRadians: CGVector3 {
            get { object.optionalLayer?.animator.rotationInRadians ?? .zero }
            set { object.optionalLayer?.animator.rotationInRadians = newValue }
        }

        /// The perspective of the view's transform (e.g. .m34).
        public var perspective: Perspective {
            get { object.optionalLayer?.animator.perspective ?? .zero }
            set { object.optionalLayer?.animator.perspective = newValue }
        }

        /// The shearing of the view's transform.
        public var skew: Skew {
            get { object.optionalLayer?.animator.skew ?? .zero }
            set { object.optionalLayer?.animator.skew = newValue }
        }

        // MARK: - Accessing animations

        /**
         The current animation for the property at the specified keypath, or `nil` if the property isn't animated.

         - Parameter keyPath: The keypath to an animatable property.
         */
        public func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<ViewAnimator, Value>) -> AnimationProviding? {
            object.optionalLayer?.animator.lastAccessedPropertyKey = ""
            lastAccessedPropertyKey = ""
            _ = self[keyPath: keyPath]
            if let layerKey = object.optionalLayer?.animator.lastAccessedPropertyKey, layerKey != "" {
                return object.optionalLayer?.animator.animations[layerKey]
            }
            return animations[lastAccessedPropertyKey != "" ? lastAccessedPropertyKey : keyPath.stringValue]
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
#endif

#if os(macOS)

    public extension ViewAnimator where View: NSDatePicker {
        /// The text color of the date picker.
        var textColor: NSColor {
            get { self[\.textColor] }
            set { self[\.textColor] = newValue }
        }
    }

    public extension ViewAnimator where View: NSLevelIndicator {
        /// The minimum value of the level indicator.
        var minValue: Double {
            get { self[\.minValue] }
            set { self[\.minValue] = newValue }
        }

        /// The maximum value of the level indicator.
        var maxValue: Double {
            get { self[\.maxValue] }
            set { self[\.maxValue] = newValue }
        }

        /// The warning value of the level indicator.
        var warningValue: Double {
            get { self[\.warningValue] }
            set { self[\.warningValue] = newValue }
        }

        /// The critical value of the level indicator.
        var criticalValue: Double {
            get { self[\.criticalValue] }
            set { self[\.criticalValue] = newValue }
        }

        /// The fill color of the level indicator.
        var fillColor: NSColor {
            get { self[\.fillColor] }
            set { self[\.fillColor] = newValue }
        }

        /// The warning fill color of the level indicator.
        var warningFillColor: NSColor {
            get { self[\.warningFillColor] }
            set { self[\.warningFillColor] = newValue }
        }

        /// The critical fill color of the level indicator.
        var criticalFillColor: NSColor {
            get { self[\.criticalFillColor] }
            set { self[\.criticalFillColor] = newValue }
        }
    }

    public extension ViewAnimator where View: NSTextField {
        /// The text color of the text field.
        var textColor: NSColor? {
            get { self[\.textColor] }
            set { self[\.textColor] = newValue }
        }

        /// The font size of the text field.
        var fontSize: CGFloat {
            get { self[\.fontSize] }
            set { self[\.fontSize] = newValue }
        }
    }

    public extension ViewAnimator where View: NSTextView {
        /// The font size of the text view.
        var fontSize: CGFloat {
            get { self[\.fontSize] }
            set { self[\.fontSize] = newValue }
        }

        /// The text color of the text view.
        var textColor: NSColor? {
            get { self[\.textColor] }
            set { self[\.textColor] = newValue }
        }
    }

    public extension ViewAnimator where View: NSStackView {
        /// The minimum spacing, in points, between adjacent views in the stack view.
        var spacing: CGFloat {
            get { self[\.spacing] }
            set { self[\.spacing] = newValue }
        }

        /// The geometric padding, in points, inside the stack view, surrounding its views.
        var edgeInsets: NSEdgeInsets {
            get { self[\.edgeInsets] }
            set { self[\.edgeInsets] = newValue }
        }
    }

    public extension ViewAnimator where View: NSScrollView {
        /// The point at which the origin of the content view is offset from the origin of the scroll view.
        var documentOffset: CGPoint {
            get { self[\.contentOffset] }
            set { self[\.contentOffset] = newValue }
        }
                
        /**
         The fractional document offset.
         
         - A value of `CGPoint(x:0, y:0)` indicates the document view is at the bottom left.
         - A value of `CGPoint(x:1, y:1)` indicates the document view is at the top right.
         */
        var documentOffsetFractional: CGPoint {
            get { self[\.documentOffsetFractional] }
            set { self[\.documentOffsetFractional] = newValue }
        }

        /// The size of the document view.
        var documentSize: CGSize {
            get { self[\.documentSize] }
            set { self[\.documentSize] = newValue }
        }

        /// The amount by which the content is currently scaled.
        var magnification: CGFloat {
            get { self[\.magnificationCentered] }
            set {
                object.animationCenterPoint = nil
                self[\.magnificationCentered] = newValue
            }
        }

        /// Magnify the content by the given amount and center the result on the given point.
        func setMagnification(_ magnification: CGFloat, centeredAt point: CGPoint) {
            object.animationCenterPoint = point
            self[\.magnificationCentered] = magnification
        }
    }

    public extension ViewAnimator where View: NSImageView {
        /// The tint color of the image.
        var contentTintColor: NSColor? {
            get { self[\.contentTintColor] }
            set { self[\.contentTintColor] = newValue }
        }
    }

    public extension ViewAnimator where View: NSButton {
        /// The tint color of the button.
        var contentTintColor: NSColor? {
            get { self[\.contentTintColor] }
            set { self[\.contentTintColor] = newValue }
        }
    }

    public extension ViewAnimator where View: NSControl {
        /// The double value of the control.
        var doubleValue: Double {
            get { self[\.doubleValue] }
            set { self[\.doubleValue] = newValue }
        }

        /// The float value of the control.
        var floatValue: Float {
            get { self[\.floatValue] }
            set { self[\.floatValue] = newValue }
        }
    }

    public extension ViewAnimator where View: NSColorWell {
        /// The selected color for the color well.
        var color: NSColor {
            get { self[\.color] }
            set { self[\.color] = newValue }
        }
    }

    public extension ViewAnimator where View: NSBox {
        /// The color of the box’s background when the box is a custom box with a simple line border.
        var fillColor: NSColor {
            get { self[\.fillColor] }
            set { self[\.fillColor] = newValue }
        }

        /// The distances between the border and the content view.
        var contentViewMargins: CGSize {
            get { self[\.contentViewMargins] }
            set { self[\.contentViewMargins] = newValue }
        }

        /// The font size of the title.
        var titleFontSize: CGFloat {
            get { self[\.titleFontSize] }
            set { self[\.titleFontSize] = newValue }
        }
    }

    public extension ViewAnimator where View: NSProgressIndicator {
        /// The current value of the progress indicator.
        var doubleValue: Double {
            get { self[\.doubleValue] }
            set { self[\.doubleValue] = newValue }
        }

        /// The minimum value for the progress indicator.
        var minValue: Double {
            get { self[\.minValue] }
            set { self[\.minValue] = newValue }
        }

        /// The maximum value for the progress indicator.
        var maxValue: Double {
            get { self[\.maxValue] }
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
                    setMagnification(newValue, centeredAt: animationCenterPoint)
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
    public extension ViewAnimator where View: UITextField {
        /// The text color of the text field.
        var textColor: UIColor? {
            get { self[\.textColor] }
            set { self[\.textColor] = newValue }
        }

        /// The font size of the text field.
        var fontSize: CGFloat {
            get { self[\.fontSize] }
            set { self[\.fontSize] = newValue }
        }
    }

    public extension ViewAnimator where View: UITextView {
        /// The font size of the text view.
        var fontSize: CGFloat {
            get { self[\.fontSize] }
            set { self[\.fontSize] = newValue }
        }

        /// The text color of the text view.
        var textColor: UIColor? {
            get { self[\.textColor] }
            set { self[\.textColor] = newValue }
        }
    }

    public extension ViewAnimator where View: UIScrollView {
        /// The point at which the origin of the content view is offset from the origin of the scroll view.
        var contentOffset: CGPoint {
            get { self[\.contentOffset] }
            set { self[\.contentOffset] = newValue }
        }

        /// The size of the content view.
        var contentSize: CGSize {
            get { self[\.contentSize] }
            set { self[\.contentSize] = newValue }
        }

        /// The scale factor applied to the scroll view’s content.
        var zoomScale: CGFloat {
            get { self[\.zoomScaleCentered] }
            set {
                object.animationCenterPoint = nil
                self[\.zoomScaleCentered] = newValue
            }
        }

        /// The custom distance that the content view is inset from the safe area or scroll view edges.
        var contentInset: UIEdgeInsets {
            get { self[\.contentInset] }
            set { self[\.contentInset] = newValue }
        }
    }

    public extension ViewAnimator where View: UIStackView {
        /// The minimum spacing, in points, between adjacent views in the stack view.
        var spacing: CGFloat {
            get { self[\.spacing] }
            set { self[\.spacing] = newValue }
        }
    }

    public extension ViewAnimator where View: UIView {
        /// The default spacing to use when laying out content in a view,
        var directionalLayoutMargins: NSDirectionalEdgeInsets {
            get { self[\.directionalLayoutMargins] }
            set { self[\.directionalLayoutMargins] = newValue }
        }

        /// The default spacing to use when laying out content in the view.
        var layoutMargins: UIEdgeInsets {
            get { self[\.layoutMargins] }
            set { self[\.layoutMargins] = newValue }
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

    public extension ViewAnimator where View: UIImageView {
        /// The tint color of the image.
        var tintColor: UIColor {
            get { self[\.tintColor] }
            set { self[\.tintColor] = newValue }
        }
    }

    public extension ViewAnimator where View: UIButton {
        /// The tint color of the button.
        var tintColor: UIColor {
            get { self[\.tintColor] }
            set { self[\.tintColor] = newValue }
        }
    }

    public extension ViewAnimator where View: UILabel {
        /// The text color of the label.
        var textColor: UIColor {
            get { self[\.textColor] }
            set { self[\.textColor] = newValue }
        }

        /// The font size of the label.
        var fontSize: CGFloat {
            get { self[\.fontSize] }
            set { self[\.fontSize] = newValue }
        }
    }

    #if os(iOS)
        @available(iOS 14.0, *)
        public extension ViewAnimator where View: UIColorWell {
            /// The selected color in the color picker.
            var selectedColor: UIColor? {
                get { self[\.selectedColor] }
                set { self[\.selectedColor] = newValue }
            }
        }
    #endif

    public extension ViewAnimator where View: UIProgressView {
        /// The current progress of the progress view.
        var progress: Float {
            get { self[\.progress] }
            set { self[\.progress] = newValue }
        }
    }

    extension UIScrollView {
        var zoomScaleCentered: CGFloat {
            get { zoomScale }
            set {
                if let animationCenterPoint = animationCenterPoint {
                    setZoomScale(newValue, centeredAt: animationCenterPoint)
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
            scale = CGFloat.maximum(scale, minimumZoomScale)
            var translatedZoomPoint: CGPoint = .zero
            translatedZoomPoint.x = point.x + contentOffset.x
            translatedZoomPoint.y = point.y + contentOffset.y

            let zoomFactor = 1.0 / zoomScale

            translatedZoomPoint.x *= zoomFactor
            translatedZoomPoint.y *= zoomFactor

            var destinationRect: CGRect = .zero
            destinationRect.size.width = frame.width / scale
            destinationRect.size.height = frame.height / scale
            destinationRect.origin.x = translatedZoomPoint.x - destinationRect.width * 0.5
            destinationRect.origin.y = translatedZoomPoint.y - destinationRect.height * 0.5

            zoom(to: destinationRect, animated: false)
        }
    }
#endif
