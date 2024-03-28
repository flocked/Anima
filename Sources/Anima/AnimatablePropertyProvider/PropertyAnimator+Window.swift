//
//  PropertyAnimator+Window.swift
//
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS)
    import AppKit

    extension NSWindow: AnimatablePropertyProvider {
        /**
         Provides animatable properties of the window.

         To animate the properties change their value inside an ``Anima`` animation block, To stop their animations and to change their values imminently, update their values outside an animation block.

         See ``WindowAnimator`` for more information about how to animate and all animatable properties.
         */
        public var animator: WindowAnimator { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: WindowAnimator(self)) }
    }

    /**
     Provides animatable properties of `NSWindow`.

     ### Animating Properties

     To animate the properties, change their values inside an ``Anima`` animation block:

     ```swift
     Anima.animate(withSpring: .smooth) {
        window.animator.frame.size = CGSize(width: 100.0, height: 200.0)
        window.animator.backgroundColor = .systemBlue
     }
     ```
     To stop animations and to change properties immediately, change their values outside an animation block:

     ```swift
     window.animator.backgroundColor = .systemRed
     ```

     ### Accessing Animations

     To access the animation for a property, use ``Anima/AnimationProvider/animation(for:)-80x48``:

     ```swift
     if let animation = window.animator.animation(for: \.frame) {
        animation.stop()
     }
     ```
     
     ### Accessing Animation Value and Velocity
     
     The animation returned via ``Anima/AnimationProvider/animation(for:)-80x48`` provides the current animation value and velocity.

     ```swift
     if let animation = layer.animator.animation(for: \.origin) {
        let velocity = animation.velocity
        let value = animation.value
     }
     ```
     */
    public class WindowAnimator: PropertyAnimator<NSWindow> {
        /// The frame of the window.
        public var frame: CGRect {
            get { self[\._frame] }
            set { self[\._frame] = newValue }
        }

        /// The origin of the window.
        public var origin: CGPoint {
            get { frame.origin }
            set { frame.origin = newValue }
        }

        /// The size of the window. Changing the value keeps the window centered. To change the size without centering use the window's frame size.
        public var size: CGSize {
            get { frame.size }
            set {
                guard size != newValue else { return }
                frame.sizeCentered = newValue
            }
        }

        /// The center of the window.
        public var center: CGPoint {
            get { frame.center }
            set { frame.center = newValue }
        }

        /// The background color of the window.
        public var backgroundColor: NSColor {
            get { self[\.backgroundColor] }
            set { self[\.backgroundColor] = newValue }
        }

        /// The alpha value of the window.
        public var alphaValue: CGFloat {
            get { self[\.alphaValue] }
            set { self[\.alphaValue] = newValue }
        }
    }

    fileprivate extension NSWindow {
        @objc var _frame: CGRect {
            get { frame }
            set { setFrame(newValue, display: false) }
        }
    }
#endif
