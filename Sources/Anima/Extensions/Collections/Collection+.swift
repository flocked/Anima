//
//  Collection+.swift
//
//
//  Created by Florian Zand on 15.01.22.
//

import Foundation

internal extension MutableCollection {
    /// Edits the elements.
    mutating func editEach(_ body: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try body(&self[index])
        }
    }
}

internal extension Collection {
    subscript(safe safeIndex: Index) -> Element? {
        if isEmpty == false, safeIndex < count - 1 {
            return self[safeIndex]
        }
        return nil
    }
    
    subscript(indexes: [Index]) -> [Element] {
        return indexes.compactMap { self[safe: $0] }
    }
}

internal extension MutableCollection {
    subscript(safe safeIndex: Index) -> Element? {
        get {
            if isEmpty == false, safeIndex < count - 1 {
                return self[safeIndex]
            }
            return nil
        }
        set {
            if isEmpty == false, safeIndex < count - 1, let newValue = newValue {
                self[safeIndex] = newValue
            }
        }
    }
}

internal extension Collection where Element: Equatable {
    /**
     A Boolean value indicating whether the collection contains any of the specified elements.
     
     - Parameters elements: The elements.
     - Returns: `true` if any of the elements exists in the collection, or` false` if non exist in the option set.
     */
    func contains<S>(any elements: S) -> Bool where S : Sequence, Element == S.Element {
        for element in elements {
            if self.contains(element) {
                return true
            }
        }
        return false
    }
    
    /**
     A Boolean value indicating whether the collection contains all specified elements.
     - Parameters elements: The elements.
     - Returns: `true` if all elements exist in the collection, or` false` if not.
     */
    func contains<S>(all elements: S) -> Bool where S : Sequence, Element == S.Element {
        for element in elements {
            if self.contains(element) == false {
                return false
            }
        }
        return true
    }
}

internal extension Collection {
    /// Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
    func grouped<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [Key: [Element]] {
        try Dictionary(grouping: self, by: keyForValue)
    }
    
    /// Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
    func grouped<Key>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] {
        Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }
    
    /// Splits the collection by the specified keypath and values that are returned for each keypath.
    func split<Key>(by keyPath: KeyPath<Element, Key>) -> [(key: Key, values: [Element])] where Key: Equatable {
        self.split(by: { $0[keyPath: keyPath] })
    }
    
    /// Splits the collection by the key returned from the specified closure and values that are returned for each key.
    func split<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [(key: Key, values: [Element])] where Key: Equatable {
        var output: [(key: Key, values: [Element])] = []
        for value in self {
            let key = try keyForValue(value)
            if let index = output.firstIndex(where: {$0.key == key}) {
                output[index].values.append(value)
            } else {
                output.append((key, [value]))
            }
        }
        return output
    }
}

internal extension Collection where Index == Int {
    subscript(safe range: Range<Index>) -> [Element] {
        return range.compactMap({ self[safe: $0] })
    }
    
    subscript(safe range: ClosedRange<Int>) -> [Element] {
        return range.compactMap({ self[safe: $0] })
    }

    subscript(indexes: IndexSet) -> [Element] {
        return indexes.compactMap { self[safe: $0] }
    }
}

internal extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    /**
     Removes the specificed elements and returns them.
     - Parameters elements: The elements to remove.
     - Returns: Returns the removed elements.
     */
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        var removedElements: [Element] = []
        for element in elements {
            while let index = self.firstIndex(of: element) {
                let removed = self.remove(at: index)
                removedElements.append(removed)
            }
        }
        return removedElements
    }
}

internal extension RangeReplaceableCollection where Self.Indices.Element == Int {
    @discardableResult
    /**
     Removes the elements at the specified indexes and returns them.
     - Parameters indexes: The indexes of the elements to remove.
     - Returns: Returns the removed elements.
     */
    mutating func remove(at indexes: IndexSet) -> [Self.Element] {
        var returnItems = [Self.Element]()
        for (index, _) in enumerated().reversed() {
            if indexes.contains(index) {
                returnItems.insert(remove(at: index), at: startIndex)
            }
        }
        return returnItems
    }

