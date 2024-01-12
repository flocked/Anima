//
//  WindowController.swift
//  Example
//
//  Created by Florian Zand on 12.01.24.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func keyDown(with event: NSEvent) {
        contentViewController?.keyDown(with: event)
    }

}
