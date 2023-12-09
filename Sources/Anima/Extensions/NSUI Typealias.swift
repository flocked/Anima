//
//  NSUI Typealias.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import SwiftUI

#if os(macOS)
import AppKit
public typealias NSUIColor = NSColor
public typealias NSUIView = NSView
typealias NSUIBezierPath = NSBezierPath
typealias NSUIScrollView = NSScrollView
typealias NSUIScreen = NSScreen
typealias NSUITextField = NSTextField
typealias NSUITextView = NSTextView
#elseif canImport(UIKit)
import UIKit
public typealias NSUIColor = UIColor
public typealias NSUIView = UIView
typealias NSUIBezierPath = UIBezierPath
typealias NSUIScrollView = UIScrollView
typealias NSUIScreen = UIScreen
typealias NSUITextField = UITextField
typealias NSUITextView = UITextView
#endif