    @discardableResult
    /**
     Moves the element at the specified index to the specified position.
     - Parameters index: The index of the element.
     - Parameters destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(from index: Int, to destinationIndex: Index) -> Bool {
        return move(from: IndexSet([index]), to: destinationIndex)
    }

    @discardableResult
    /**
     Moves the elements at the specified indexes to the specified position.
     - Parameters indexes: The indexes of the elements to move.
     - Parameters destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(from indexes: IndexSet, to destinationIndex: Index) -> Bool {
        guard indexes.isSubset(of: IndexSet(indices)) else {
            debugPrint("Source indices out of range.")
            return false
        }
        guard (0 ..< count + indexes.count).contains(destinationIndex) else {
            debugPrint("Destination index out of range.")
            return false
        }

        let itemsToMove = remove(at: indexes)

        let modifiedDestinationIndex: Int = destinationIndex - indexes.filter { destinationIndex > $0 }.count

        insert(contentsOf: itemsToMove, at: modifiedDestinationIndex)

        return true
    }
}

internal extension RangeReplaceableCollection where Self.Indices.Element == Int, Element: Equatable {
    @discardableResult
    /**
     Moves the specified element to the specified position.
     - Parameters element: The element to move.
     - Parameters destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(_ element: Element, to destinationIndex: Self.Indices.Element) -> Bool {
        let indexes = self.indexes(for: [element])
        return move(from: indexes, to: destinationIndex)
    }

    @discardableResult
    /**
     Moves the specified elements to the specified position.
     - Parameters elements: The elements to move.
     - Parameters destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move<S: Sequence<Element>>(_ elements: S, to destinationIndex: Self.Indices.Element) -> Bool {
        let indexes = self.indexes(for: elements)
        return move(from: indexes, to: destinationIndex)
    }
    
    @discardableResult
    /**
     Moves the specified element before the specified `beforeElement`.
     - Parameters element: The element to move.
     - Parameters beforeElement: The element to move before.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(_ element: Element, before beforeElement: Element) -> Bool {
        let indexes = self.indexes(for: [element])
        guard let destinationIndex = self.firstIndex(of: beforeElement) else { return false }
        return move(from: indexes, to: destinationIndex)
    }

    @discardableResult
    /**
     Moves the specified elements before the specified `beforeElement`.
     - Parameters elements: The elements to move.
     - Parameters beforeElement: The element to move before.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move<S: Sequence<Element>>(_ elements: S, before beforeElement: Element) -> Bool {
        guard let destinationIndex = self.firstIndex(of: beforeElement), destinationIndex + 1 < self.count else { return false }
        let indexes = self.indexes(for: elements)
        return move(from: indexes, to: destinationIndex)
    }
    
    @discardableResult
    /**
     Moves the specified element after the specified `afterElement`.
     - Parameters element: The element to move.
     - Parameters afterElement: The element to move after.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(_ element: Element, after afterElement: Element) -> Bool {
        let indexes = self.indexes(for: [element])
        guard let destinationIndex = self.firstIndex(of: afterElement), destinationIndex + 1 < self.count else { return false }
        return move(from: indexes, to: destinationIndex + 1)
    }

    @discardableResult
    /**
     Moves the specified elements after the specified `afterElement`.
     - Parameters elements: The elements to move.
     - Parameters afterElement: The element to move after.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move<S: Sequence<Element>>(_ elements: S, after afterElement: Element) -> Bool {
        guard let destinationIndex = self.firstIndex(of: afterElement), destinationIndex + 1 < self.count else { return false }
        let indexes = self.indexes(for: elements)
        return move(from: indexes, to: destinationIndex + 1)
    }

    @discardableResult
    /**
     Removes the specified element.
     - Parameters element: The element remove.
     - Returns: Returns the removed element.
     */
    mutating func remove(_ element: Element) -> Element? {
        let indexes = self.indexes(for: [element])
        return remove(at: indexes).first
    }

    @discardableResult
    /**
     Removes the specified elements.
     - Parameters elements: The elements to remove.
     - Returns: Returns the removed elements.
     */
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        let indexes = self.indexes(for: elements)
        return remove(at: indexes)
    }

    /**
     Replaces the first appearance of the specified element with another.
     - Parameters element: The element to replace.
     - Parameters another: The replacing element.
     */
    mutating func replace(first element: Element, with another: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(another, at: index)
        }
    }

    /**
     Replaces the first appearance of the specified element with other elements.
     - Parameters element: The element to replace.
     - Parameters newElements: The replacing elements.
     */
    mutating func replace<C>(first element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(contentsOf: newElements, at: index)
        }
    }

    /**
     Replaces all appearances of the specified element with another.
     - Parameters element: The element to replace.
     - Parameters another: The replacing element.
     */
    mutating func replace(_ element: Element, with: Element) {
        guard let index = self.firstIndex(of: element) else { return }
        self.remove(element)
        self.insert(element, at: index)
    }

    /**
     Replaces all appearance of the specified element with other elements.
     - Parameters element: The element to replace.
     - Parameters newElements: The replacing elements.
     */
    mutating func replace<C>(_ element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
        replace(first: element, with: newElements)
        remove(element)
    }
}

