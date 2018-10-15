//
//  InterfaceController.swift
//  SpriteKitWatchFace WatchKit Extension
//
//  Created by Guillermo Cique Fernández on 14/10/2018.
//  Copyright © 2018 Guillermo Cique Fernández. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, WKCrownDelegate {

    @IBOutlet var scene: WKInterfaceSKScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let scene = FaceScene(fileNamed: "FaceScene")
        let currentDeviceSize = WKInterfaceDevice.current().screenBounds.size
        /* Using the 44mm Apple Watch as the base size, scale down to fit */
        scene?.camera?.xScale = (184.0/currentDeviceSize.width)
        scene?.camera?.yScale = (184.0/currentDeviceSize.width)
        
        self.scene.presentScene(scene)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didAppear() {
        hideTime()
        
        crownSequencer.delegate = self
        crownSequencer.focus()
    }
    
    var currentTheme: Int = 0
    var totalRotation: Double = 0
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        totalRotation += fabs(rotationalDelta)
        let goingUp = rotationalDelta >= 0
        
        if totalRotation > .pi/8 {
            let scene = self.scene.scene as! FaceScene
            
            if goingUp {
                currentTheme += 1
            } else {
                currentTheme -= 1
                if currentTheme < 0 {
                    currentTheme = ColorTheme.allThemes.count - 1
                }
            }
            scene.colorTheme = ColorTheme.allThemes[currentTheme % ColorTheme.allThemes.count]
            
            totalRotation = 0
        }
    }
    
}

extension WKInterfaceController {
    func hideTime() {
        guard let fullScreenViewClass = NSClassFromString("SPFullScreenView"),
            let application = NSClassFromString("UIApplication")?.value(forKey: "sharedApplication") as? NSObject,
            let viewControllers = application.keyWindow?.rootViewController?.viewControllers as? [NSObject],
            let subviews = viewControllers.first?.view?.subviews as? [NSObject] else {
                return
        }
        
        for view in subviews {
            if view.isKind(of: fullScreenViewClass) {
                view.timeLabel?.layer?.perform(NSSelectorFromString("setOpacity:"), with: CGFloat(0))
            }
        }
    }
}

@dynamicMemberLookup
protocol DynamicKeyValue {}
extension DynamicKeyValue {
    subscript(dynamicMember member: String) -> NSObject? {
        return (self as? NSObject)?.value(forKey: member) as? NSObject
    }
}
extension NSObject: DynamicKeyValue {}
