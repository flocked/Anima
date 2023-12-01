//
//  NSUIView+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

internal extension NSUIView {
    func removeAllConstraints() {
        var _superview = superview
        while let superview = _superview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? NSUIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? NSUIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }
        removeConstraints(constraints)
    }

    /// Sends the view to the front of it's superview.
    func sendToFront() {
        if let superview = superview {
            #if os(macOS)
            superview.addSubview(self)
            #else
            superview.bringSubviewToFront(self)
            #endif
        }
    }

    /// Sends the view to the back of it's superview.
    func sendToBack() {
        if let superview = superview {
            #if os(macOS)
            superview.addSubview(self, positioned: .below, relativeTo: nil)
            #else
            superview.sendSubviewToBack(self)
            #endif
        }
    }
    
    /**
     Returns the enclosing rect for the specified subviews.
     - Parameters subviews: The subviews for the rect.
     - Returns: The rect enclosing all the specified subviews.
     */
    func enclosingRect(for subviews: [NSUIView]) -> CGRect {
        var enlosingFrame = CGRect.zero
        for subview in subviews {
            let frame = convert(subview.bounds, from: subview)
            enlosingFrame = CGRectUnion(enlosingFrame, frame)
        }
        return enlosingFrame
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

    /**
     Moves the specified subview to the index.
     
     - Parameters:
        - view: The view to move.
        - index: The index for moving.
     */
    func moveSubview(_ subview: NSUIView, to toIndex: Int) {
        if let index = subviews.firstIndex(of: subview) {
            moveSubview(at: index, to: toIndex)
        }
    }

    /**
     Moves the specified subviews to the index.
     
     - Parameters:
        - subviews: The subviews to move.
        - toIndex: The index for moving.
     */
    func moveSubviews(_ subviews: [NSUIView], to toIndex: Int, reorder: Bool = false) {
        var indexSet = IndexSet()
        for view in subviews {
            if let index = subviews.firstIndex(of: view), indexSet.contains(index) == false {
                indexSet.insert(index)
            }
        }
        if indexSet.isEmpty == false {
            moveSubviews(at: indexSet, to: toIndex, reorder: reorder)
        }
    }

    /**
     Moves the subview at the specified index to another index.
     
     - Parameters:
        - index: The index of the subview to move.
        - toIndex: The index to where the subview should be moved.
     */
    func moveSubview(at index: Int, to toIndex: Int) {
        moveSubviews(at: IndexSet(integer: index), to: toIndex)
    }

    /**
     Moves subviews at the specified indexes to another index.
     
     - Parameters:
        - indexes: The indexes of the subviews to move.
        - toIndex: The index where the subviews should be moved to.
     */
    func moveSubviews(at indexes: IndexSet, to toIndex: Int, reorder: Bool = false) {
        let subviewsCount = subviews.count
        if subviews.isEmpty == false {
            if toIndex >= 0, toIndex < subviewsCount {
                let indexes = IndexSet(Array(indexes).filter { $0 < subviewsCount })
                #if os(macOS)
                var subviews = self.subviews
                if reorder {
                    for index in indexes.reversed() {
                        subviews.move(from: IndexSet(integer: index), to: toIndex)
                    }
                } else {
                    subviews.move(from: indexes, to: toIndex)
                }
                self.subviews = subviews
                #elseif canImport(UIKit)
                var below = self.subviews[toIndex]
                let subviewsToMove = (reorder == true) ? self.subviews[indexes].reversed() : self.subviews[indexes]
                for subviewToMove in subviewsToMove {
                    insertSubview(subviewToMove, belowSubview: below)
                    below = (reorder == true) ? subviews[toIndex] : subviewToMove
                }
                #endif
            }
        }
    }

    /**
     The first superview that matches the specificed view type.
     
     - Parameters viewType: The type of view to match.
     - Returns: The first parent view that that matches the view type or `nil` if none match or there isn't a parent.
     
     */
    func firstSuperview<V: NSUIView>(for viewType: V.Type) -> V? {
        return self.firstSuperview(where: {$0 is V}) as? V
    }
    
    /**
     The first superview that matches the specificed predicate.
     
     - Parameters predicate: The closure to match.
     - Returns: The first parent view that that is matching the predicate or `nil` if none match or there isn't a parent.
     */
    func firstSuperview(where predicate: (NSUIView)->(Bool)) -> NSUIView? {
        if let superview = superview {
            if predicate(superview) == true {
                return superview
            }
            return superview.firstSuperview(where: predicate)
        }
        return nil
    }
    
    /**
     An array of all subviews upto the maximum depth.
     
     - Parameters depth: The maximum depth. A value of 0 will return subviews of the current view. A value of 1 e.g. returns subviews of the current view and all subviews of the view's subviews.
     */
    func subviews(depth: Int) -> [NSUIView] {
        if depth > 0 {
            return subviews + subviews.flatMap { $0.subviews(depth: depth - 1) }
        } else {
            return subviews
        }
    }

    
    /**
    An array of all subviews matching the specified view type.

     - Parameters:
        - type: The type of subviews.
        - depth: The maximum depth. A value of 0 will return subviews of the current view. A value of 1 e.g. returns subviews of the current view and all subviews of the view's subviews.
     */
    func subviews<V>(type _: V.Type, depth: Int = 0) -> [V] {
        self.subviews(depth: depth).compactMap({$0 as? V})
    }
    
    /**
    An array of all subviews matching the specified predicte.

     - Parameters:
        - predicate: The predicate to match.
        - depth: The maximum depth. A value of 0 will return subviews of the current view. A value of 1 e.g. returns subviews of the current view and all subviews of the view's subviews.
     */
    func subviews(where predicate: (NSUIView)->(Bool), depth: Int = 0) -> [NSUIView] {
        self.subviews(depth: depth).filter({predicate($0) == true})
    }
    
    /**
     Removes all subviews matching the specified view type.

     - Parameters:
        - type: The type of subviews to remove.
        - depth: The maximum depth. A value of 0 will remove all matching subviews of the current view. A value of 1 e.g. removes all marching subviews of the current view and all marching subviews of the view's subviews.
     */
    func removeSubviews(type: NSUIView.Type, depth: Int = 0) {
        subviews(type: type, depth: depth).forEach { $0.removeFromSuperview() }
    }
    
    /**
     Removes all subviews matching the specified predicate.
     
     - Parameters:
        - predicate: The predicate to match.
        - depth: The maximum depth. A value of 0 will remove all matching subviews of the current view. A value of 1 e.g. removes all marching subviews of the current view and all marching subviews of the view's subviews.
     */
    func removeSubviews(where predicate: (NSUIView)->(Bool), depth: Int = 0) {
        subviews(where: predicate, depth: depth).forEach { $0.removeFromSuperview() }
    }
    
    /// Animates a transition to changes made to the view after calling this.
    func transition(_ transition: CATransition) {
        #if os(macOS)
        wantsLayer = true
        layer?.add(transition, forKey: CATransitionType.fade.rawValue)
        #else
        layer.add(transition, forKey: CATransitionType.fade.rawValue)
        #endif
    }
    
    /// Recursive description of the view useful for debugging.
    var recursiveDescription: NSString {
        return value(forKey: "recursiveDescription") as! NSString
    }
}
#endif


internal extension NSUIView {
    var optionalLayer: CALayer? {
        get { self.layer }
    }
}
