//
//  ContentTransform.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

import Foundation

/// A  protocol for a transformer that generates a modified output from an input.
public protocol ContentTransform: Hashable, Identifiable {
    /// The content type.
    associatedtype Content
    /// The block that transform the content.
    var transform: (Content) -> Content { get }
    /// The identifier of the transformer.
    var id: String { get }
    /**
     Initalizes the transformer with the specified identifier and transform block.
     
     - Parameters:
     - id: The identifier of the transformer.
     - transform: The block that transform a content.
     
     - Returns: The content transformer..
     */
    init(_ id: String, _ transform: @escaping ((Content) -> Content))
}

public extension ContentTransform {
    /**
     Initalizes the transformer with the specified transform block.
     - Parameters transform: The block that transform a content.
     - Returns: The content transformer..
     */
    init(_ transform: @escaping ((Content) -> Content)) {
        self.init(UUID().uuidString, transform)
    }
    
    /**
     Initalizes the transformer with the specified transformers.
     
     The transformer that transforms with multiple transformers by applying them one after the other.
     - Parameters transformers: An array of transformers.
     - Returns: The content transformer..
     */
    init(_ transformers: [Self]) {
        let id = transformers.compactMap({$0.id}).joined(separator: ", ")
        self.init(id) { content in
            var content = content
            for transformer in transformers {
                content = transformer.transform(content)
            }
            return content
        }
    }
    
    /**
     Initalizes the transformer with the specified transformers.
     
     The transformer that transforms with multiple transformers by applying them one after the other.
     - Parameters transformers: An array of transformers.
     - Returns: The content transformer..
     */
    init(_ transformers: Self...) {
        self.init(transformers)
    }
    
    /// Performs the transformation on a single input.
    func callAsFunction(_ input: Content) -> Content {
        return transform(input)
    }

    /// Performs the transformation on a sequence of inputs.
    func callAsFunction<S>(_ inputs: S) -> [Content] where S: Sequence<Content> {
        var results: [Content] = []
        for input in inputs {
            let result = self(input)
            results.append(result)
        }
        return results
    }

    /// Performs the transformation asynchronous on a single input and returns it output to the completion handler.
    func callAsFunction(_ input: Content, completionHandler: @escaping ((Content) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.transform(input)
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }

    /// Performs the transformation asynchronous on a sequence of inputs and returns it output to the completion handler.
    func callAsFunction<S>(_ inputs: S, completionHandler: @escaping (([Content]) -> Void)) where S: Sequence<Content> {
        DispatchQueue.global(qos: .userInitiated).async {
            for input in inputs {
                self(input) { _ in
                }
            }
            let results = self(inputs)
            DispatchQueue.main.async {
                completionHandler(results)
            }
        }
    }

    /// Performs the transformation asynchronous on a single input.
    func callAsFunction(_ input: Content) async -> Content {
        return await withCheckedContinuation { continuation in
            self(input) { result in
                continuation.resume(returning: result)
            }
        }
    }

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        return Self { input in
            var result = lhs(input)
            result = rhs(result)
            return result
        }
    }
}

public extension ContentTransform where Self: AnyObject {
    var id: String { return ObjectIdentifier(self).debugDescription }
}
