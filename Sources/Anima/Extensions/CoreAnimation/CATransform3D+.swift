//
//  CATransform3D+.swift
//  
//
//  Created by Florian Zand on 07.10.23.
//

#if canImport(QuartzCore)
import Foundation
import QuartzCore
import Decomposed

extension CATransform3D: Equatable {
    public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
        CATransform3DEqualToTransform(lhs, rhs)
    }
}

extension CATransform3D {
    var eulerAnglesDegrees: CGVector3 {
        get {
            let eulerAngles = self.eulerAngles
            return .init(eulerAngles.x.radiansToDegrees, eulerAngles.y.radiansToDegrees, eulerAngles.z.radiansToDegrees)
        }
        set {
            self.eulerAngles = .init(newValue.x.degreesToRadians, newValue.y.degreesToRadians, newValue.z.degreesToRadians)
        }
    }
}
#endif
