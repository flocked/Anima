//
//  Collection+Unique.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

internal extension Sequence where Element: Equatable {
    /**
     Returns a random element of the collection excluding any of the specified elements.
     
     - Parameters excluding: The elements excluded for the returned element.
     - Returns: A random element from the collection excluding any of the specified elements. If the collection is empty, the method returns nil.
     */
    func randomElement(excluding: [Element]) -> Element? {
       let elements = self.filter({excluding.contains($0) == false})
        guard elements.isEmpty == false else { return nil }
        return elements.randomElement()
    }
}

internal extension Sequence where Element: Equatable {
    /// An array of unique elements.
    func uniqued() -> [Element] {
        var elements: [Element] = []
        for element in self {
            if elements.contains(element) == false {
                elements.append(element)
            }
        }
        return elements
    }
}

internal extension Sequence {
    /**
     An array of elements by filtering the keypath for unique values.
     
     - Parameters keyPath: The keypath for filtering the object.
     */
    func uniqued<T: Equatable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return uniqued(by: { $0[keyPath: keyPath] })
    }

    /**
     An array of unique elements.
     
     - Parameters map: A mapping closure. map accepts an element of this sequence as its parameter and returns a value of the same or of a different type.
     */
    func uniqued<T: Equatable>(by map: (Element) -> T) -> [Element] {
        var uniqueElements: [T] = []
        var ordered: [Element] = []
        for element in self {
            let check = map(element)
            if uniqueElements.contains(check) == false {
                uniqueElements.append(check)
                ordered.append(element)
            }
        }
        return ordered
    }
}
