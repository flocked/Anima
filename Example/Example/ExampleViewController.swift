//
//  ExampleViewController.swift
//  Example
//
//  Created by Florian Zand on 21.03.25.
//

import Cocoa
import Anima

class ExampleViewController: NSViewController {

    let animatedView = NSView()
    @IBOutlet weak var frameCheckButton: NSButton!
    @IBOutlet weak var sizeCheckButton: NSButton!
    @IBOutlet weak var backgroundColorCheckButton: NSButton!
    @IBOutlet weak var cornerRadiusCheckButton: NSButton!
    @IBOutlet weak var durationSlider: NSSlider!
    @IBOutlet weak var durationTextField: NSTextField!
    @IBOutlet weak var colorSpacePopUpButton: NSPopUpButton!

    func decayAnimate() {
        Anima.animate(withDecay: .value, options: animationOptions) {
            animate()
        }
    }
    
    func easeAnimate() {
        Anima.animate(withEasing: .easeInEaseOut, duration: durationSlider.doubleValue, options: animationOptions) {
            animate()
        }
    }
    
    func springAnimate() {
        Anima.animate(withSpring: .bouncy(duration: durationSlider.doubleValue), options: animationOptions) {
            animate()
        }
    }
    
    var animationOptions: Anima.AnimationOptions {
        .colorSpace(.init(rawValue: UInt(colorSpacePopUpButton.indexOfSelectedItem)) ?? .srgb)
    }
    
    func stopAnimation(immediately: Bool) {
        Anima.stopAllAnimations(immediately: immediately)
    }
    
    var animationPosition: Int = 0
    var backgroundColors: [NSColor] = [.systemOrange, .systemRed, .controlAccentColor, .green]
    func animate() {
        animationPosition += 1
        if animationPosition == 5 {
            animationPosition = 0
        }

        let backgroundColor = backgroundColors.removeFirst()
        backgroundColors.append(backgroundColor)
        if backgroundColorCheckButton.state == .on {
            animatedView.animator.backgroundColor = backgroundColor
        }

        let frameSize: CGSize
        switch animationPosition {
        case 1, 3:
            frameSize = view.bounds.size * 0.3
        case 2, 4:
            frameSize = view.bounds.size * 0.4
        default:
            frameSize = view.bounds.size * 0.6
        }
        if sizeCheckButton.state == .on && frameCheckButton.state == .on {
            animatedView.animator.frame.size = frameSize
            animateOrigin()
        } else if sizeCheckButton.state == .on {
            animatedView.animator.size = frameSize
        } else if frameCheckButton.state == .on {
            animateOrigin()
        }
        
        if cornerRadiusCheckButton.state == .on {
            animatedView.animator.cornerRadius = CGFloat.random(in: 0.0...animatedView.animator.frame.height*0.5)
        }
    }
    
    func animateOrigin() {
        switch animationPosition {
        case 1:
            animatedView.animator.frame.topLeft = view.frame.topLeft.offset(x: 20, y: -20)
        case 2:
            animatedView.animator.frame.topRight = view.frame.topRight.offset(x: -20, y: -20)
        case 3:
            animatedView.animator.frame.bottomRight = view.frame.bottomRight.offset(x: -20, y: 20)
        case 4:
            animatedView.animator.frame.bottomLeft = view.frame.bottomLeft.offset(x: 20, y: 20)
        default:
            animatedView.animator.frame.center = view.frame.center
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        colorSpacePopUpButton.removeAllItems()
        colorSpacePopUpButton.addItems(withTitles: Anima.ColorSpace.allCases.map(\.description))
        colorSpacePopUpButton.selectItem(withTitle: Anima.ColorSpace.srgb.description)
                
        setupKeyDownMonitor()
        
        animatedView.backgroundColor = .controlAccentColor
        animatedView.cornerRadius = 10
        animatedView.frame.size = view.bounds.size * 0.6
        animatedView.frame.center = view.bounds.center
        view.addSubview(animatedView)
    }
    
    
    @IBAction func durationSliderChanged(_ sender: Any? = nil) {
        durationTextField.stringValue = "\(durationSlider.doubleValue)s"
    }
    
    // Monitors keyDown events
    var keyDownMonitor: Any?
    func setupKeyDownMonitor() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { event in
            switch event.keyCode {
            case 49: self.springAnimate()
            case 18: self.easeAnimate()
            case 19: self.decayAnimate()
            case 01: self.stopAnimation(immediately: true)
            case 02: self.stopAnimation(immediately: false)
            default: return event
            }
            return nil
        })
    }
}

