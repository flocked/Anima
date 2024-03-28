//
//  DisplayLink+Combine.swift
//
//  Copyright (c) 2019, Tim Donnelly
//  https://github.com/timdonnelly/DisplayLink
//

import Combine
import Foundation
import CoreVideo

extension CVTimeStamp {
    var duration: TimeInterval {
        TimeInterval(videoTime) / TimeInterval(videoRefreshPeriod)
    }
}
    
private protocol DisplayLinkProvider: AnyObject {
    var isPaused: Bool { get set }
    var onFrame: ((DisplayLink.Frame) -> Void)? { get set }
}

// A publisher that emits new values when the system is about to update the display.
final class DisplayLink: Publisher {
    public typealias Output = Frame
    public typealias Failure = Never

    fileprivate let platformDisplayLink: DisplayLinkProvider

    private var subscribers: [CombineIdentifier: AnySubscriber<Frame, Never>] = [:] {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            platformDisplayLink.isPaused = subscribers.isEmpty
        }
    }

    fileprivate init(platformDisplayLink: DisplayLinkProvider) {
        dispatchPrecondition(condition: .onQueue(.main))
        self.platformDisplayLink = platformDisplayLink
        self.platformDisplayLink.onFrame = { [weak self] frame in
            self?.send(frame: frame)
        }
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Frame {
        dispatchPrecondition(condition: .onQueue(.main))

        let typeErased = AnySubscriber(subscriber)
        let identifier = typeErased.combineIdentifier
        let subscription = Subscription(onCancel: { [weak self] in
            self?.cancelSubscription(for: identifier)
        })
        subscribers[identifier] = typeErased
        subscriber.receive(subscription: subscription)
    }

    private func cancelSubscription(for identifier: CombineIdentifier) {
        dispatchPrecondition(condition: .onQueue(.main))
        subscribers.removeValue(forKey: identifier)
    }

    private func send(frame: Frame) {
        dispatchPrecondition(condition: .onQueue(.main))
        let subscribers = subscribers.values
        subscribers.forEach {
            _ = $0.receive(frame) // Ignore demand
        }
    }
}

extension DisplayLink {
    // Represents a frame that is about to be drawn
    struct Frame {
        // The system timestamp for the frame to be drawn
        public var timestamp: TimeInterval

        // The duration between each display update
        public var duration: TimeInterval
    }
}

extension DisplayLink {
    @available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
    convenience init() {
        self.init(platformDisplayLink: PlatformDisplayLink())
    }
}

#if os(macOS)
    @available(macOS 14.0, *)
    extension DisplayLink {
        /// Creates a display link for the specified view. It will automatically track the display the view is on, and will be automatically suspended if it isn’t on a display.
        convenience init(view: NSView) {
            self.init(platformDisplayLink: PlatformDisplayLinkMac(view: view))
        }

        /// Creates a display link for the specified window. It will automatically track the display the window is on, and will be automatically suspended if it isn’t on a display.
        convenience init(window: NSWindow) {
            self.init(platformDisplayLink: PlatformDisplayLinkMac(window: window))
        }

        /// Creates a display link for the specified screen.
        convenience init(screen: NSScreen) {
            self.init(platformDisplayLink: PlatformDisplayLinkMac(screen: screen))
        }

        /// Creates a display link for the main screen, optionally with the specified preferred frame rate range. Returns `nil` if there isn't a main screen.
        convenience init(preferredFrameRateRange: CAFrameRateRange? = nil) {
            if let preferredFrameRateRange = preferredFrameRateRange, let platformDisplayLink = PlatformDisplayLinkMac(preferredFrameRateRange: preferredFrameRateRange) {
                self.init(platformDisplayLink: platformDisplayLink)
            } else {
                self.init(platformDisplayLink: PlatformDisplayLink())
            }
        }
    }
#endif

extension DisplayLink {
    static let shared = DisplayLink()
}

extension DisplayLink {
    final class Subscription: Combine.Subscription {
        var onCancel: () -> Void

        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }

        func request(_: Subscribers.Demand) {
            // Do nothing – subscribers can't impact how often the system draws frames.
        }

