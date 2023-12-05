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
internal typealias NSUIBezierPath = NSBezierPath
internal typealias NSUIScrollView = NSScrollView
internal typealias NSUIScreen = NSScreen
internal typealias NSUITextField = NSTextField
internal typealias NSUITextView = NSTextView
#elseif canImport(UIKit)
import UIKit
public typealias NSUIColor = UIColor
public typealias NSUIView = UIView
internal typealias NSUIBezierPath = UIBezierPath
internal typealias NSUIScrollView = UIScrollView
internal typealias NSUIScreen = UIScreen
internal typealias NSUITextField = UITextField
internal typealias NSUITextView = UITextView
#endif
