//
//  NSCollectionView+.swift
//  
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

import AppKit
import Foundation

internal extension NSCollectionView {
    /**
     The frame of the item at the specified index path.
     - Parameters indexPath: The index path of the item.
     - Returns: The frame of the item or nil if no item exists at the specified path.
     */
    func frameForItem(at indexPath: IndexPath) -> CGRect? {
        return layoutAttributesForItem(at: indexPath)?.frame
    }

    /**
     The item item at the specified location.
     - Parameters location: The location of the item.
     - Returns: The item or nil if no item exists at the specified location.
     */
    func item(at location: CGPoint) -> NSCollectionViewItem? {
        if let indexPath = indexPathForItem(at: location) {
            return item(at: indexPath)
        }
        return nil
    }

    /**
     The item index paths for the specified section.
     - Parameters section: The section of the items.
     - Returns: The item index paths.
     */
    func indexPaths(for section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        if numberOfSections > section {
            let numberOfItems = self.numberOfItems(inSection: section)
            for item in 0 ..< numberOfItems {
                indexPaths.append(IndexPath(item: item, section: section))
            }
        }
        return indexPaths
    }

    func scrollToTop() {
        enclosingScrollView?.scrollToBeginningOfDocument(nil)
    }

    func scrollToBottom() {
        enclosingScrollView?.scrollToEndOfDocument(nil)
    }

    /**
     Changes the collection view layout animated.
     - Parameters:
        - layout: The new collection view layout.
        - animationDuration: The animation duration.
        - completion: The completion handler that gets called when the animation is completed.
     */
    func setCollectionViewLayout(_ layout: NSCollectionViewLayout, animationDuration: CGFloat, completion: (() -> ())? = nil) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = animationDuration
                self.animator().collectionViewLayout = layout
            }, completionHandler: { completion?() })
        } else {
            collectionViewLayout = layout
            completion?()
        }
    }

    var contentOffset: CGPoint {
        get { return enclosingScrollView?.contentOffset ?? .zero }
        set { enclosingScrollView?.contentOffset = newValue }
    }

    var contentSize: CGSize { return enclosingScrollView?.contentSize ?? .zero }
}

#endif
