//
//  FaceScene.swift
//  SpriteKitWatchFace WatchKit Extension
//
//  Created by Guillermo Cique Fernández on 14/10/2018.
//  Copyright © 2018 Guillermo Cique Fernández. All rights reserved.
//

import SpriteKit
import CoreText

#if os(iOS) || os(watchOS)
/* Sigh. */
typealias NSFont = UIFont
typealias NSFontDescriptor = UIFontDescriptor
#endif

extension NSFont {
    var smallCaps: NSFont {
        let settings: [NSFontDescriptor.FeatureKey: Int] = [
            NSFontDescriptor.FeatureKey.featureIdentifier: kUpperCaseType,
            NSFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector
        ]
        let attributes: [NSFontDescriptor.AttributeName : Any] = [
            NSFontDescriptor.AttributeName.featureSettings: settings,
            NSFontDescriptor.AttributeName.name: fontName
        ]
        
        return NSFont(descriptor: NSFontDescriptor(fontAttributes: attributes), size: pointSize)
    }
}

class FaceScene: SKScene, SKSceneDelegate {
    
    static let minus2piOver12: CGFloat = -(2 * .pi)/12.0
    static let minus2piOver60: CGFloat = -(2 * .pi)/60.0
    
    let faceSize: CGSize = CGSize(width: 184, height: 224)
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "ccc d"
        
