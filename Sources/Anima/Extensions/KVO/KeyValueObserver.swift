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
internal class KeyValueObserver<Object>: NSObject where Object: NSObject {
    internal var observers: [String:  (_ oldValue: Any, _ newValue: Any)->()] = [:]
    /// The object to register for KVO notifications.
    public fileprivate(set) weak var observedObject: Object?
    
    /**
    Creates a key-value observer with the specifed observed object.
     - Parameters observedObject: The object to register for KVO notifications.
     - Returns: The  key-value observer.
     */
    public init(_ observedObject: Object) {
        self.observedObject = observedObject
        super.init()
    }
    
    /**
     Adds an observer for the specified keypath which calls the specified handler.
     
     - Parameters keyPath: The keypath to the value to observe.
     - Parameters sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
     - Parameters handler: The handler to be called whenever the keypath value changes.
     */
    public func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        self.add(name, sendInitalValue: sendInitalValue) { old, new in
            guard let old = old as? Value, let new = new as? Value, old != new else { return }
            handler(old, new)
        }
    }
    
    /**
     Adds an observer for the specified keypath which calls the specified handler.
     
     - Parameters keyPath: The keypath to the value to observe.
     - Parameters sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
     - Parameters handler: The handler to be called whenever the keypath value changes.
     */
    public func add<Value>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        
        self.add(name, sendInitalValue: sendInitalValue) { old, new in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(old, new)
        }
    }
    
    /**
     Adds an observer for the specified keypath which calls the specified handler.
     
     - Parameters keyPath: The keypath to the value to observe.
     - Parameters sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
     - Parameters handler: The handler to be called whenever the keypath value changes.
     */
    public func add(_ keypath: String, sendInitalValue: Bool = false, handler: @escaping ( _ oldValue: Any, _ newValue: Any)->()) {
        if (observers[keypath] == nil) {
            observers[keypath] = handler
            let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
            observedObject?.addObserver(self, forKeyPath: keypath, options: options, context: nil)
        } else {
            observers[keypath] = handler
        }
    }
    
    /**
     Adds observers for the specified keypaths which calls the specified handler whenever any of the keypaths properties changes.
     
     - Parameters keyPaths: The keypaths to the values to observe.
     - Parameters handler: The handler to be called whenever any of keypaths values changes.
     */
    public func add(_ keyPaths: [PartialKeyPath<Object>], handler: @escaping ((_ keyPath: PartialKeyPath<Object>)->())) {
        for keyPath in keyPaths {
            if let name = keyPath._kvcKeyPathString {
                self.add(name) { old, new in
                    if let old = old as? any Equatable, let new = new as? any Equatable {
                        if old.isEqual(new) == false {
                            handler(keyPath)
                        }
                    } else {
                        handler(keyPath)
                    }
                }
            }
        }
    }
    
    /**
     Removes the observer for the specified keypath.
     
     - Parameters keyPath: The keypath to remove.
     */
    public func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let name = keyPath._kvcKeyPathString else { return }
        self.remove(name)
    }
    
    /**
     Removes the observesr for the specified keypaths.
     
     - Parameters keyPaths: The keypaths to remove.
     */
    public func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S)  {
        keyPaths.compactMap({$0._kvcKeyPathString}).forEach({ self.remove($0) })
    }
    
    /**
     Removes the observer for the specified keypath.
     
     - Parameters keyPath: The keypath to remove.
     */
    public func remove(_ keyPath: String) {
        guard let observedObject = self.observedObject else { return }
        if self.observers[keyPath] != nil {
            observedObject.removeObserver(self, forKeyPath: keyPath)
            self.observers[keyPath] = nil
        }
    }
    
    /// Removes all observers.
    public func removeAll() {
        self.observers.keys.forEach({ self.remove( $0) })
    }
    
    /// A bool indicating whether any value is observed.
    public func isObserving() -> Bool {
        return  self.observers.isEmpty != false
    }
    
    /**
     A bool indicating whether the value at the specified keypath is observed.
     
     - Parameters keyPath: The keyPath to the value.
     */
    public func isObserving(_ keyPath: PartialKeyPath<Object>) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        return self.isObserving(name)
    }
    
    /**
     A bool indicating whether the value at the specified keypath is observed.
     
     - Parameters keyPath: The keyPath to the value.
     */
    public func isObserving(_ keyPath: String) -> Bool {
        return self.observers[keyPath] != nil
    }
    
    override public func observeValue(forKeyPath keyPath:String?, of object:Any?, change:[NSKeyValueChangeKey:Any]?, context:UnsafeMutableRawPointer?) {
        guard
            self.observedObject != nil,
            let keyPath = keyPath,
            let handler = self.observers[keyPath],
            let change = change,
            let oldValue = change[NSKeyValueChangeKey.oldKey],
            let newValue = change[NSKeyValueChangeKey.newKey] else {
           // super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        handler(oldValue, newValue)
    }
    
    deinit {
        self.removeAll()
    }
}

internal extension KeyValueObserver {
    subscript<Value: Equatable>(keyPath: KeyPath<Object, Value>) -> ((_ oldValue: Value, _ newValue: Value)->())? {
        get {
            guard let name = keyPath._kvcKeyPathString else { return nil }
            return self.observers[name] as ((_ oldValue: Value, _ newValue: Value)->())?
        }
        set {
            if let newValue = newValue {
                guard keyPath._kvcKeyPathString != nil else { return }
                self.add(keyPath, handler: newValue)
            } else {
                self.remove(keyPath)
            }
        }
        
    }
    
    subscript<Value>(keyPath: KeyPath<Object, Value>) -> ((_ oldValue: Value, _ newValue: Value)->())? {
        get {
            guard let name = keyPath._kvcKeyPathString else { return nil }
            return self.observers[name] as ((_ oldValue: Value, _ newValue: Value)->())?
        }
        set {
            if let newValue = newValue {
                guard keyPath._kvcKeyPathString != nil else { return }
                self.add(keyPath, handler: newValue)
            } else {
                self.remove(keyPath)
            }
        }
    }
    
    subscript(keyPath: String) -> ((_ oldValue: Any, _ newValue: Any)->())? {
        get { self.observers[keyPath] }
        set {
            self.remove(keyPath)
            if let newValue = newValue {
                self.add(keyPath, handler: newValue)
            } else {
                self.remove(keyPath)
            }
        }
    }
}
