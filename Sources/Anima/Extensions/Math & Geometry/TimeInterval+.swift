//
//  TimeInterval+.swift
//
//
//  Created by Florian Zand on 26.08.22.
//

import Foundation
import QuartzCore

internal extension TimeInterval {
    /// The current time interval in seconds.
    static var now: TimeInterval {
        return CACurrentMediaTime()
    }
}