        func cancel() {
            onCancel()
        }
    }
}

#if os(iOS) || os(tvOS)
    import QuartzCore
    import UIKit

    extension DisplayLink {
        /// Creates a display link, optionally with the specified preferred frame rate range.
        @available(iOS 15.0, tvOS 15.0, *)
        convenience init(preferredFrameRateRange: CAFrameRateRange? = nil) {
            self.init(platformDisplayLink: PlatformDisplayLink(preferredFrameRateRange: preferredFrameRateRange))
        }
    }

    fileprivate extension DisplayLink {
        final class PlatformDisplayLink: DisplayLinkProvider {
            /// The callback to call for each frame.
            var onFrame: ((Frame) -> Void)?

            /// If the display link is paused or not.
            var isPaused: Bool {
                get { displayLink.isPaused }
                set { displayLink.isPaused = newValue }
            }

            /// The CADisplayLink that powers this DisplayLink instance.
            let displayLink: CADisplayLink

            /// The target for the CADisplayLink (because CADisplayLink retains its target).
            let target = DisplayLinkTarget()

            /// The framesPerSecond of the displaylink.
            var framesPerSecond: CGFloat {
                1 / (displayLink.targetTimestamp - displayLink.timestamp)
            }

            /// The preferred framerate range.
            @available(iOS 15.0, tvOS 15.0, *)
            var preferredFrameRateRange: CAFrameRateRange {
                get { displayLink.preferredFrameRateRange }
                set { displayLink.preferredFrameRateRange = newValue }
            }

            @available(iOS 15.0, tvOS 15.0, *)
            convenience init(preferredFrameRateRange: CAFrameRateRange? = nil) {
                self.init()
                if let preferredFrameRateRange = preferredFrameRateRange {
                    self.preferredFrameRateRange = preferredFrameRateRange
                }
            }

            /// Creates a new paused DisplayLink instance.
            init() {
                displayLink = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))

                if #available(iOS 15.0, tvOS 15.0, *) {
                    let maximumFramesPerSecond = Float(UIScreen.main.maximumFramesPerSecond)
                    let highFPSEnabled = maximumFramesPerSecond > 60
                    let minimumFPS: Float = Swift.min(highFPSEnabled ? 80 : 60, maximumFramesPerSecond)
                    displayLink.preferredFrameRateRange = .init(minimum: minimumFPS, maximum: maximumFramesPerSecond, preferred: maximumFramesPerSecond)
                }

                displayLink.isPaused = true
                displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
                target.callback = { [unowned self] frame in
                    onFrame?(frame)
                }
            }

            deinit {
                displayLink.invalidate()
            }

            /// The target for the CADisplayLink (because CADisplayLink retains its target).
            final class DisplayLinkTarget {
                /// The callback to call for each frame.
                var callback: ((DisplayLink.Frame) -> Void)?

                /// Called for each frame from the CADisplayLink.
                @objc dynamic func frame(_ displayLink: CADisplayLink) {
                    let frame = Frame(
                        timestamp: displayLink.timestamp,
                        duration: displayLink.duration
                    )

                    callback?(frame)
                }
            }
        }
    }

