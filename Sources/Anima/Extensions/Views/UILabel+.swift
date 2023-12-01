//
//  UILabel+.swift
//
//
//  Created by Florian Zand on 17.08.23.
//

#if os(iOS) || os(tvOS)
import UIKit

internal extension UILabel {
    /// The font size of the label.
    @objc var fontSize: CGFloat {
        get { font.pointSize }
        set { font = font?.withSize(newValue) }
    }
}
#endif
