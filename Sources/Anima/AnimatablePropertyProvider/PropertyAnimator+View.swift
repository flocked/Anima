//
//  PropertyAnimator+View.swift
//
//
//  Created by Florian Zand on 28.03.24.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

#if os(macOS)
    extension NSView: AnimatablePropertyProvider {}

    public extension AnimatablePropertyProvider where Self: NSView {
        /**
         Provides animatable properties of the view.

         To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update their values outside an animation block.

         See ``ViewAnimator`` for more information about how to animate and all animatable properties.
         */
        var animator: ViewAnimator<Self> { getAssociatedValue("PropertyAnimator", initialValue: ViewAnimator(self)) }
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

     To access the animation for a property, use ``Anima/AnimationProvider/animation(for:)-6k79l``:

     ```swift
     if let animation = view.animator.animation(for: \.frame) {
        animation.stop()
     }
     ```
     
     ### Accessing Animation Value and Velocity
     
     The animation returned via ``Anima/AnimationProvider/animation(for:)-6k79l`` provides the current animation value and velocity.

     ```swift
     if let animation = view.animator.animation(for: \.frame) {
        let velocity = animation.velocity
        let value = animation.value
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
        
        /// The view’s position on the z axis.
        public var zPosition: CGFloat {
            get { object.optionalLayer?.animator.zPosition ?? .zero }
            set { object.optionalLayer?.animator.zPosition = newValue }
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
                if let layer = object.optionalLayer, layer.animator.backgroundColor == nil || layer.animator.backgroundColor?.alpha == 0.0 {
                    layer.backgroundColor = newValue?.resolvedColor(for: object).withAlphaComponent(0.0).cgColor
                }
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
                object.optionalLayer?.animator.border = newValue.resolved(for: object)
            }
        }

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
                object.optionalLayer?.animator.innerShadow = newValue.resolved(for: object)
            }
        }

        /// The three-dimensional transform of the view.
        public var transform3D: CATransform3D {
            get { object.optionalLayer?.animator.transform ?? CATransform3DIdentity }
            set { object.optionalLayer?.animator.transform = newValue }
        }

        /// The scale transform of the view.
        public var scale: Scale {
            get { object.optionalLayer?.animator.scale ?? .none }
            set { object.optionalLayer?.animator.scale = newValue }
        }

        /// The translation transform of the view.
        public var translation: CGPoint {
            get { object.optionalLayer?.animator.translation ?? .zero }
            set { object.optionalLayer?.animator.translation = newValue }
        }

        /// The rotation of the view as euler angles in degrees.
        public var rotation: Rotation {
            get { object.optionalLayer?.animator.rotation ?? .zero }
            set { object.optionalLayer?.animator.rotation = newValue }
        }

        /// The rotation of the view as euler angles in radians.
        public var rotationInRadians: Rotation {
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
        
        /// Adds the view animated by fading it in.
        public func addSubview(_ view: NSView) {
            guard view !== object else { return }
            view.removeSuperview = nil
            Anima.nonAnimated {
                view.animator.alpha = 0.0
            }
            object.addSubview(view)
            view.animator.alpha = 1.0
        }
        
        /**
         Removes the view from it's superview by fading it out.
         
         The view is removed after the fade out animation finishes.
         */
        public func removeFromSuperview() {
            guard let superview = object.superview else { return }
            object.removeSuperview = superview
            object.animator.alpha = 0.0
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
        var animator: ViewAnimator<Self> { getAssociatedValue("PropertyAnimator", initialValue: ViewAnimator(self)) }
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
                if let layer = object.optionalLayer, layer.animator.backgroundColor == nil || layer.animator.backgroundColor?.alpha == 0.0 {
                    layer.backgroundColor = newValue?.resolvedColor(for: object).withAlphaComponent(0.0).cgColor
                }
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
            set { object.optionalLayer?.animator.border = newValue.resolved(for: object) }
        }

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
            set { object.optionalLayer?.animator.innerShadow = newValue.resolved(for: object) }
        }

        /// The three-dimensional transform of the view.
        public var transform3D: CATransform3D {
            get { object.optionalLayer?.animator.transform ?? CATransform3DIdentity }
            set { object.optionalLayer?.animator.transform = newValue }
        }

        /// The scale transform of the view.
        public var scale: Scale {
            get { object.optionalLayer?.animator.scale ?? .none }
            set { object.optionalLayer?.animator.scale = newValue }
        }

        /// The translation transform of the view.
        public var translation: CGPoint {
            get { object.optionalLayer?.animator.translation ?? .zero }
            set { object.optionalLayer?.animator.translation = newValue }
        }

        /// The rotation of the view as euler angles in degrees.
        public var rotation: Rotation {
            get { object.optionalLayer?.animator.rotation ?? .zero }
            set { object.optionalLayer?.animator.rotation = newValue }
        }

        /// The rotation of the view as euler angles in radians.
        public var rotationInRadians: Rotation {
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
        
        /// The default spacing to use when laying out content in a view,
        public var directionalLayoutMargins: NSDirectionalEdgeInsets {
            get { self[\.directionalLayoutMargins] }
            set { self[\.directionalLayoutMargins] = newValue }
        }

        /// The default spacing to use when laying out content in the view.
        public var layoutMargins: UIEdgeInsets {
            get { self[\.layoutMargins] }
            set { self[\.layoutMargins] = newValue }
        }
        
        /// Adds the view animated by fading it in.
        public func addSubview(_ view: UIView) {
            guard view !== object else { return }
            view.removeSuperview = nil
            Anima.nonAnimated {
                view.animator.alpha = 0.0
            }
            object.addSubview(view)
            view.animator.alpha = 1.0
        }
        
        /**
         Removes the view from it's superview by fading it out.
         
         The view is removed after the fade out animation finishes.
         */
        public func removeFromSuperview() {
            guard let superview = object.superview else { return }
            object.removeSuperview = superview
            object.animator.alpha = 0.0
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
        func magnification(_ magnification: CGFloat, centeredAt point: CGPoint) {
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
        
        /// Magnify the content by the given amount and center the result on the given point.
        func zoomScale(_ zoomScale: CGFloat, centerAt center: CGPoint) {
            object.animationCenterPoint = center
            self[\.zoomScaleCentered] = zoomScale
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
#endif
