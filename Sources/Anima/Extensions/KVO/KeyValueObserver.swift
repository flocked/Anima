//
//  KeyValueObserver.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

/**
 Observes multiple properties of an object.
 
 When the instances are deallocated, the KVO is automatically unregistered.
 */
class KeyValueObserver<Object>: NSObject where Object: NSObject {
    var observers: [String: (_ oldValue: Any, _ newValue: Any) -> Void] = [:]
    /// The object to register for KVO notifications.
    public fileprivate(set) weak var observedObject: Object?

    /**
    Creates a key-value observer with the specifed observed object.
     - Parameter observedObject: The object to register for KVO notifications.
     - Returns: The  key-value observer.
     */
    public init(_ observedObject: Object) {
        self.observedObject = observedObject
        super.init()
    }

    /**
     Adds an observer for the specified keypath which calls the specified handler.
     
     - Parameter keyPath: The keypath to the value to observe.
     - Parameter sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
     - Parameter handler: The handler to be called whenever the keypath value changes.
     */
    public func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping (( _ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let name = keyPath._kvcKeyPathString else { return }
        add(name, sendInitalValue: sendInitalValue) { old, new in
            guard let old = old as? Value, let new = new as? Value, old != new else { return }
            handler(old, new)
        }
    }

    /**
     Adds an observer for the specified keypath which calls the specified handler.
     
     - Parameter keyPath: The keypath to the value to observe.
     - Parameter sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
     - Parameter handler: The handler to be called whenever the keypath value changes.
     */
    public func add<Value>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping (( _ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let name = keyPath._kvcKeyPathString else { return }

        add(name, sendInitalValue: sendInitalValue) { old, new in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(old, new)
        }
    }

    /**
     Adds an observer for the specified keypath which calls the specified handler.
     
     - Parameter keyPath: The keypath to the value to observe.
     - Parameter sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
     - Parameter handler: The handler to be called whenever the keypath value changes.
     */
    public func add(_ keypath: String, sendInitalValue: Bool = false, handler: @escaping ( _ oldValue: Any, _ newValue: Any) -> Void) {
        if observers[keypath] == nil {
            observers[keypath] = handler
            let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
            observedObject?.addObserver(self, forKeyPath: keypath, options: options, context: nil)
        } else {
            observers[keypath] = handler
        }
    }

    /**
     Removes the observer for the specified keypath.
     
     - Parameter keyPath: The keypath to remove.
     */
    public func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let name = keyPath._kvcKeyPathString else { return }
        remove(name)
    }

    /**
     Removes the observesr for the specified keypaths.
     
     - Parameter keyPaths: The keypaths to remove.
     */
    public func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S) {
        keyPaths.compactMap({$0._kvcKeyPathString}).forEach({ remove($0) })
    }

    /**
     Removes the observer for the specified keypath.
     
     - Parameter keyPath: The keypath to remove.
     */
    public func remove(_ keyPath: String) {
        guard let observedObject = observedObject else { return }
        if observers[keyPath] != nil {
            observedObject.removeObserver(self, forKeyPath: keyPath)
            observers[keyPath] = nil
        }
    }

    /// Removes all observers.
    public func removeAll() {
        observers.keys.forEach({ remove( $0) })
    }

    /// A bool indicating whether any value is observed.
    public func isObserving() -> Bool {
        return  observers.isEmpty != false
    }

    /**
     A bool indicating whether the value at the specified keypath is observed.
     
     - Parameter keyPath: The keyPath to the value.
     */
    public func isObserving(_ keyPath: PartialKeyPath<Object>) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        return isObserving(name)
    }

    /**
     A bool indicating whether the value at the specified keypath is observed.
     
     - Parameter keyPath: The keyPath to the value.
     */
    public func isObserving(_ keyPath: String) -> Bool {
        return observers[keyPath] != nil
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard
            observedObject != nil,
            let keyPath = keyPath,
            let handler = observers[keyPath],
            let change = change,
            let oldValue = change[NSKeyValueChangeKey.oldKey],
            let newValue = change[NSKeyValueChangeKey.newKey] else {
           // super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        handler(oldValue, newValue)
    }

    deinit {
        removeAll()
    }
}

extension KeyValueObserver {
    subscript<Value: Equatable>(keyPath: KeyPath<Object, Value>) -> ((_ oldValue: Value, _ newValue: Value) -> Void)? {
        get {
            guard let name = keyPath._kvcKeyPathString else { return nil }
            return observers[name] as ((_ oldValue: Value, _ newValue: Value) -> Void)?
        }
        set {
            if let newValue = newValue {
                guard keyPath._kvcKeyPathString != nil else { return }
                add(keyPath, handler: newValue)
            } else {
                remove(keyPath)
            }
        }

    }

    subscript<Value>(keyPath: KeyPath<Object, Value>) -> ((_ oldValue: Value, _ newValue: Value) -> Void)? {
        get {
            guard let name = keyPath._kvcKeyPathString else { return nil }
            return observers[name] as ((_ oldValue: Value, _ newValue: Value) -> Void)?
        }
        set {
            if let newValue = newValue {
                guard keyPath._kvcKeyPathString != nil else { return }
                add(keyPath, handler: newValue)
            } else {
                remove(keyPath)
            }
        }
    }

    subscript(keyPath: String) -> ((_ oldValue: Any, _ newValue: Any) -> Void)? {
        get { observers[keyPath] }
        set {
            remove(keyPath)
            if let newValue = newValue {
                add(keyPath, handler: newValue)
            } else {
                remove(keyPath)
            }
        }
    }
}
