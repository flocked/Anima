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
    typealias Observer = (handler: (_ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void, sendInital: Bool, sendUnique: Bool)
    var observers: [String: Observer] = [:]
    
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
        setupNotificationObservation()
    }

    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only be called if the new value isn't equal to the previous value.
        - handler: The handler to be called whenever the keypath value changes.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        if uniqueValues {
            return add(keyPath, sendInitalValue: sendInitalValue, handler: handler)
        } else {
            guard let name = keyPath._kvcKeyPathString else { return false }
            add(name, sendInitalValue: sendInitalValue) { old, new, _ in
                guard let old = old as? Value, let new = new as? Value else { return }
                handler(old, new)
            }
            return true
        }
    }

    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the keypath value changes to a new value that isn't equal to the previous value. If you want to the handler to get called on all changes, use ``add(_:sendInitalValue:uniqueValues:handler:)`` and set `uniqueValues` to `false`.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        add(name, sendInitalValue: sendInitalValue, uniqueValues: true) { old, new, inital in
            guard let old = old as? Value, let new = new as? Value else { return }
            if inital || old != new {
                handler(old, new)
            }
        }
        return true
    }

    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the keypath value changes.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        add(name, sendInitalValue: sendInitalValue) { old, new, _ in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(old, new)
        }
        return true
    }

    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the keypath value changes.
     */
    open func add(_ keypath: String, sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void) {
        add(keypath, sendInitalValue: sendInitalValue, uniqueValues: false, handler: handler)
    }
    
    open func add<Value>(_ keypath: String, type: Value.Type, sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void) {
        add(keypath, sendInitalValue: sendInitalValue, uniqueValues: false) { old, new, isInitial in
            guard let new = new as? Value else { return }
            if let old = old as? Value {
                handler(old, new)
            } else {
                handler(new, new)
            }
        }
    }
    
    open func add<Value: Equatable>(_ keypath: String, type: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void) {
        add(keypath, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues) { old, new, isInitial in
            guard let new = new as? Value else { return }
            if let old = old as? Value {
                guard !uniqueValues || old != new else { return }
                handler(old, new)
            } else {
                handler(new, new)
            }
        }
    }

    func add(_ keypath: String, sendInitalValue: Bool = false, uniqueValues: Bool = false, handler: @escaping (_ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void) {
        if observers[keypath] == nil || observers[keypath]?.sendInital != sendInitalValue || observers[keypath]?.sendUnique != uniqueValues {
            observers[keypath] = (handler, sendInitalValue, uniqueValues)
            let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
            observedObject?.addObserver(self, forKeyPath: keypath, options: options, context: nil)
        } else {
            observers[keypath] = (handler, sendInitalValue, uniqueValues)
        }
    }

    /**
     Removes the observer for the property at the specified keypath.

     - Parameter keyPath: The keypath to remove.
     */
    open func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let name = keyPath._kvcKeyPathString else { return }
        remove(name)
    }

    /**
     Removes the observer for the specified keypath.

     - Parameter keyPath: The keypath to remove.
     */
    open func remove(_ keyPath: String) {
        guard let observedObject = observedObject else { return }
        if observers[keyPath] != nil {
            observedObject.removeObserver(self, forKeyPath: keyPath)
            observers[keyPath] = nil
        }
    }
    
    /**
     Removes the observed object and stops observing it, while keeping the list of observed properties and handlers for a new object.
     
     When you add a new object to observe via ``replaceObservedObject(_:)``, all previous observed properties and handlers are used.
     
     */
    func removeObservedObject() {
        guard let observedObject = observedObject else { return }
        for observer in observers {
            observedObject.removeObserver(self, forKeyPath: observer.key)
        }
        self.observedObject = nil
    }
    
    /**
     Replaces the observed object.
     
     All previous observed properties and handlers are used.
    */
    func replaceObservedObject(with object: Object) {
        removeObservedObject()
        self.observedObject = object
        for observer in observers {
            let options: NSKeyValueObservingOptions = observer.value.sendInital ? [.old, .new, .initial] : [.old, .new]
            object.addObserver(self, forKeyPath: observer.key, options: options, context: nil)
        }
    }

    /**
     Removes the observer for the properties at the specified keypaths.

     - Parameter keyPaths: The keypaths to remove.
     */
    open func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S) {
        keyPaths.compactMap(\._kvcKeyPathString).forEach { remove($0) }
    }

    /// Removes all observers.
    open func removeAll() {
        observers.keys.forEach { remove($0) }
    }

    /// A Boolean value indicating whether any value is observed.
    open func isObserving() -> Bool {
        observers.isEmpty != false
    }

    /**
     A Boolean value indicating whether the property at the specified keypath is observed.

     - Parameter keyPath: The keypath to the property.
     */
    open func isObserving(_ keyPath: PartialKeyPath<Object>) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        return isObserving(name)
    }

    /**
     A Boolean value indicating whether the value at the specified keypath is observed.

     - Parameter keyPath: The keypath to the property.
     */
    open func isObserving(_ keyPath: String) -> Bool {
        observers[keyPath] != nil
    }

    override open func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        guard
            observedObject != nil,
            let keyPath = keyPath,
            let observer = observers[keyPath],
            let change = change,
            let newValue = change[NSKeyValueChangeKey.newKey]
        else {
            // super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if let oldValue = change[NSKeyValueChangeKey.oldKey] {
            observer.handler(oldValue, newValue, false)
        } else {
            observer.handler(newValue, newValue, true)
        }
    }
    
    func activate() {
        guard let observedObject = observedObject, isActive == false else { return }
        isActive = true
        for observer in observers {
            let options: NSKeyValueObservingOptions = observer.value.sendInital ? [.old, .new, .initial] : [.old, .new]
            observedObject.addObserver(self, forKeyPath: observer.key, options: options, context: nil)
        }
    }
    
    func deactivate() {
        guard let observedObject = observedObject, isActive else { return }
        isActive = false
        for observer in observers {
            observedObject.removeObserver(self, forKeyPath: observer.key)
        }
    }
    
    var tokens: [NotificationToken] = []
    var isActive: Bool = true
    
    func setupNotificationObservation() {
        tokens.append(NotificationCenter.default.observe(Self.activateObservation, object: observedObject, using: { [weak self] notification in
            guard let self = self else { return }
            self.activate()
        }))
        
        tokens.append(NotificationCenter.default.observe(Self.deactivateObservation, object: observedObject, using: { [weak self] notification in
            guard let self = self else { return }
            self.deactivate()
        }))
    }

    deinit {
        removeAll()
    }
}

extension NSObject {
    static let deactivateObservation = NSNotification.Name("com.fzuikit.deactivateObservation")
    static let activateObservation = NSNotification.Name("com.fzuikit.activateObservation")
}

