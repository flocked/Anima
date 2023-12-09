//
//  InnerShadowLayer.swift
//  
//
//  Created by Florian Zand on 16.09.21.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A layer with an inner shadow.
class InnerShadowLayer: CALayer {
    /// The configuration of the inner shadow.
    public var configuration: ShadowConfiguration {
        get { ShadowConfiguration(color: shadowColor?.nsUIColor, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point)  }
        set {
            shadowColor = newValue.color?.cgColor
            shadowOpacity = Float(newValue.opacity)
            let needsUpdate = shadowOffset != newValue.offset.size || shadowRadius != newValue.radius
            shadowOffset = newValue.offset.size
            shadowRadius = newValue.radius
            if needsUpdate {
                updateShadowPath()
            }
        }
    }
    
    
    /**
     Initalizes an inner shadow layer with the specified configuration.
     
     - Parameter configuration: The configuration of the inner shadow.
     - Returns: The inner shadow layer.
     */
    public init(configuration: ShadowConfiguration) {
        super.init()
        self.configuration = configuration
    }
    
    
    override public init() {
        super.init()
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        sharedInit()
    }
    
    func sharedInit() {
        shadowOpacity = 0
        shadowColor = nil
        masksToBounds = true
        backgroundColor = .clear
        shadowOffset = .zero
        shadowRadius = 0.0
    }
    
    override public var bounds: CGRect {
        didSet {
            guard oldValue != bounds else { return }
            updateShadowPath()
        }
    }
    
    public override var cornerRadius: CGFloat {
        didSet {
            guard oldValue != cornerRadius else { return }
            updateShadowPath()
        }
    }

    func updateShadowPath() {
        let path: NSUIBezierPath
        let innerPart: NSUIBezierPath
        if cornerRadius != 0.0 {
            path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
            #if os(macOS)
            innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
            #else
            innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
            #endif
        } else {
            path = NSUIBezierPath(rect: bounds.insetBy(dx: -20, dy: -20))
            #if os(macOS)
            innerPart = NSUIBezierPath(rect: bounds).reversed
            #else
            innerPart = NSUIBezierPath(rect: bounds).reversing()
            #endif
        }
        path.append(innerPart)
        shadowPath = path.cgPath
    }
}
