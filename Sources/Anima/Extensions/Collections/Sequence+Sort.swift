//
//  Sequence+Sort.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

/// The order of sorting for a sequence
internal enum SequenceSortOrder: Int, Hashable {
    /// An ascending sorting order.
    case ascending
    /// A descending sorting order.
    case descending
}

internal extension Sequence {
    /**
    An array of the elements sorted by the given predicate.
     
     - Parameters compare: The closure to compare the elements.
     - Parameters order: The order of the sorting.
     */
    func sorted<Value>(by compare: ((Element) -> Value), _ order : SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return sorted { compare($0) < compare($1) }
        } else {
            return sorted { compare($0) > compare($1) }
        }
    }
    
    /**
    An array of the elements sorted by the given predicate.
     
     - Parameters compare: The closure to compare the elements.
     - Parameters order: The order of the sorting.
     */
    func sorted<Value>(by compare: ((Element) -> Value?), _ order : SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return self.sorted(by: compare, using: <)
        } else {
            return self.sorted(by: compare, using: >)
        }
    }
    
    /**
    An array of the elements sorted by the given keypath.
     
     - Parameters keyPath: The keypath to compare the elements.
     - Parameters order: The order of the sorting.
     */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order : SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return self.sorted(by: keyPath, using: <)
        } else {
            return self.sorted(by: keyPath, using: >)
        }
    }
    
    /**
    An array of the elements sorted by the given keypath.
     
     - Parameters compare: The keypath to compare the elements.
     - Parameters order: The order of the sorting.
     */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order : SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return self.sorted(by: keyPath, using: <)
        } else {
            return self.sorted(by: keyPath, using: >)
        }
    }
    
    private func sorted<Value>(by compare: (Element) -> Value?, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            guard let b = compare(b) else { return true }
            guard let a = compare(a) else { return false }
            return comparator(a, b)
        }
    }
    
    private func sorted<Value>(by keyPath: KeyPath<Element, Value>, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            return comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
    
    private func sorted<Value>(by keyPath: KeyPath<Element, Value?>, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            guard let b = b[keyPath: keyPath] else { return true }
            guard let a = a[keyPath: keyPath] else { return false }
            return comparator(a, b)
        }
    }
}

internal extension Sequence {
    /**
     Returns the elements of the sequence, sorted using given keyPaths as comparison between elements.

     Provided keyPath's that don't conform to Comparable will be ingnored when sorting.

     - Parameters:
        - keyPaths: The keypaths used for sorting the elements.
        - ascending: If true, the sequence will be sorted in a ascending order, otherwise, descending.
     */
    func sorted(by keyPaths: [PartialKeyPath<Element>], order: SequenceSortOrder = .ascending) -> [Element] {
        return sorted(by: keyPaths.compactMap { PartialSortingKeyPath($0, order: order) })
    }

    /**
     Returns the elements of the sequence, sorted using given keypaths as comparison between elements.
     
     Each keypath defines its own sorting order by `ascending(_ keypath)` / `descending(_ keypath)` or by prependding `>>`(ascending) or `<<` (descending) to a keypath.
     ```swift
     images.sorted(by: [<<\.pixelSize, >>\.creationDate]
     images.sorted(by: [ascending(\.pixelSize), descending(\.creationDate)]
     ```
          
     - Parameters keyPaths: The keypaths used for sorting the elements.
     - Note:Provided keykaths that don't conform to Comparable will be ingnored when sorting.
     */
    func sorted(by keyPaths: [PartialSortingKeyPath<Element>]) -> [Element] {
        sorted { a, b in
            for kp in keyPaths {
                let order = kp.order
                for keyPath in kp.keyPaths {
                    if let val1 = a[keyPath: keyPath] as? any Comparable, let val2 = b[keyPath: keyPath] as? any Comparable {
                            return (order == .ascending) ? val1.isLessThan(val2) : !val1.isLessThan(val2)
                    } else if let valus1 = a[keyPath: keyPath] as? (any Comparable)?, let value2 = b[keyPath: keyPath] as? (any Comparable)? {
                        guard value2 != nil else { return true }
                        guard valus1 != nil else { return false }
                        return (order == .ascending) ? (valus1?.isLessThan(value2) ?? false) : !(valus1?.isLessThan(value2) ?? false)
                    } else {
                        return false
                    }
                }
            }
            return false
        }
    }
    
    /**
     Returns the elements of the sequence, sorted using given keypaths as comparison between elements.
     
     Each keypath defines its own sorting order by `ascending(_ keypath)` / `descending(_ keypath)` or by prependding `>>`(ascending) or `<<` (descending) to a keypath.
     ```swift
     images.sorted(by: [<<\.pixelSize, >>\.creationDate]
     images.sorted(by: [ascending(\.pixelSize), descending(\.creationDate)]
     ```
          
     - Parameters keyPaths: The keypaths used for sorting the elements.
     - Note:Provided keykaths that don't conform to Comparable will be ingnored when sorting.
     */
    func sorted(by keyPaths: PartialSortingKeyPath<Element>...) -> [Element] {
        self.sorted(by: keyPaths)
    }
}


internal struct PartialSortingKeyPath<Root> {
    let keyPaths: [PartialKeyPath<Root>]
    let order: SequenceSortOrder

    internal init(_ keyPath: PartialKeyPath<Root>, order: SequenceSortOrder = .ascending) {
        self.keyPaths = [keyPath]
        self.order = order
    }

    internal init(_ keyPaths: [PartialKeyPath<Root>], order: SequenceSortOrder = .ascending) {
        self.keyPaths = keyPaths
        self.order = order
    }

    /// Returns a keypath used for sorting a sequence ascending.
    public static func ascending(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .ascending)
    }

    /// Returns a keypath used for sorting a sequence descending.
    public static func descending(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .descending)
    }

    /// Returns a keypath used for sorting a sequence ascending.
    public static func ascending(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .ascending)
    }

    /// Returns a keypath used for sorting a sequence descending.
    public static func descending(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .descending)
    }
}