internal extension RangeReplaceableCollection where Element: Equatable  {
    /**
     Inserts a new element before the specified element.
     
     The new element is inserted before the specified element. If the element doesn't exist in the array, the new element won't be inserted.

     - Parameters newElement: The new element to insert into the array.
     - Parameters before: The element before which to insert the new element.
     */
    mutating func insert(_ newElement: Element, before: Element) {
        guard let index = self.firstIndex(of: before) else { return }
        self.insert(newElement, at: index)
    }
    
    /**
     Inserts a new element after the specified element.
     
     The new element is inserted after the specified element. If the element doesn't exist in the array, the new element won't be inserted.

     - Parameters newElement: The new element to insert into the array.
     - Parameters after: The element after which to insert the new element.
     */
    mutating func insert(_ newElement: Element, after: Element) {
        guard let index = self.firstIndex(of: after) else { return }
        self.insert(newElement, at: self.index(after: index))
    }
    
    /**
     Inserts the new elements before the specified element.
     
     The new elements are inserted before the specified element. If the element doesn't exist in the array, the new elements won't be inserted.

     - Parameters newElements: The new elements to insert into the array.
     - Parameters before: The element before which to insert the new elements.
     */
    mutating func insert<C>(_ newElements: C, before: Element) where C: Collection<Element> {
        guard let index = self.firstIndex(of: before) else { return }
        self.insert(contentsOf: newElements, at: index)
    }
    
    /**
     Inserts the new elements after the specified element.
     
     The new elements are inserted after the specified element. If the element doesn't exist in the array, the new elements won't be inserted.

     - Parameters newElements: The new elements to insert into the array.
     - Parameters after: The element after which to insert the new elements.
     */
    mutating func insert<C>(_ newElements: C, after: Element) where C: Collection<Element> {
        guard let index = self.firstIndex(of: after) else { return }
        self.insert(contentsOf: newElements, at: self.index(after: index))
    }
}

internal extension Collection where Element: BinaryInteger {
    /// The average value of all values in the collection. If the collection is empty, it returns 0.
    func average() -> Double {
        guard !isEmpty else { return .zero }
        return Double(reduce(.zero, +)) / Double(count)
    }

    /// The total sum value of all values in the collection. If the collection is empty, it returns 0.
    func sum() -> Self.Element {
        reduce(0, +)
    }
}

internal extension Collection where Element: FloatingPoint {
    /// The average value of all values in the collection. If the collection is empty, it returns 0.
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }

    /// The total sum value of all values in the collection. If the collection is empty, it returns 0.
    func sum() -> Self.Element {
        reduce(0, +)
    }
}

internal extension RangeReplaceableCollection {
    /**
     Returns the collection rotated by the specified amount of positions.
          
     - Parameter positions: The amount of positions to rotate. A value larger than 0 rotates the collection to the right, a value smaller than 0 left.
     - Returns: The rotated collection.
     */
    func rotated(positions: Int) -> Self {
        guard positions != 0 else { return self }
        let index: Index
        let positions = -positions
        if positions > 0 {
            index = self.index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
        } else {
            index = self.index(startIndex, offsetBy: -positions, limitedBy: endIndex) ?? endIndex
        }
        return Self(self[index...] + self[..<index])
    }
    
    /**
     Rotates the collection by the specified amount of positions.
          
     - Parameter positions: The amount of positions to rotate. A value larger than 0 rotates the collection to the right, a value smaller than 0 left.
     */
    mutating func rotate(positions: Int)  {
        guard positions != 0 else { return }
        let positions = -positions
        if positions > 0 {
           let index = self.index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
            removeSubrange(index...)
            insert(contentsOf: self[index...], at: startIndex)
        } else {
           let index = self.index(startIndex, offsetBy: -positions, limitedBy: endIndex) ?? endIndex
            removeSubrange(..<index)
            insert(contentsOf: self[..<index], at: endIndex)
        }
    }
}