        return dateFormatter
    }()
    
    var colorTheme: ColorTheme = .chess {
        didSet { refreshTheme() }
    }
    var faceStyle: FaceStyle = .rectangular {
        didSet { refreshTheme() }
    }
    var numeralStyle: NumeralStyle = .all {
        didSet { refreshTheme() }
    }
    var tickmarkStyle: TickmarkStyle = .all {
        didSet { refreshTheme() }
    }
    var majorTickmarkShape: TickmarkShape = .circular {
        didSet { refreshTheme() }
    }
    var minorTickmarkShape: TickmarkShape = .rectangular {
        didSet { refreshTheme() }
    }
    var colorRegionStyle: ColorRegionStyle = .dynamicDuo {
        didSet { refreshTheme() }
    }
    
    var useProgrammaticLayout: Bool = true {
        didSet { refreshTheme() }
    }
    var showDate: Bool = true {
        didSet { refreshTheme() }
    }
    var showCenterDisc: Bool = false {
        didSet { refreshTheme() }
    }
    
    override func sceneDidLoad() {
        self.delegate = self
        refreshTheme()
    }
    
    func refreshTheme() {
        if let markings = childNode(withName: "Markings") {
            markings.removeAllChildren()
            markings.removeFromParent()
        }
        if let markings = childNode(withName: "Markings Alternate") {
            markings.removeAllChildren()
            markings.removeFromParent()
        }
        
        setupScene()
        if useProgrammaticLayout && colorTheme.shouldUseMasking && (colorRegionStyle == .dynamicDuo || colorRegionStyle == .half) {
            setupMasking()
        }
    }
    
    func setupScene() {
        guard let face = childNode(withName: "Face"),
            let hourHand = face.childNode(withName: "Hours") as? SKSpriteNode,
            let minuteHand = face.childNode(withName: "Minutes") as? SKSpriteNode,
            let hourHandInlay = hourHand.childNode(withName: "Hours Inlay") as? SKSpriteNode,
            let minuteHandInlay = minuteHand.childNode(withName: "Minutes Inlay") as? SKSpriteNode,
            let secondHand = face.childNode(withName: "Seconds") as? SKSpriteNode,
            let colorRegion = face.childNode(withName: "Color Region") as? SKSpriteNode,
            let colorRegionReflection = face.childNode(withName: "Color Region Reflection") as? SKSpriteNode,
            let numbers = face.childNode(withName: "Numbers") as? SKSpriteNode,
            let centerDisc = face.childNode(withName: "Center Disc") as? SKSpriteNode else {
                fatalError("Nodes missing from scene")
        }
        
        hourHand.color = colorTheme.handColor
        hourHand.colorBlendFactor = 1
        
        minuteHand.color = colorTheme.handColor
        minuteHand.colorBlendFactor = 1
        
        secondHand.color = colorTheme.secondHandColor
        secondHand.colorBlendFactor = 1
        
        backgroundColor = colorTheme.faceBackgroundColor
        
        colorRegion.color = colorTheme.colorRegionColor
        colorRegion.colorBlendFactor = 1
        
        numbers.color = colorTheme.textColor
        numbers.colorBlendFactor = 1
        
        hourHandInlay.color = colorTheme.inlayColor
        hourHandInlay.colorBlendFactor = 1
        
        minuteHandInlay.color = colorTheme.inlayColor
        minuteHandInlay.colorBlendFactor = 1
        
        let colorRegionScale: CGFloat = 0.9
        switch colorRegionStyle {
        case .none:
            colorRegion.alpha = 0
        case .dynamicDuo:
            colorRegion.alpha = 1
            colorRegion.texture = nil
            colorRegion.anchorPoint = CGPoint(x: 0.5, y: 0)
            colorRegion.size = CGSize(width: 768, height: 768)
            
            colorRegionReflection.texture = nil
        case .half:
            colorRegion.alpha = 1
            colorRegion.texture = nil
            colorRegion.anchorPoint = CGPoint(x: 0.5, y: 0)
            colorRegion.size = CGSize(width: 768, height: 768)
            
            colorRegionReflection.texture = nil
        case .circle:
            colorRegion.texture = SKTexture(imageNamed: "ColorRegionCircle")
            colorRegion.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            colorRegion.position = .zero
            colorRegion.size = CGSize(width: 179*colorRegionScale, height: 179*colorRegionScale)
            
            colorRegionReflection.texture = SKTexture(imageNamed: "ColorRegionCircleReflection")
            colorRegionReflection.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            colorRegionReflection.position = .zero
            colorRegionReflection.size = CGSize(width: 368*colorRegionScale, height: 448*colorRegionScale)
        case .ring:
            colorRegion.texture = SKTexture(imageNamed: "ColorRegionRing")
            colorRegion.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            colorRegion.position = .zero
            colorRegion.size = CGSize(width: 179*colorRegionScale, height: 179*colorRegionScale)
            
            colorRegionReflection.texture = SKTexture(imageNamed: "ColorRegionRingReflection")
            colorRegionReflection.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            colorRegionReflection.position = .zero
            colorRegionReflection.size = CGSize(width: 368*colorRegionScale, height: 448*colorRegionScale)
        }
        
        if useProgrammaticLayout {
            numbers.alpha = 0
            
            if faceStyle == .round {
                setupTickmarksForRoundFace()
            } else {
                setupTickmarksForRectangularFace()
            }
        } else {
            numbers.alpha = 1
        }
        
        if showCenterDisc {
            centerDisc.alpha = 1
        } else {
            centerDisc.alpha = 0
        }
        
        colorRegionReflection.alpha = 0
    }
    
    func setupMasking() {
        guard let face = childNode(withName: "Face"),
            let faceMarkings = childNode(withName: "Markings") as? SKCropNode,
            let colorRegion = face.childNode(withName: "Color Region") as? SKSpriteNode,
            let colorRegionReflection = face.childNode(withName: "Color Region Reflection") as? SKSpriteNode else {
                fatalError("Nodes missing from scene")
        }
        
        faceMarkings.maskNode = colorRegion
        
        if faceStyle == .round {
            setupTickmarksForRoundFace(isAlternateLayer: true)
        } else {
            setupTickmarksForRectangularFace(isAlternateLayer: true)
        }
        
        colorRegionReflection.alpha = 1
        if let markings = childNode(withName: "Markings Alternate") as? SKCropNode {
            markings.maskNode = colorRegionReflection
        }
    }
    
    func setupTickmarksForRoundFace(isAlternateLayer: Bool = false) {
        let faceMarkings = SKCropNode()
        let textColor: SKColor
        let majorMarkColor: SKColor
        let minorMarkColor: SKColor
        
        if isAlternateLayer {
            faceMarkings.name = "Markings Alternate"
            textColor = colorTheme.alternateTextColor!
            majorMarkColor = colorTheme.alternateMajorMarkColor!
            minorMarkColor = colorTheme.alternateMinorMarkColor!
        } else {
            faceMarkings.name = "Markings"
            textColor = colorTheme.textColor
            majorMarkColor = colorTheme.majorMarkColor
            minorMarkColor = colorTheme.minorMarkColor
        }
        
        /* Hardcoded for 44mm Apple Watch */
        
        let margin: CGFloat = 4
        let labelMargin: CGFloat = 26
        
        for i in 0..<12 {
            let angle: CGFloat = FaceScene.minus2piOver12 * CGFloat(i)
            let workingRadius: CGFloat = faceSize.width / 2
            let longTickHeight: CGFloat = workingRadius / 15
            
            if tickmarkStyle == .all || tickmarkStyle == .major {
                let tick = SKSpriteNode(color: majorMarkColor, size: CGSize(width: 2, height: longTickHeight))
                tick.position = .zero
                tick.anchorPoint = CGPoint(x: 0.5, y: (workingRadius - margin) / longTickHeight)
                tick.zRotation = angle
                
                faceMarkings.addChild(tick)
                
                switch majorTickmarkShape {
                case .rectangular:
                    break
                case .circular:
                    tick.color = .clear
                    
                    let shape = SKShapeNode(ellipseOf: CGSize(width: longTickHeight, height: longTickHeight))
                    shape.fillColor = majorMarkColor
                    shape.strokeColor = .clear
                    shape.position = CGPoint(x: 0, y: (workingRadius - margin) - longTickHeight/2)
                    
                    tick.addChild(shape)
                case .triangular:
                    tick.color = .clear
                    
                    let triangleHeight: CGFloat = numeralStyle == .none ? 8 : 3
                    let triangleWidth: CGFloat = 4
                    
                    var points = [CGPoint(x: -(0.5 * triangleWidth), y: triangleHeight),
                                  CGPoint(x: 0, y: -triangleHeight),
                                  CGPoint(x: (0.5 * triangleWidth), y: triangleHeight)
                    ]
                    let shape = SKShapeNode(points: &points, count: points.count)
                    shape.fillColor = majorMarkColor
                    shape.strokeColor = .clear
                    shape.position = CGPoint(x: 0, y: (workingRadius - margin) - triangleHeight)
                    
                    tick.addChild(shape)
                }
            }
            
            if numeralStyle == .all || numeralStyle == .cardinal && i%3 == 0 {
                let fontSize: CGFloat = 25
                
                let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: fontSize, weight: .medium).smallCaps,
                                                                 .foregroundColor: textColor]
                let labelText = NSAttributedString(string: (i == 0 ? 12 : i).description, attributes: attributes)
                let numberLabel = SKLabelNode(attributedText: labelText)
                numberLabel.position = CGPoint(x: (workingRadius-labelMargin) * -sin(angle), y: (workingRadius-labelMargin) * cos(angle) - 9)
                
                faceMarkings.addChild(numberLabel)
            }
        }
        
        if tickmarkStyle == .all || tickmarkStyle == .minor {
            for i in 0..<60 {
                guard i % 5 != 0 else {
                    continue
                }
                
                let angle: CGFloat = FaceScene.minus2piOver60 * CGFloat(i)
                let workingRadius: CGFloat = faceSize.width / 2
                let shortTickHeight: CGFloat = workingRadius / 20
                
                let tick = SKSpriteNode(color: minorMarkColor, size: CGSize(width: 1, height: shortTickHeight))
                tick.position = .zero
                tick.anchorPoint = CGPoint(x: 0.5, y: (workingRadius - margin) / shortTickHeight)
                tick.zRotation = angle
                
                faceMarkings.addChild(tick)
                
                switch minorTickmarkShape {
                case .rectangular:
                    break
                case .circular:
                    tick.color = .clear
                    
                    let shape = SKShapeNode(ellipseOf: CGSize(width: 3, height: 3))
                    shape.fillColor = minorMarkColor
                    shape.strokeColor = .clear
                    shape.position = CGPoint(x: 0, y: (workingRadius - margin) - shortTickHeight/2)
                    
                    tick.addChild(shape)
                case .triangular:
                    tick.color = .clear
                    
                    let triangleHeight: CGFloat = numeralStyle == .none ? 4 : 2
                    let triangleWidth: CGFloat = 2
                    
                    var points = [CGPoint(x: -(0.5 * triangleWidth), y: triangleHeight),
                                  CGPoint(x: 0, y: -triangleHeight),
                                  CGPoint(x: (0.5 * triangleWidth), y: triangleHeight)
                    ]
                    let shape = SKShapeNode(points: &points, count: points.count)
                    shape.fillColor = minorMarkColor
                    shape.strokeColor = .clear
                    shape.position = CGPoint(x: 0, y: (workingRadius - margin) - triangleHeight)
                    
                    tick.addChild(shape)
                }
            }
        }
        
        if showDate {
            let dateLabel = SKLabelNode(text: nil)
            dateLabel.name = "Date"
            if numeralStyle == .none {
                dateLabel.position = CGPoint(x: 42, y: -4)
            } else {
                dateLabel.position = CGPoint(x: 32, y: -4)
            }
            
            faceMarkings.addChild(dateLabel)
        }
        
        addChild(faceMarkings)
    }
    
    func workingRadiusForAngle(_ angle: CGFloat) -> CGFloat {
        let vx: CGFloat = cos(angle)
        let vy: CGFloat = sin(angle)
        
        let x1: CGFloat = 0
        let y1: CGFloat = 0
        let x2: CGFloat = faceSize.height
        let y2: CGFloat = faceSize.width
        let px: CGFloat = faceSize.height / 2
        let py: CGFloat = faceSize.width  / 2
        
        let t = [
            (x1-px)/vx,
            (x2-px)/vx,
            (y1-py)/vy,
            (y2-py)/vy
        ]
        
        let smallestT: CGFloat = t.reduce(1000) { (result, currentT) -> CGFloat in
            if currentT > 0 && currentT < result {
                return currentT
            }
            return result
        }
        
        return smallestT
    }
    
    func setupTickmarksForRectangularFace(isAlternateLayer: Bool = false) {
        let faceMarkings = SKCropNode()
        let textColor: SKColor
        let majorMarkColor: SKColor
        let minorMarkColor: SKColor
        
        if isAlternateLayer {
            faceMarkings.name = "Markings Alternate"
            textColor = colorTheme.alternateTextColor!
            majorMarkColor = colorTheme.alternateMajorMarkColor!
            minorMarkColor = colorTheme.alternateMinorMarkColor!
        } else {
            faceMarkings.name = "Markings"
            textColor = colorTheme.textColor
            majorMarkColor = colorTheme.majorMarkColor
            minorMarkColor = colorTheme.minorMarkColor
        }
        
        /* Hardcoded for 44mm Apple Watch */
        
        let margin: CGFloat = 5
        let labelXMargin: CGFloat = 24
        let labelYMargin: CGFloat = 30
        
        if tickmarkStyle == .all || tickmarkStyle == .major {
            for i in 0..<12 {
                let angle: CGFloat = FaceScene.minus2piOver12 * CGFloat(i)
                let workingRadius: CGFloat = workingRadiusForAngle(angle)
                let longTickHeight: CGFloat = workingRadius / 10
                
                let tick = SKSpriteNode(color: majorMarkColor, size: CGSize(width: 2, height: longTickHeight))
                tick.position = .zero
                tick.anchorPoint = CGPoint(x: 0.5, y: (workingRadius - margin) / longTickHeight)
                tick.zRotation = angle
                tick.zPosition = 0
                
                faceMarkings.addChild(tick)
                
                switch majorTickmarkShape {
                case .rectangular:
                    break
                case .circular:
                    tick.color = .clear
                    
                    let circleDiameter: CGFloat = 6
                    let shape = SKShapeNode(ellipseOf: CGSize(width: circleDiameter, height: circleDiameter))
                    shape.fillColor = majorMarkColor
                    shape.strokeColor = .clear
                    shape.position = CGPoint(x: 0, y: (workingRadius - margin) - circleDiameter/2)
                    
                    tick.addChild(shape)
                case .triangular:
                    tick.color = .clear
                    
                    let triangleHeight: CGFloat = numeralStyle == .none ? 8 : 3
                    let triangleWidth: CGFloat = 4
                    
                    var points = [CGPoint(x: -(0.5 * triangleWidth), y: triangleHeight),
                                  CGPoint(x: 0, y: -triangleHeight),
                                  CGPoint(x: (0.5 * triangleWidth), y: triangleHeight)
                    ]
                    let shape = SKShapeNode(points: &points, count: points.count)
                    shape.fillColor = majorMarkColor
                    shape.strokeColor = .clear
                    shape.position = CGPoint(x: 0, y: (workingRadius - margin) - triangleHeight)
                    
                    tick.addChild(shape)
                }
            }
        }
        
        if tickmarkStyle == .all || tickmarkStyle == .minor {
            for i in 0..<60 {
                guard i % 5 != 0 else {
                    continue
                }
                
                let angle: CGFloat = FaceScene.minus2piOver60 * CGFloat(i)
                var workingRadius: CGFloat = workingRadiusForAngle(angle)
                let shortTickHeight: CGFloat = workingRadius / 20
                
                /* Super hacky hack to inset the tickmarks at the four corners of a curved display instead of doing math */
                if (i == 6 || i == 7  || i == 23 || i == 24 || i == 36 || i == 37 || i == 53 || i == 54) {
                    workingRadius -= 8
                }
                
                let tick = SKSpriteNode(color: minorMarkColor, size: CGSize(width: 1, height: shortTickHeight))
                tick.position = .zero
                tick.anchorPoint = CGPoint(x: 0.5, y: (workingRadius - margin) / shortTickHeight)
                tick.zRotation = angle
                tick.zPosition = 0
                
                faceMarkings.addChild(tick)
                
                switch minorTickmarkShape {
                case .rectangular:
                    break
                case .circular:
                    tick.color = .clear
                    
                    let shape = SKShapeNode(ellipseOf: CGSize(width: 3, height: 3))
                    shape.fillColor = minorMarkColor
                    shape.strokeColor = .clear
                    shape.position = CGPoint(x: 0, y: (workingRadius - margin) - shortTickHeight/2)
                    
                    tick.addChild(shape)
                case .triangular:
                    tick.color = .clear
                    
                    let triangleHeight: CGFloat = numeralStyle == .none ? 4 : 2
                    let triangleWidth: CGFloat = 2
                    
                    var points = [CGPoint(x: -(0.5 * triangleWidth), y: triangleHeight),
                                  CGPoint(x: 0, y: -triangleHeight),
                                  CGPoint(x: (0.5 * triangleWidth), y: triangleHeight)
                    ]
                    let shape = SKShapeNode(points: &points, count: points.count)
                    shape.fillColor = minorMarkColor
                    shape.strokeColor = .clear
                    shape.position = CGPoint(x: 0, y: (workingRadius - margin) - triangleHeight)
                    
                    tick.addChild(shape)
                }
            }
        }
        
        for i in 1...12 {
            guard numeralStyle == .all || numeralStyle == .cardinal && i%3 == 0 else {
                continue
            }
            
            let fontSize: CGFloat = 25
            
            let labelNode = SKSpriteNode(color: .clear, size: CGSize(width: fontSize, height: fontSize))
            labelNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            let faceWidthWithXMarginOver3: CGFloat = (faceSize.width-labelXMargin*2)/3.0
            switch i {
            case 1, 11, 12:
                labelNode.position = CGPoint(x: labelXMargin-faceSize.width/2 + CGFloat((i+1)%3) * faceWidthWithXMarginOver3 + (faceSize.width-labelXMargin*2)/6.0,
                                             y: faceSize.height/2-labelYMargin)
            case 5, 6, 7:
                labelNode.position = CGPoint(x: labelXMargin-faceSize.width/2 + CGFloat(2-((i+1)%3)) * faceWidthWithXMarginOver3 + (faceSize.width-labelXMargin*2)/6.0,
                                             y: -faceSize.height/2+labelYMargin)
            case 2, 3, 4:
                labelNode.position = CGPoint(x: faceSize.height/2-fontSize-labelXMargin,
                                             y: -(faceSize.width-labelXMargin*2)/2 + CGFloat(2-((i+1)%3)) * faceWidthWithXMarginOver3 + (faceSize.width-labelYMargin*2)/6.0)
            case 8, 9, 10:
                labelNode.position = CGPoint(x: -faceSize.height/2+fontSize+labelXMargin,
                                             y: -(faceSize.width-labelXMargin*2)/2 + CGFloat((i+1)%3) * faceWidthWithXMarginOver3 + (faceSize.width-labelYMargin*2)/6.0)
            default:
                break
            }
            
            let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: fontSize, weight: .medium).smallCaps,
                                                             .foregroundColor: textColor]
            let labelText = NSAttributedString(string: i.description, attributes: attributes)
            let numberLabel = SKLabelNode(attributedText: labelText)
            numberLabel.position = CGPoint(x: 0, y: -9)
            
            faceMarkings.addChild(labelNode)
            labelNode.addChild(numberLabel)
        }
        
        if showDate {
            let dateLabel = SKLabelNode(text: nil)
            dateLabel.name = "Date"
            if numeralStyle == .none {
                dateLabel.position = CGPoint(x: 42, y: -4)
            } else {
                dateLabel.position = CGPoint(x: 32, y: -4)
            }
            
            faceMarkings.addChild(dateLabel)
        }
        
        addChild(faceMarkings)
    }
    
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        updateHands()
    }
    
    func updateHands() {
        guard let face = childNode(withName: "Face"),
            let hourHand = face.childNode(withName: "Hours") as? SKSpriteNode,
            let minuteHand = face.childNode(withName: "Minutes") as? SKSpriteNode,
            let secondHand = face.childNode(withName: "Seconds") as? SKSpriteNode,
            let colorRegion = face.childNode(withName: "Color Region") as? SKSpriteNode,
            let colorRegionReflection = face.childNode(withName: "Color Region Reflection") as? SKSpriteNode else {
                fatalError("Nodes missing from scene")
        }
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: now)
        
        let hour: CGFloat = CGFloat(components.hour!).truncatingRemainder(dividingBy: 12)
        let minute: CGFloat = CGFloat(components.minute!)
        let second: CGFloat = CGFloat(components.second!)
        let nanosecond: CGFloat = CGFloat(components.nanosecond!)
        hourHand.zRotation =  FaceScene.minus2piOver12 * (hour + 1.0/60.0*minute)
        minuteHand.zRotation =  FaceScene.minus2piOver60 * (minute + 1.0/60.0*second)
        secondHand.zRotation = FaceScene.minus2piOver60 * (second + 1.0/CGFloat(NSEC_PER_SEC)*nanosecond)
        
        switch colorRegionStyle {
        case .none:
            break
        case .dynamicDuo:
            colorRegion.alpha = 1.0;
            
            colorRegion.zRotation = .pi/2 + minuteHand.zRotation
            colorRegionReflection.zRotation =  colorRegion.zRotation
        case .half:
            colorRegion.alpha = 1.0
            
            colorRegion.zRotation =  0
            colorRegionReflection.zRotation =  0
        case .circle, .ring:
            colorRegion.zRotation =  0
            colorRegionReflection.zRotation =  0
        }
        
        updateDateLabel()
    }
    
    func updateDateLabel() {
        let now = Date()
        let fontSize: CGFloat = 12
        let dateString = dateFormatter.string(from: now).uppercased()
        
        if let markings = childNode(withName: "Markings"),
            let dateLabel = markings.childNode(withName: "Date") as? SKLabelNode {
            let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: fontSize, weight: .medium).smallCaps,
                                                             .foregroundColor: colorTheme.textColor]
            let labelText = NSAttributedString(string: dateString, attributes: attributes)
            dateLabel.attributedText = labelText
        }
        
        if let markings = childNode(withName: "Markings Alternate"),
            let dateLabel = markings.childNode(withName: "Date") as? SKLabelNode,
            let alternateTextColor = colorTheme.alternateTextColor {
            let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: fontSize, weight: .medium).smallCaps,
                                                             .foregroundColor: alternateTextColor]
            let labelText = NSAttributedString(string: dateString, attributes: attributes)
            dateLabel.attributedText = labelText
        }
    }
    
}
