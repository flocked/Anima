//
//  NSUIView+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension NSUIView {
    var optionalLayer: CALayer? {
        #if os(macOS)
            wantsLayer = true
        #endif
        return layer
    }

    /**
     Inserts the subview at the specified index.

     - Parameters:
        - view: The view to insert.
        - index: The index of insertation.
     */
    func insertSubview(_ view: NSUIView, at index: Int) {
        guard index < self.subviews.count else {
            addSubview(view)
            return
        }
        #if os(macOS)
            var subviews = subviews
            subviews.insert(view, at: index)
            self.subviews = subviews
        #elseif canImport(UIKit)
            insertSubview(view, belowSubview: self.subviews[index])
        #endif
    }
}

#if os(macOS)
    extension NSView {
        struct DynamicColors {
            var background: NSColor? {
                mutating get { get(\._background, view?.layer?.backgroundColor) }
                set { _background = newValue?.isDynamic == true ? newValue : nil }
            }

            var shadow: NSColor? {
                mutating get { get(\._shadow, view?.layer?.shadowColor) }
                set { _shadow = newValue?.isDynamic == true ? newValue : nil }
            }
            
            var border: NSColor? {
                mutating get { get(\._border, view?.layer?.borderColor) }
                set { _border = newValue?.isDynamic == true ? newValue : nil }
            }
            
            var innerShadow: NSColor? {
                mutating get { get(\._innerShadow, view?.layer?.innerShadow.color?.cgColor) }
                set { _innerShadow = newValue?.isDynamic == true ? newValue : nil }
            }
            
            var _shadow: NSColor?
            var _innerShadow: NSColor?
            var _border: NSColor?
            var _background: NSColor?
            weak var view: NSView?
            
            mutating func update() {
                guard let view = view, let layer = view.layer else { return }
                if let shadow = shadow?.resolvedColor(for: view).cgColor {
                    layer.shadowColor = shadow
                }
                if let border = border?.resolvedColor(for: view).cgColor {
                    layer.borderColor = border
                }
                if let background = background?.resolvedColor(for: view).cgColor {
                    layer.backgroundColor = background
                }
            }

            mutating func get(_ keyPath: WritableKeyPath<Self, NSColor?>, _ cgColor: CGColor?) -> NSColor? {
                guard let dynamics = self[keyPath: keyPath]?.dynamicColors else { return nil }
                if cgColor != dynamics.light.cgColor, cgColor != dynamics.dark.cgColor {
                    self[keyPath: keyPath] = nil
                }
                return self[keyPath: keyPath]
            }
            
            var needsObserver: Bool {
                _background != nil || _border != nil || _shadow != nil || _innerShadow != nil
            }
        }

        var dynamicColors: DynamicColors {
            get { getAssociatedValue("dynamicColors", initialValue: DynamicColors(view: self)) }
            set { setAssociatedValue(newValue, key: "dynamicColors")
                setupEffectiveAppearanceObserver()
            }
        }

        var effectiveAppearanceObservation: NSKeyValueObservation? {
            get { getAssociatedValue("effectiveAppearanceObservation") }
            set {  setAssociatedValue(newValue, key: "effectiveAppearanceObservation") }
        }

        func setupEffectiveAppearanceObserver() {
            if !dynamicColors.needsObserver {
                effectiveAppearanceObservation = nil
            } else if effectiveAppearanceObservation == nil {
                effectiveAppearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                    self?.dynamicColors.update()
                }
            }
        }
    }

#endif
