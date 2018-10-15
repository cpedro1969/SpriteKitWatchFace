//
//  ViewController.swift
//  SpriteKitWatchFace
//
//  Created by Guillermo Cique Fernández on 14/10/2018.
//  Copyright © 2018 Guillermo Cique Fernández. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    @IBOutlet var watchView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var skView: SKView!
    let scene: FaceScene = FaceScene(fileNamed: "FaceScene")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.watchView.layer.borderColor = UIColor(white: 28/255.0, alpha: 1).cgColor
        self.watchView.layer.borderWidth = 9
        self.watchView.layer.cornerRadius = 60
        self.containerView.layer.cornerRadius = 36
        self.containerView.layer.masksToBounds = true
        
        skView.presentScene(scene)
    }
    
    var currentTheme: Int = 0
    @IBAction func changeThemeAction(_ sender: Any) {
//        currentTheme += 1
        currentTheme -= 1
        if currentTheme < 0 {
            currentTheme = ColorTheme.allThemes.count - 1
        }
        scene.colorTheme = ColorTheme.allThemes[currentTheme % ColorTheme.allThemes.count]
    }
    
}

