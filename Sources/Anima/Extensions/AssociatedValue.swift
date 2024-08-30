//
//  AssociatedValue.swift
//
//  Parts taken from:
//  github.com/bradhilton/AssociatedValues
//  Created by Skyvive
//  Created by Florian Zand on 23.02.23.
//

import Foundation
import ObjectiveC.runtime

extension NSObjectProtocol where Self: NSObject {
    /**
     Returns the associated value for the specified key.

     - Parameter key: The key of the associated value.
     - Returns: The associated value for the object and key, or `nil` if the value couldn't be found for the key..
     */
    func getAssociatedValue<T>(_ key: String) -> T? {
        return (objc_getAssociatedObject(self, key.address) as? AssociatedValue)?.value as? T
   }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        getAssociatedValue(key) ?? setAndReturn(initialValue(), key: key)
    }
    
    /**
     Sets a associated value for the specified key.

     - Parameters:
        - associatedValue: The value of the associated value.
        - key: The key of the associated value.
     */
    func setAssociatedValue<T>(_ value: T?, key: String) {
        setAssociatedValue(AssociatedValue(value), key: key)
    }
    
    func setAssociatedValue<T: AnyObject>(weak value: T?, key: String) {
        setAssociatedValue(AssociatedValue(weak: value), key: key)
    }
    
    private func setAssociatedValue(_ value: AssociatedValue, key: String) {
        objc_setAssociatedObject(self, key.address, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func setAndReturn<T>(_ initialValue: T, key: String) -> T {
        setAssociatedValue(initialValue, key: key)
        return initialValue
    }
}

func getAssociatedValue<T>(_ key: String, object: AnyObject) -> T? {
    (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.value as? T
}

func getAssociatedValue<T>(_ key: String, object: AnyObject, initialValue: @autoclosure () -> T) -> T {
    getAssociatedValue(key, object: object) ?? setAndReturn(initialValue(), key: key, object: object)
}

private func setAndReturn<T>(_ initialValue: T, key: String, object: AnyObject) -> T {
    setAssociatedValue(initialValue, key: key, object: object)
    return initialValue
}

func setAssociatedValue<T>(_ value: T?, key: String, object: AnyObject) {
    setAssociatedValue(AssociatedValue(value), key: key, object: object)
}

private func setAssociatedValue(_ value: AssociatedValue, key: String, object: AnyObject) {
    objc_setAssociatedObject(object, key.address, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private class AssociatedValue {
    weak var _weakValue: AnyObject?
    var _value: Any?

    var value: Any? {
        _weakValue ?? _value
    }

    init(_ value: Any?) {
        _value = value
    }

    init(weak: AnyObject?) {
        _weakValue = weak
    }
}

private extension String {
    var address: UnsafeRawPointer {
        UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}
