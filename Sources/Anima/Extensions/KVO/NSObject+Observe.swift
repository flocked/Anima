//
//  NSObject+Observe.swift
//
//  Adopted from:
//  Copyright ©2020 Peter Baumgartner. All rights reserved.
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

extension NSObjectProtocol where Self: NSObject {
    /**
     Observes changes for a property identified by the given key path.

     - Parameters:
        - keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.

     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    func observeChanges<Value>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> NSKeyValueObservation {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
        return observe(keyPath, options: options) { _, change in
            if let newValue = change.newValue, let oldValue = change.oldValue {
                handler(oldValue, newValue)
            }
        }
    }

    /**
     Observes changes for a property identified by the given key path.

     - Parameters:
        - keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.

     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    func observeChanges<Value: Equatable>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> NSKeyValueObservation {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
        return observe(keyPath, options: options) { _, change in
            if let newValue = change.newValue, let oldValue = change.oldValue {
                if uniqueValues == false {
                    handler(oldValue, newValue)
                } else if change.newValue != change.oldValue {
                    handler(oldValue, newValue)
                }
            }
        }
    }
}
