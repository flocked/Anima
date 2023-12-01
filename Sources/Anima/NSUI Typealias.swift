//
//  NSUI Typealias.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import SwiftUI

#if os(macOS)
import AppKit
public typealias NSUICollectionView = NSCollectionView
public typealias NSUIColor = NSColor
public typealias NSUIEdgeInsets = NSEdgeInsets
public typealias NSUIFont = NSFont
public typealias NSUIStoryboard = NSStoryboard
public typealias NSUIView = NSView
public typealias NSUITextField = NSTextField
public typealias NSUIStackView = NSStackView
public typealias NSUIControl = NSControl
public typealias NSUIImageView = NSImageView
public typealias NSUIScrollView = NSScrollView
public typealias NSUITextView = NSTextView
public typealias NSUIScreen = NSScreen
internal typealias NSUIBezierPath = NSBezierPath
internal typealias NSUIRectCorner = NSRectCorner
#elseif canImport(UIKit)
import UIKit
public typealias NSUIColor = UIColor
public typealias NSUIEdgeInsets = UIEdgeInsets
public typealias NSUICollectionView = UICollectionView
public typealias NSUIView = UIView
public typealias NSUIControl = UIControl
public typealias NSUIImageView = UIImageView
public typealias NSUITextField = UITextField
public typealias NSUIScrollView = UIScrollView
public typealias NSUIStackView = UIStackView
public typealias NSUITextView = UITextView
public typealias NSUIScreen = UIScreen
internal typealias NSUIRectCorner = UIRectCorner
internal typealias NSUIBezierPath = UIBezierPath
#endif
