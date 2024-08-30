//
//  NSUITextField+.swift
//
//
//  Created by Florian Zand on 08.11.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension NSUITextField {
    /// The font size of the text filed.
    @objc var fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) }
    }
}

extension NSUITextView {
    /// The font size of the text view.
    @objc var fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) }
    }
}

#if os(iOS) || os(tvOS)
    extension UILabel {
        /// The font size of the label.
        @objc var fontSize: CGFloat {
            get { font.pointSize }
            set { font = font?.withSize(newValue) }
        }
    }
#endif
