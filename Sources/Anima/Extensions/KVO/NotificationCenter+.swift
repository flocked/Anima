//
//  NotificationCenter+.swift
//  
//
//  Created by Florian Zand on 29.03.24.
//

import Foundation

/**
 A token representing an observer for notifications.

 The notification is observed until you deallocate the token.
 */
class NotificationToken: NSObject {
    /// The `NotificationCenter` instance associated with the observer.
    let notificationCenter: NotificationCenter

    /// The token that identifies the observer.
    let token: Any
    
    /// The name of the observed notification.
    public let name: NSNotification.Name?

    /**
     Initializes a new `NotificationToken` instance with the specified `NotificationCenter` and token.

     - Parameters:
       - notificationCenter: The `NotificationCenter` instance associated with the observer. The default value is `.default`.
       - token: The token that identifies the observer.
     */
    public init(notificationCenter: NotificationCenter = .default, token: Any, name: NSNotification.Name?) {
        self.notificationCenter = notificationCenter
        self.token = token
        self.name = name
    }

    /**
     Removes the observer from the associated `NotificationCenter`.

     This method is automatically called when the `NotificationToken` instance is deallocated.
     */
    deinit {
        notificationCenter.removeObserver(token)
    }
}

extension NotificationCenter {
    /**
     Adds an observer for the specified notification name, object, queue, and block.

     - Parameters:
       - name: The name of the notification to observe. Pass `nil` to receive notifications for all names.
       - object: The object to observe. Pass `nil` to receive notifications from any object.
       - queue: The operation queue on which to execute the block. The default value is `nil` which uses the default queue.
       - block: The block to execute when the notification is received. The block takes a single parameter of type `Notification`.

     - Returns: A `NotificationToken` that represents the observer. You can use this token to remove the observer later.
     */
    func observe(_ name: NSNotification.Name?, object: Any?,
                 queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void)
        -> NotificationToken
    {
        let token = addObserver(forName: name, object: object, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token, name: name)
    }
}