#elseif os(macOS)

    import AppKit
    import CoreVideo
    fileprivate extension DisplayLink {
        /// DisplayLink is used to hook into screen refreshes.
        final class PlatformDisplayLink: DisplayLinkProvider {
            /// The callback to call for each frame.
            var onFrame: ((Frame) -> Void)?

            /// If the display link is paused or not.
            var isPaused: Bool = true {
                didSet {
                    guard isPaused != oldValue else { return }
                    if isPaused == true {
                        CVDisplayLinkStop(displayLink)
                    } else {
                        CVDisplayLinkStart(displayLink)
                    }
                }
            }

            /// The CVDisplayLink that powers this DisplayLink instance.
            var displayLink: CVDisplayLink = {
                var dl: CVDisplayLink?
                CVDisplayLinkCreateWithActiveCGDisplays(&dl)
                return dl!
            }()

            /*
             /// The framesPerSecond of the displaylink.
             var framesPerSecond: CGFloat {
                 1 / (displayLink.targetTimestamp - displayLink.timestamp)
             }
             */

            init() {
                CVDisplayLinkSetOutputHandler(displayLink) { [weak self] _, inNow, inOutputTime, _, _ -> CVReturn in
                    
                    /*
                    let duration = Double(inOutputTime.pointee.timeInterval) - Double(inNow.pointee.timeInterval)
                    let duration1 = (inOutputTime.pointee.timeInterval - CACurrentMediaTime()) * 2.0
                    let duration2 = inOutputTime.pointee.duration * 2.0
                     */
                    
                    let frame = Frame(
                        timestamp: inNow.pointee.timeInterval,
                        duration: (Double(inOutputTime.pointee.timeInterval) - Double(inNow.pointee.timeInterval)) / 2.0
                    )

                    DispatchQueue.main.async {
                        self?.handle(frame: frame)
                    }

                    return kCVReturnSuccess
                }
            }

            deinit {
                isPaused = true
            }

            /// Called for each CVDisplayLink frame callback.
            func handle(frame: Frame) {
                guard isPaused == false else { return }
                onFrame?(frame)
            }
        }

        /// DisplayLink is used to hook into screen refreshes.
        @available(macOS 14.0, *)
        final class PlatformDisplayLinkMac: DisplayLinkProvider {
            /// The callback to call for each frame.
            var onFrame: ((Frame) -> Void)?

            /// If the display link is paused or not.
            var isPaused: Bool {
                get {
                    displayLink.isPaused
                }
                set {
                    displayLink.isPaused = newValue
                }
            }

            /// The preferred framerate range.
            var preferredFrameRateRange: CAFrameRateRange {
                get { displayLink.preferredFrameRateRange }
                set { displayLink.preferredFrameRateRange = newValue }
            }

            /// The CADisplayLink that powers this DisplayLink instance.
            let displayLink: CADisplayLink

            /// The target for the CADisplayLink (because CADisplayLink retains its target).
            let target = DisplayLinkTarget()

            /// The framesPerSecond of the displaylink.
            var framesPerSecond: CGFloat {
                1 / (displayLink.targetTimestamp - displayLink.timestamp)
            }

            init(view: NSView) {
                displayLink = view.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
                sharedInit(screen: view.window?.screen)
            }

            init(window: NSWindow) {
                displayLink = window.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
                sharedInit(screen: window.screen)
            }

            init(screen: NSScreen) {
                displayLink = screen.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
                sharedInit(screen: screen)
            }

            /// Creates a new paused DisplayLink instance.
            convenience init?(preferredFrameRateRange: CAFrameRateRange? = nil) {
                guard let mainScreen = NSScreen.main else {
                    return nil
                }
                self.init(screen: mainScreen)
                if let preferredFrameRateRange = preferredFrameRateRange {
                    self.preferredFrameRateRange = preferredFrameRateRange
                }
            }

            func sharedInit(screen: NSScreen?) {
                if let screen = screen {
                    let maximumFramesPerSecond = Float(screen.maximumFramesPerSecond)
                    let highFPSEnabled = maximumFramesPerSecond > 60
                    let minimumFPS: Float = Swift.min(highFPSEnabled ? 80 : 60, maximumFramesPerSecond)
                    displayLink.preferredFrameRateRange = .init(minimum: minimumFPS, maximum: maximumFramesPerSecond, preferred: maximumFramesPerSecond)
                }
                displayLink.isPaused = true
                displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)

                target.callback = { [unowned self] frame in
                    onFrame?(frame)
                }
            }

            deinit {
                displayLink.invalidate()
            }

            /// The target for the CADisplayLink (because CADisplayLink retains its target).
            final class DisplayLinkTarget {
                /// The callback to call for each frame.
                var callback: ((DisplayLink.Frame) -> Void)?

                /// Called for each frame from the CADisplayLink.
                @objc dynamic func frame(_ displayLink: CADisplayLink) {
                    let frame = Frame(
                        timestamp: displayLink.timestamp,
                        duration: displayLink.duration
                    )

                    callback?(frame)
                }
            }
        }
    }
#endif
