//
//  CALayer+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

// import QuartzCore

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension CALayer {
    /// The shadow of the layer.
    var shadow: ShadowConfiguration {
        get { .init(color: shadowColor?.nsUIColor, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point) }
        set {
            shadowColor = newValue.color?.cgColor
            shadowOpacity = Float(newValue.opacity)
            shadowRadius = newValue.radius
            shadowOffset = newValue.offset.size
        }
    }
    
    /// The inner shadow of the layer.
    var innerShadow: ShadowConfiguration {
        get { self.innerShadowLayer?.configuration ?? .none() }
        set { self.configurateInnerShadow(using: newValue) }
    }
    
    /// Sends the layer to the front of it's superlayer.
    func sendToFront() {
        guard let superlayer = superlayer else { return }
        removeFromSuperlayer()
        superlayer.addSublayer(self)
    }
    
    /// Sends the layer to the back of it's superlayer.
    func sendToBack() {
        guard let superlayer = superlayer else { return }
        removeFromSuperlayer()
        superlayer.insertSublayer(self, at: 0)
    }
    
    
    /// Returns the first sublayer of a specific type.
    func firstSublayer<V>(type _: V.Type) -> V? {
        self.sublayers?.first(where: { $0 is V }) as? V
    }
    
    /**
     Adds the specified sublayer and constraints it to the layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
     - layer: The layer to be added.
     - insets: Insets from the new sublayer border to the layer border.
     */
    func addSublayer(withConstraint layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
        self.addSublayer(layer)
        layer.constraintTo(layer: self, insets: insets)
    }
    
    /**
     Inserts the specified layer at the specified index and constraints it to the layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
     - layer: The layer to be added.
     - index: The index at which to insert layer. This value must be a valid 0-based index into the `sublayers` array.
     - insets: Insets from the new sublayer border to the layer border.
     */
    func insertSublayer(withConstraint layer: CALayer, at index: UInt32, insets: NSDirectionalEdgeInsets = .zero) {
        self.insertSublayer(layer, at: index)
        layer.constraintTo(layer: self, insets: insets)
    }
    
    /**
     Constraints the layer to the specified layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` will be constraint to the specified layer. To remove the constraints use `removeConstraints()`.
     
     - Parameters layer: The layer to constraint to.
     */
    func constraintTo(layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
        let layerUpdateHandler: (()->()) = { [weak self] in
            guard let self = self else { return }
            let frameSize = layer.frame.size
            var shapeRect = CGRect(origin: .zero, size: frameSize)
            if frameSize.width > insets.width, frameSize.height > insets.height {
                shapeRect = shapeRect.inset(by: insets)
            }
            
            let position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
            
            self.cornerRadius = layer.cornerRadius
            self.maskedCorners = layer.maskedCorners
            self.cornerCurve = layer.cornerCurve
            self.bounds = shapeRect
            self.position = position
        }
        
        if layerObserver?.observedObject != layer {
            layerObserver = KeyValueObserver(layer)
        }
        
        layerObserver?[\.cornerRadius] = { old, new in
            guard old != new else { return }
            layerUpdateHandler()
        }
        
        layerObserver?[\.cornerCurve] = { old, new in
            guard old != new else { return }
            layerUpdateHandler()
        }
        
        layerObserver?[\.maskedCorners] = { old, new in
            guard old != new else { return }
            layerUpdateHandler()
        }
        
        layerObserver?[\.bounds] = { old, new in
            guard old != new else { return }
            layerUpdateHandler()
        }
        layerUpdateHandler()
    }
    
    /// Removes the layer constraints.
    func removeConstraints() {
        self.layerObserver = nil
    }
    
     var layerObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue(key: "CALayer.boundsObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "CALayer.boundsObserver", object: self) }
    }
    
    /// The associated view using the layer.
    var parentView: NSUIView? {
        if let view = delegate as? NSUIView {
            return view
        }
        return superlayer?.parentView
    }

}
