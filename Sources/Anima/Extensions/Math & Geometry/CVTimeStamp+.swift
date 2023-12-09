//
//  CVTimeStamp+.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import CoreVideo
import Foundation

extension CVTimeStamp {
    /// The time interval represented by the time stamp.
    var timeInterval: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }
}
