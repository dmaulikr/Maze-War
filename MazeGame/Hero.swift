//
//  Hero.swift
//  MazeGame
//
//  Created by Jack Hider on 30/04/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import Foundation
import SpriteKit




class Hero: SKNode {
    
    // MARK: Properties
    
    fileprivate var _objectSprite:SKSpriteNode?
    fileprivate var _physicsBodySize: CGSize!
    var currentSpeed: Float = 2
    var currentDirection = Direction.right
    var desiredDirection = DesiredDirection.none
    
    var movingAnimation: SKAction = SKAction()
    
    var downBlocked:Bool = false
    var upBlocked:Bool = false
    var leftBlocked:Bool = false
    var rightBlocked:Bool = false
    
    var nodeUp:SKNode?
    var nodeDown:SKNode?
    var nodeLeft:SKNode?
    var nodeRight:SKNode?
    
    var buffer:Int = 25
    
    // MARK: Getter/Setter
    
    var objectSprite: SKSpriteNode {
        get {
            return _objectSprite!
        }
        
        set (objSprite){
            
            _objectSprite = objSprite
            
        }
    }
    
    var physicsBodySize: CGSize {
        
        get {
            
            return _physicsBodySize
        }
        
        set (largerSize) {
            
            _physicsBodySize = largerSize
        }
    }
    
    
    // MARK: Initialiser
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implimented")
    }
    
        init(heroDict:[String: AnyObject]) {
        
        super.init()
        
        let image:String = heroDict["HeroImage"] as! String
        
        objectSprite = SKSpriteNode(imageNamed: image)
        addChild(objectSprite)
        
            
       if let atlasName:String = heroDict["MovingAtlasFile"] as? String {
                
          if let frameArray:NSArray = (heroDict["MovingFrames"] as? NSArray)! {
                    
                    setUpAnimationWithArray(frameArray, andAtlasNamed: atlasName)
                    runAnimation()
                }
                
       }else {
            
                setUpAnimation()
                runAnimation()
        }
        
        physicsBodySize = CGSize(width: objectSprite.size.width * 1.2 , height: objectSprite.size.height * 1.2)
        self.physicsBody = SKPhysicsBody(rectangleOf: physicsBodySize)
            
        let bodyShape:String = heroDict["BodyShape"] as! String
        
            if( bodyShape == "circle") {
                
                self.physicsBody = SKPhysicsBody(circleOfRadius: objectSprite.size.width / 2)
                
            }else {
                
                self.physicsBody = SKPhysicsBody(rectangleOf: physicsBodySize)

            }
            
        self.physicsBody!.friction = 0 // smooth
        self.physicsBody!.isDynamic = true // true keeps the object within boundries better
        self.physicsBody!.restitution = 0 // no bounce
        self.physicsBody!.allowsRotation = false //
        self.physicsBody!.affectedByGravity = false
        
        self.physicsBody!.categoryBitMask = BodyType.hero.rawValue
        self.physicsBody!.collisionBitMask = 0 // wont collide with anything
        self.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue | BodyType.star.rawValue
        
        nodeUp = SKNode()
        addChild(nodeUp!)
        nodeUp!.position = CGPoint(x: 0, y: buffer)
        createUpSensorPhysicsBody( whileTravellingUpOrDown: false)
        
        nodeDown = SKNode()
        addChild(nodeDown!)
        nodeDown!.position = CGPoint(x: 0, y: -buffer)
        createDownSensorPhysicsBody( whileTravellingUpOrDown: false)
        
        nodeRight = SKNode()
        addChild(nodeRight!)
        nodeRight!.position = CGPoint(x: buffer, y: 0)
        createRightSensorPhysicsBody( whileTravellingLeftOrRight: true)
        
        nodeLeft = SKNode()
        addChild(nodeLeft!)
        nodeLeft!.position = CGPoint(x: -buffer, y: 0)
        createLeftSensorPhysicsBody( whileTravellingLeftOrRight: true)
    }
    
    // MARK: Functions
    
    func update() {
        
        switch currentDirection {
        case .right:
            self.position = CGPoint(x: self.position.x + CGFloat(currentSpeed), y: self.position.y)
            objectSprite.zRotation = CGFloat(degreesToRadians(0))
            
        case .left:
            self.position = CGPoint(x: self.position.x - CGFloat(currentSpeed), y: self.position.y)
            objectSprite.zRotation = CGFloat(degreesToRadians(180))
            
        case .up:
            self.position = CGPoint(x: self.position.x , y: self.position.y + CGFloat(currentSpeed))
            objectSprite.zRotation = CGFloat(degreesToRadians(90))
            
        case .down:
            self.position = CGPoint(x: self.position.x , y: self.position.y - CGFloat(currentSpeed))
            objectSprite.zRotation = CGFloat(degreesToRadians(-90))
            
        case .none:
            self.position = CGPoint(x: self.position.x , y: self.position.y)
            
        
        }
    }
    
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees / 180 * Double(M_PI)
    }
    
    //MARK: Control Functions
    func goUp() {
        
        if (upBlocked == true) {
            
            desiredDirection = DesiredDirection.up
            
        }else {
            
            
            currentDirection = .up
            desiredDirection = .none
            runAnimation()
            
            downBlocked = false
            self.physicsBody?.isDynamic = true
            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: true)
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: false)
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
        }
    }
    
    func goDown() {
        
        if (downBlocked == true) {
            
            desiredDirection = DesiredDirection.down
            
        }else {
            
            
            currentDirection = .down
            desiredDirection = .none
            runAnimation()
            
            upBlocked = false
            self.physicsBody?.isDynamic = true
            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: true)
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: false)
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
        }
    }
    
    func goLeft() {
        
        if (leftBlocked == true) {
            
            desiredDirection = DesiredDirection.left
            
        }else {
            
            
            currentDirection = .left
            desiredDirection = .none
            runAnimation()
            
            rightBlocked = false
            self.physicsBody?.isDynamic = true
            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: false)
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
        }
    }
    
    func goRight() {
        
        if (rightBlocked == true) {
            
            desiredDirection = DesiredDirection.right
            
        }else {
            
            currentDirection = .right
            desiredDirection = .none
            runAnimation()
            
            leftBlocked = false
            self.physicsBody?.isDynamic = true

            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: false)
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
        }
    }
    
    
    //MARK: Animation Functions
    
    func setUpAnimationWithArray(_ theArray:NSArray, andAtlasNamed theAtlas:String ) {
        
        let atlas = SKTextureAtlas(named: theAtlas) //without the .atlas extension
        
        
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< theArray.count {
            
            let texture:SKTexture = atlas.textureNamed( theArray[i] as! String  )
            atlasTextures.insert (texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/30, resize: true, restore:false )
        movingAnimation = SKAction.repeatForever(atlasAnimation)
        
        
    }
    
    func setUpAnimation() {
        
        let atlas = SKTextureAtlas(named: "moving")
        let array:[String] = ["moving0001","moving0002", "moving0003", "moving0004", "moving0003", "moving0002"]
        
        var atlasTextures:[SKTexture] = []
        
        for x in 0..<array.count {
            let texture: SKTexture = atlas.textureNamed(array[x])
            atlasTextures.insert(texture, at: x)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/30, resize: true, restore: false)
        movingAnimation = SKAction.repeatForever(atlasAnimation)
    }
    
    func runAnimation() {
       
        objectSprite.run(movingAnimation)
        
    }
    
    func stopAnimation() {
        
        objectSprite.removeAllActions()
    }
    
    // MARK: Sensor PHysics Body
    
    func createUpSensorPhysicsBody(whileTravellingUpOrDown: Bool) {
        var size:CGSize = CGSize.zero
        
        if(whileTravellingUpOrDown == true) {
            
            size = CGSize(width: 32, height:4)
            
        }else {
            
            size = CGSize(width: 34, height: 36)
        }
        
        nodeUp!.physicsBody = nil // get rid of any body
        let bodyUp:SKPhysicsBody = SKPhysicsBody(rectangleOf: size)
        nodeUp!.physicsBody = bodyUp
        nodeUp!.physicsBody?.categoryBitMask = BodyType.sensorUp.rawValue
        nodeUp!.physicsBody?.collisionBitMask = 0
        nodeUp!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeUp!.physicsBody?.pinned = true
        nodeUp!.physicsBody?.allowsRotation = false
        
    }
    
    func createDownSensorPhysicsBody(whileTravellingUpOrDown:Bool){
        
        var size:CGSize = CGSize.zero
        
        if (whileTravellingUpOrDown == true) {
            
            size = CGSize(width: 32, height: 4)
        } else {
            
            size = CGSize(width: 34 , height:36 )
        }
        
        
        
        nodeDown!.physicsBody = nil
        let bodyDown:SKPhysicsBody = SKPhysicsBody(rectangleOf: size )
        nodeDown!.physicsBody = bodyDown
        nodeDown!.physicsBody?.categoryBitMask = BodyType.sensorDown.rawValue
        nodeDown!.physicsBody?.collisionBitMask = 0
        nodeDown!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeDown!.physicsBody!.pinned = true
        nodeDown!.physicsBody!.allowsRotation = false
        
        
    }
    
    func createLeftSensorPhysicsBody( whileTravellingLeftOrRight:Bool){
        
        var size:CGSize = CGSize.zero
        
        if (whileTravellingLeftOrRight == true) {
            
            size = CGSize(width: 4, height: 32)
        } else {
            
            size = CGSize(width: 36, height: 34)
        }
        
        
        
        nodeLeft!.physicsBody = nil
        let bodyLeft:SKPhysicsBody = SKPhysicsBody(rectangleOf: size )
        nodeLeft!.physicsBody = bodyLeft
        nodeLeft!.physicsBody?.categoryBitMask = BodyType.sensorLeft.rawValue
        nodeLeft!.physicsBody?.collisionBitMask = 0
        nodeLeft!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeLeft!.physicsBody!.pinned = true
        nodeLeft!.physicsBody!.allowsRotation = false
        
        
        
    }
    
    func createRightSensorPhysicsBody( whileTravellingLeftOrRight:Bool){
        
        
        var size:CGSize = CGSize.zero
        
        if (whileTravellingLeftOrRight == true) {
            
            size = CGSize(width: 4, height: 32)
        } else {
            
            size = CGSize(width: 36, height: 34)
        }
        
        
        
        
        nodeRight!.physicsBody = nil
        let bodyRight:SKPhysicsBody = SKPhysicsBody(rectangleOf: size )
        nodeRight!.physicsBody = bodyRight
        nodeRight!.physicsBody?.categoryBitMask = BodyType.sensorRight.rawValue
        nodeRight!.physicsBody?.collisionBitMask = 0
        nodeRight!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeRight!.physicsBody!.pinned = true
        nodeRight!.physicsBody!.allowsRotation = false
        
        
    }
    
    //MARK: Sensor Contact Initiated
    
    func upSensorContactStart() {
        
        upBlocked = true
        
        if(currentDirection == Direction.up) {
            
            currentDirection = Direction.none
            self.physicsBody?.isDynamic = false
            stopAnimation()
        }
    }
    
    func downSensorContactStart() {
        
        downBlocked = true
        
        if(currentDirection == Direction.down) {
            
            currentDirection = Direction.none
            self.physicsBody?.isDynamic = false
            stopAnimation()
        }
        
        
    }
    
    func rightSensorContactStart() {
        
        rightBlocked = true
        
        if(currentDirection == Direction.right) {
            
            currentDirection = Direction.none
            self.physicsBody?.isDynamic = false
            stopAnimation()
        }
        
        
    }
    
    func leftSensorContactStart() {
        
        leftBlocked = true
        
        if(currentDirection == Direction.left) {
            
            currentDirection = Direction.none
            self.physicsBody?.isDynamic = false
            stopAnimation()
        }
        
        
    }
    
    // MARK: Sensor Contact Ended
    
    func upSensorContactEnd() {
        
        upBlocked = false
        
        if (desiredDirection == DesiredDirection.up) {
            
            goUp()
            desiredDirection  == DesiredDirection.none
        }
    }

    func downSensorContactEnd() {
        
        downBlocked = false
        
        if (desiredDirection == DesiredDirection.down) {
            
            goDown()
            desiredDirection  == DesiredDirection.none
        }
        
    }
    
    func rightSensorContactEnd() {
        
        rightBlocked = false
        
        if (desiredDirection == DesiredDirection.right) {
            
            goRight()
            desiredDirection  == DesiredDirection.none
        }
        
    }
    
    func leftSensorContactEnd() {
        
        leftBlocked = false
        
        if (desiredDirection == DesiredDirection.left) {
            
            goLeft()
            desiredDirection  == DesiredDirection.none
        }
        
    }
}
