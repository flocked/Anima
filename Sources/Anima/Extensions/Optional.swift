//
//  Optional.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

/// A protocol represeting an optional value.
protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped
    /// The optional value.
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    /// The optional value.
    var optional: Self { self }
}
