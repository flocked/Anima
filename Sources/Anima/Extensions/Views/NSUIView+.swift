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
        get {
            #if os(macOS)
            wantsLayer = true
            #endif
           return self.layer
        }
    }
    
    /**
     Inserts the subview at the specified index.
     
     - Parameters:
        - view: The view to insert.
        - index: The index of insertation.
     */
    func insertSubview(_ view: NSUIView, at index: Int) {
        guard index < self.subviews.count else {
            self.addSubview(view)
            return
        }
        #if os(macOS)
        var subviews = self.subviews
        subviews.insert(view, at: index)
        self.subviews = subviews
        #elseif canImport(UIKit)
        insertSubview(view, belowSubview: self.subviews[index])
        #endif
    }
}
