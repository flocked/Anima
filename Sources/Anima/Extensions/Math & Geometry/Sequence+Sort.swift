//
//  Sequence+Sort.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

/// The order of sorting for a sequence
enum SequenceSortOrder: Int, Hashable {
    /// An ascending sorting order.
    case ascending
    /// A descending sorting order.
    case descending
}

extension Sequence {
    /**
     An array of the elements sorted by the given keypath.

      - Parameter keyPath: The keypath to compare the elements.
      - Parameter order: The order of the sorting.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        order == .ascending ? sorted(by: keyPath, using: <) : sorted(by: keyPath, using: >)
    }

    /**
     An array of the elements sorted by the given keypath.

      - Parameter compare: The keypath to compare the elements.
      - Parameter order: The order of the sorting.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        order == .ascending ? sorted(by: keyPath, using: <) : sorted(by: keyPath, using: >)
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
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
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
