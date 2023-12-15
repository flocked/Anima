//
//  NSView+.swift
//  
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)
import AppKit
import Decomposed

extension NSView {
    /// The view whose alpha channel is used to mask a view’s content.
    @objc dynamic var mask: NSView? {
        get { layer?.mask?.parentView  }
        set {
            wantsLayer = true
            newValue?.wantsLayer = true
            newValue?.removeFromSuperview()
            layer?.mask = newValue?.layer
        }
    }
    
    /// The anchor point of the view’s bounds rectangle.
    @objc dynamic var anchorPoint: CGPoint {
        get { layer?.anchorPoint ?? .zero }
        set {
            wantsLayer = true
            setAnchorPoint(newValue)
        }
    }
    
    /// Sets the anchor point of the view’s bounds rectangle while retaining the position.
    func setAnchorPoint(_ anchorPoint: CGPoint) {
        guard let layer = layer else { return }
        var newPoint = CGPoint(bounds.size.width * anchorPoint.x, bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(bounds.size.width * layer.anchorPoint.x, bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(layer.affineTransform())
        oldPoint = oldPoint.applying(layer.affineTransform())

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = anchorPoint
    }
    
    var alpha: CGFloat {
        get { guard let cgValue = layer?.opacity else { return 1.0 }
            return CGFloat(cgValue)
        }
        set {
            wantsLayer = true
            layer?.opacity = Float(newValue)
        }
    }
}

extension NSView {
    // Saves dynamics colors that provide both a light and dark color variant and updates them inside the view if the appearance changes from light to dark or vice versa.
    struct DynamicColors {
        var shadow: NSColor? = nil {
            didSet { if shadow?.isDynamic == false { shadow = nil } } }
        var innerShadow: NSColor? = nil {
            didSet { if innerShadow?.isDynamic == false { innerShadow = nil } } }
        var border: NSColor? = nil {
            didSet { if border?.isDynamic == false { border = nil } } }
        var background: NSColor? = nil {
            didSet { if background?.isDynamic == false { background = nil } } }
        
        var needsAppearanceObserver: Bool {
            background != nil || border != nil || shadow != nil || innerShadow != nil
        }
        
        mutating func update(_ keyPath: WritableKeyPath<Self, NSColor?>, cgColor: CGColor?) {
            guard let dynamics = self[keyPath: keyPath]?.dynamicColors else { return }
            if  cgColor != dynamics.light.cgColor && cgColor != dynamics.dark.cgColor {
                self[keyPath: keyPath] = nil
            }
        }
    }
    
    var dynamicColors: DynamicColors {
        get { getAssociatedValue(key: "dynamicColors", object: self, initialValue: DynamicColors() ) }
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
