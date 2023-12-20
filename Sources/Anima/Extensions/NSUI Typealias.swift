//
//  NSUI Typealias.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import SwiftUI

#if os(macOS)
import AppKit
/// NSView
public typealias NSUIView = NSView
typealias NSUIColor = NSColor
typealias NSUIBezierPath = NSBezierPath
typealias NSUIScrollView = NSScrollView
typealias NSUIScreen = NSScreen
typealias NSUITextField = NSTextField
typealias NSUITextView = NSTextView
#elseif canImport(UIKit)
import UIKit
/// UIView
public typealias NSUIView = UIView
typealias NSUIColor = UIColor
typealias NSUIBezierPath = UIBezierPath
typealias NSUIScrollView = UIScrollView
typealias NSUIScreen = UIScreen
typealias NSUITextField = UITextField
typealias NSUITextView = UITextView
#endif
