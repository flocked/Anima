//
//  KeyPath+.swift
//
//
//  Created by Florian Zand on 13.10.23.
//

import Foundation

extension PartialKeyPath {
    /// The name of the key path.
    public var stringValue: String {
        if let string = _kvcKeyPathString {
            return string
        }
        let me = String(describing: self)
        let rootName = String(describing: Root.self)
        let removingRootName = me.components(separatedBy: rootName)
        var keyPathValue = removingRootName.last ?? ""
        if keyPathValue.first == "." { keyPathValue.removeFirst() }
        keyPathValue = keyPathValue.replacingOccurrences(of: "?", with: "")
        return keyPathValue
    }
    
    /// The `KVO` name of the key path, or `nil` if the property isn't key value observable.
    var kvcStringValue: String? {
        _kvcKeyPathString
    }
}
