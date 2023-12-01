//
//  CVTimeStamp+.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import CoreVideo
import Foundation

internal extension CVTimeStamp {
    
    /// The time interval represented by the time stamp.
    var timeInterval: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }
    
    /// The frames per second (FPS).
    var fps: TimeInterval {
        return TimeInterval(videoTimeScale) / TimeInterval(videoRefreshPeriod)
    }
    
    /// The frame duration in seconds.
    var frame: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoRefreshPeriod)
    }
    
    /// The timestamp in seconds.
    var seconds: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }
    
    /// The root timestamp in seconds.
    var rootTotalSeconds: TimeInterval {
        return TimeInterval(hostTime)
    }
    
    /// The root timestamp in days.
    var rootDays: TimeInterval {
        return TimeInterval(hostTime) / (1_000_000_000 * 60 * 60 * 24).truncatingRemainder(dividingBy: 365)
    }
    
    /// The root timestamp in hours.
    var rootHours: TimeInterval {
        return TimeInterval(hostTime) / (1_000_000_000 * 60 * 60).truncatingRemainder(dividingBy: 24)
    }
    
    /// The root timestamp in minutes.
    var rootMinutes: TimeInterval {
        return TimeInterval(hostTime) / (1_000_000_000 * 60).truncatingRemainder(dividingBy: 60)
    }
    
    /// The root timestamp in seconds.
    var rootSeconds: TimeInterval {
        return TimeInterval(hostTime) / 1_000_000_000.truncatingRemainder(dividingBy: 60)
    }
    
    /// The total timestamp in seconds.
    var totalSeconds: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }
    
    /// The timestamp in days.
    var days: TimeInterval {
        return (totalSeconds / (60 * 60 * 24)).truncatingRemainder(dividingBy: 365)
    }
    
    /// The timestamp in hours.
    var hours: TimeInterval {
        return (totalSeconds / (60 * 60)).truncatingRemainder(dividingBy: 24)
    }
    
    /// The timestamp in minutes.
    var minutes: TimeInterval {
        return (totalSeconds / 60).truncatingRemainder(dividingBy: 60)
    }
    
    /*
     var seconds: TimeInterval {
     return totalSeconds.truncatingRemainder(dividingBy: 60)
     }
     */
}
