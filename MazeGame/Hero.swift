//
//  Hero.swift
//  MazeGame
//
//  Created by Jack Hider on 30/04/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction {
    case Up, Down, Right, Left, None
}

enum DesiredDirection {
    case Up, Down, Right, Left, None
}


class Hero: SKNode {
    
    // MARK: Properties
    
    private var _objectSprite:SKSpriteNode?
    private var _physicsBodySize: CGSize!
    var currentSpeed: Float = 2
    var currentDirection = Direction.Right
    var desiredDirection = Direction.None
    
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
    
    override init() {
        super.init()
        
        print("hero was added")
        
        objectSprite = SKSpriteNode(imageNamed: "hero")
        addChild(objectSprite)
        
        setUpAnimation()
        runAnimation()
        
        physicsBodySize = CGSize(width: objectSprite.size.width * 1.2, height: objectSprite.size.height)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: physicsBodySize)
        self.physicsBody!.friction = 0 // smooth
        self.physicsBody!.dynamic = true // true keeps the object within boundries better
        self.physicsBody!.restitution = 0 // no bounce
        self.physicsBody!.allowsRotation = false //
        self.physicsBody!.affectedByGravity = false
        
        self.physicsBody!.categoryBitMask = BodyType.hero.rawValue
//        self.physicsBody!.collisionBitMask = 0 // wont collide with anything
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
        case .Right:
            self.position = CGPoint(x: self.position.x + CGFloat(currentSpeed), y: self.position.y)
            objectSprite.zRotation = CGFloat(degreesToRadians(0))
            
        case .Left:
            self.position = CGPoint(x: self.position.x - CGFloat(currentSpeed), y: self.position.y)
            objectSprite.zRotation = CGFloat(degreesToRadians(180))
            
        case .Up:
            self.position = CGPoint(x: self.position.x , y: self.position.y + CGFloat(currentSpeed))
            objectSprite.zRotation = CGFloat(degreesToRadians(90))
            
        case .Down:
            self.position = CGPoint(x: self.position.x , y: self.position.y - CGFloat(currentSpeed))
            objectSprite.zRotation = CGFloat(degreesToRadians(-90))
            
        case .None:
            self.position = CGPoint(x: self.position.x , y: self.position.y)
            
        
        }
    }
    
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees / 180 * Double(M_PI)
    }
    
    //MARK: Control Functions
    func goUp() {
        
        currentDirection = .Up
        runAnimation()
        createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: true)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: false)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
    }
    
    func goDown() {
        
        currentDirection = .Down
        runAnimation()
        createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: true)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: false)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
    }
    
    func goLeft() {
        
        currentDirection = .Left
        runAnimation()
        createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: false)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
        
    }
    
    func goRight() {
        
        currentDirection = .Right
        runAnimation()
        createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: false)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
        
    }
    
    
    //MARK: Animation Functions
    
    func setUpAnimation() {
        
        let atlas = SKTextureAtlas(named: "moving")
        let array:[String] = ["moving0001","moving0002", "moving0003", "moving0004", "moving0003", "moving0002"]
        
        var atlasTextures:[SKTexture] = []
        
        for x in 0..<array.count {
            let texture: SKTexture = atlas.textureNamed(array[x])
            atlasTextures.insert(texture, atIndex: x)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/30, resize: true, restore: false)
        movingAnimation = SKAction.repeatActionForever(atlasAnimation)
    }
    
    func runAnimation() {
       
        objectSprite.runAction(movingAnimation)
        
    }
    
    func stopAnimation() {
        
        objectSprite.removeAllActions()
    }
    
    func createUpSensorPhysicsBody(whileTravellingUpOrDown whileTravellingUpOrDown: Bool) {
        var size:CGSize = CGSizeZero
        
        if(whileTravellingUpOrDown == true) {
            
            size = CGSize(width: 32, height: 4)
            
        }else {
            
            size = CGSize(width: 32.4, height: 36)
        }
        
        nodeUp!.physicsBody = nil // get rid of any body
        let bodyUp:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size)
        nodeUp!.physicsBody = bodyUp
        nodeUp!.physicsBody?.categoryBitMask = BodyType.sensorUp.rawValue
        nodeUp!.physicsBody?.collisionBitMask = 0
        nodeUp!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeUp!.physicsBody?.pinned = true
        nodeUp!.physicsBody?.allowsRotation = false
        
    }
    
    func createDownSensorPhysicsBody(whileTravellingUpOrDown whileTravellingUpOrDown:Bool){
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingUpOrDown == true) {
            
            size = CGSize(width: 32, height: 4)
        } else {
            
            size = CGSize(width: 32.4 , height:36 )
        }
        
        
        
        nodeDown?.physicsBody = nil
        let bodyDown:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        
        
        
        nodeDown!.physicsBody = bodyDown
        nodeDown!.physicsBody?.categoryBitMask = BodyType.sensorDown.rawValue
        nodeDown!.physicsBody?.collisionBitMask = 0
        nodeDown!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeDown!.physicsBody!.pinned = true
        nodeDown!.physicsBody!.allowsRotation = false
        
        
    }
    
    func createLeftSensorPhysicsBody( whileTravellingLeftOrRight whileTravellingLeftOrRight:Bool){
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingLeftOrRight == true) {
            
            size = CGSize(width: 4, height: 32)
        } else {
            
            size = CGSize(width: 36, height: 32.4)
        }
        
        
        
        nodeLeft?.physicsBody = nil
        let bodyLeft:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        nodeLeft!.physicsBody = bodyLeft
        nodeLeft!.physicsBody?.categoryBitMask = BodyType.sensorLeft.rawValue
        nodeLeft!.physicsBody?.collisionBitMask = 0
        nodeLeft!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeLeft!.physicsBody!.pinned = true
        nodeLeft!.physicsBody!.allowsRotation = false
        
        
        
    }
    
    func createRightSensorPhysicsBody( whileTravellingLeftOrRight whileTravellingLeftOrRight:Bool){
        
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingLeftOrRight == true) {
            
            size = CGSize(width: 4, height: 32)
        } else {
            
            size = CGSize(width: 36, height: 32.4)
        }
        
        
        
        
        nodeRight?.physicsBody = nil
        let bodyRight:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        nodeRight!.physicsBody = bodyRight
        nodeRight!.physicsBody?.categoryBitMask = BodyType.sensorRight.rawValue
        nodeRight!.physicsBody?.collisionBitMask = 0
        nodeRight!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeRight!.physicsBody!.pinned = true
        nodeRight!.physicsBody!.allowsRotation = false
        
        
    }

}
