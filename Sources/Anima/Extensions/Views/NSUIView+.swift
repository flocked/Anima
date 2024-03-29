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
        // Saves dynamics colors that provide both a light and dark color variant and updates them inside the view if the appearance changes from light to dark or vice versa.
        struct DynamicColors {
            var shadow: NSColor? {
                didSet { if shadow?.isDynamic == false { shadow = nil } }
            }

            var innerShadow: NSColor? {
                didSet { if innerShadow?.isDynamic == false { innerShadow = nil } }
            }

            var border: NSColor? {
                didSet { if border?.isDynamic == false { border = nil } }
            }

            var background: NSColor? {
                didSet { if background?.isDynamic == false { background = nil } }
            }

            var needsAppearanceObserver: Bool {
                background != nil || border != nil || shadow != nil || innerShadow != nil
            }

            mutating func update(_ keyPath: WritableKeyPath<Self, NSColor?>, cgColor: CGColor?) {
                guard let dynamics = self[keyPath: keyPath]?.dynamicColors else { return }
                if cgColor != dynamics.light.cgColor, cgColor != dynamics.dark.cgColor {
                    self[keyPath: keyPath] = nil
                }
            }
        }

        var dynamicColors: DynamicColors {
            get { getAssociatedValue(key: "dynamicColors", object: self, initialValue: DynamicColors()) }
            set { set(associatedValue: newValue, key: "dynamicColors", object: self)
                setupEffectiveAppearanceObserver()
            }
        }

        var _effectiveAppearanceKVO: NSKeyValueObservation? {
            get { getAssociatedValue(key: "_viewEffectiveAppearanceKVO", object: self) }
            set { set(associatedValue: newValue, key: "_viewEffectiveAppearanceKVO", object: self) }
        }

        func setupEffectiveAppearanceObserver() {
            if dynamicColors.needsAppearanceObserver {
                if _effectiveAppearanceKVO == nil {
                    _effectiveAppearanceKVO = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                        self?.updateEffectiveColors()
                    }
                }
            } else {
                _effectiveAppearanceKVO?.invalidate()
                _effectiveAppearanceKVO = nil
            }
        }

        func updateEffectiveColors() {
            dynamicColors.update(\.shadow, cgColor: layer?.shadowColor)
            dynamicColors.update(\.background, cgColor: layer?.backgroundColor)
            dynamicColors.update(\.border, cgColor: layer?.borderColor)
            dynamicColors.update(\.innerShadow, cgColor: layer?.innerShadowLayer?.shadowColor)

            if let color = dynamicColors.shadow?.resolvedColor(for: self).cgColor {
                layer?.shadowColor = color
            }
            if let color = dynamicColors.border?.resolvedColor(for: self).cgColor {
                layer?.borderColor = color
            }
            if let color = dynamicColors.background?.resolvedColor(for: self).cgColor {
                layer?.backgroundColor = color
            }
            if let color = dynamicColors.innerShadow?.resolvedColor(for: self).cgColor {
                layer?.innerShadowLayer?.shadowColor = color
            }

            if dynamicColors.needsAppearanceObserver == false {
                _effectiveAppearanceKVO?.invalidate()
                _effectiveAppearanceKVO = nil
            }
        }
    }

#endif
