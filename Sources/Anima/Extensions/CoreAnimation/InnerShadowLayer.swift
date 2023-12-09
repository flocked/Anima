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
        get { ShadowConfiguration(color: self.shadowColor?.nsUIColor, opacity: CGFloat(self.shadowOpacity), radius: self.shadowRadius, offset: CGPoint(x: self.shadowOffset.width, y: self.shadowOffset.height))  }
        set {
            self.shadowColor = newValue.color?.cgColor
            self.shadowOpacity = Float(newValue.opacity)
            self.shadowOffset = CGSize(width: newValue.offset.x, height: newValue.offset.y)
            self.shadowRadius = newValue.radius
        }
    }
    
    
    /**
     Initalizes an inner shadow layer with the specified configuration.
     
     - Parameters configuration: The configuration of the inner shadow.
     - Returns: The inner shadow layer.
     */
    public init(configuration: ShadowConfiguration) {
        super.init()
        self.configuration = configuration
    }
    
    
    override public init() {
        super.init()
        self.sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        self.sharedInit()
    }
    
    func sharedInit() {
        self.shadowOpacity = 0
        self.shadowColor = nil
        self.shadowOffset = .zero
        self.shadowRadius = 0.0
    }
    
    public override var shadowRadius: CGFloat {
        didSet { if !isUpdating, oldValue != shadowRadius { self.update() } }
    }
    
    public override var shadowOffset: CGSize {
        didSet { if !isUpdating, oldValue != shadowOffset { self.update() } }
    }

    var isUpdating: Bool = false
    override public var frame: CGRect {
        didSet { if !isUpdating, oldValue != frame {
            update() } }
    }
    
    override public var bounds: CGRect {
        didSet { if !isUpdating, oldValue != bounds {
            update() } }
    }
    
    public override var cornerRadius: CGFloat {
        didSet { if !isUpdating, oldValue != cornerRadius {
            update() } }
    }

    func update() {
            var path = NSUIBezierPath(rect: bounds.insetBy(dx: -20, dy: -20))
            #if os(macOS)
            var innerPart = NSUIBezierPath(rect: bounds).reversed
            #else
            var innerPart = NSUIBezierPath(rect: bounds).reversing()
            #endif
            if cornerRadius != 0.0 {
                path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
                #if os(macOS)
                innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
                #else
                innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
                #endif
            }
            path.append(innerPart)
            shadowPath = path.cgPath
            masksToBounds = true
            backgroundColor = .clear
    }

    override public func display() {
        super.display()
        update()
    }
}
