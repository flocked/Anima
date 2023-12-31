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
    /// Sends the layer to the front of it's superlayer.
    func sendToFront() {
        guard let superlayer = superlayer else { return }
        removeFromSuperlayer()
        superlayer.addSublayer(self)
    }
    
    var _transform: CATransform3D {
        get { transform }
        set {
            DisableActions {
              transform = newValue
            }
        }
    }
    
    /// Sends the layer to the back of it's superlayer.
    func sendToBack() {
        guard let superlayer = superlayer else { return }
        removeFromSuperlayer()
        superlayer.insertSublayer(self, at: 0)
    }
    
    
    /// Returns the first sublayer of a specific type.
    func firstSublayer<V>(type _: V.Type) -> V? {
        sublayers?.first(where: { $0 is V }) as? V
    }
    
    /**
     Adds the specified sublayer and constraints it to the layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified sublayer will be constraint to the layer. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
        - layer: The layer to be added.
        - insets: Insets from the new sublayer border to the layer border.
     */
    func addSublayer(withConstraint layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
        addSublayer(layer)
        layer.constraintTo(layer: self, insets: insets)
    }
    
    /**
     Inserts the specified layer at the specified index and constraints it to the layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified sublayer will be constraint to the layer. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
        - layer: The layer to be added.
        - index: The index at which to insert layer. This value must be a valid 0-based index into the `sublayers` array.
        - insets: Insets from the new sublayer border to the layer border.
     */
    func insertSublayer(withConstraint layer: CALayer, at index: UInt32, insets: NSDirectionalEdgeInsets = .zero) {
        insertSublayer(layer, at: index)
        layer.constraintTo(layer: self, insets: insets)
    }
    
    /**
     Constraints the layer to the specified layer.
     
     The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` will be constraint to the specified layer. To remove the constraints use `removeConstraints()`.
     
     - Parameters:
        - layer: The layer to constraint to.
        - insets: Insets from the layer's border to the specified other layer.
     */
    func constraintTo(layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
        let layerBoundsUpdate: (()->()) = { [weak self] in
            guard let self = self else { return }
            let frameSize = layer.frame.size
            var shapeRect = CGRect(origin: .zero, size: frameSize)
            if frameSize.width > insets.width, frameSize.height > insets.height {
                shapeRect = shapeRect.inset(by: insets)
            }
            let position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
            bounds = shapeRect
            self.position = position
        }
        
        let layerUpdate: (()->()) = { [weak self] in
            guard let self = self else { return }
            cornerRadius = layer.cornerRadius
            maskedCorners = layer.maskedCorners
            cornerCurve = layer.cornerCurve
        }
        
        if layerObserver?.observedObject != layer {
            layerObserver = KeyValueObserver(layer)
        }
        
        layerObserver?[\.cornerRadius] = { old, new in
            guard old != new else { return }
            layerUpdate()
        }
        
        layerObserver?[\.cornerCurve] = { old, new in
            guard old != new else { return }
            layerUpdate()
        }
        
        layerObserver?[\.maskedCorners] = { old, new in
            guard old != new else { return }
            layerUpdate()
        }
        
        layerObserver?[\.bounds] = { old, new in
            guard old != new else { return }
            layerBoundsUpdate()
        }
        layerBoundsUpdate()
        layerUpdate()
    }
    
    /// Removes the layer constraints.
    func removeConstraints() {
        layerObserver = nil
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

// Runs the `CALayer` changes without any animations.
let DisableActions = { (changes: () -> Void) in
  CATransaction.begin()
  CATransaction.setDisableActions(true)
  changes()
  CATransaction.commit()
}
