//
//  NSUIScrollView+.swift
//
//
//  Created by Florian Zand on 30.08.24.
//

#if os(macOS)
import AppKit

extension NSScrollView {
    var magnificationCentered: CGFloat {
        get { magnification }
        set {
            if let animationCenterPoint = animationCenterPoint {
                setMagnification(newValue, centeredAt: animationCenterPoint)
            } else {
                magnification = newValue
            }
        }
    }

    var animationCenterPoint: CGPoint? {
        get { getAssociatedValue("animationCenterPoint") }
        set { setAssociatedValue(newValue, key: "animationCenterPoint") }
    }
}

#elseif os(iOS) || os(tvOS)
import UIKit

extension UIScrollView {
    var zoomScaleCentered: CGFloat {
        get { zoomScale }
        set {
            if let animationCenterPoint = animationCenterPoint {
                setZoomScale(newValue, centeredAt: animationCenterPoint)
            } else {
                zoomScale = newValue
            }
        }
    }

    var animationCenterPoint: CGPoint? {
        get { getAssociatedValue("animationCenterPoint") }
        set { setAssociatedValue(newValue, key: "animationCenterPoint") }
    }

    func setZoomScale(_ scale: CGFloat, centeredAt point: CGPoint) {
        var scale = CGFloat.minimum(scale, maximumZoomScale)
        scale = CGFloat.maximum(scale, minimumZoomScale)
        var translatedZoomPoint: CGPoint = .zero
        translatedZoomPoint.x = point.x + contentOffset.x
        translatedZoomPoint.y = point.y + contentOffset.y

        let zoomFactor = 1.0 / zoomScale

        translatedZoomPoint.x *= zoomFactor
        translatedZoomPoint.y *= zoomFactor

        var destinationRect: CGRect = .zero
        destinationRect.size.width = frame.width / scale
        destinationRect.size.height = frame.height / scale
        destinationRect.origin.x = translatedZoomPoint.x - destinationRect.width * 0.5
        destinationRect.origin.y = translatedZoomPoint.y - destinationRect.height * 0.5

        zoom(to: destinationRect, animated: false)
    }
}
#endif
