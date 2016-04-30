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
    var currentSpeed: Float = 5
    var currentDirection = Direction.Up
    var desiredDirection = Direction.None
    
    var movingAnimation: SKAction = SKAction()
    
    // MARK: Getter/Setter
    
    var objectSprite: SKSpriteNode {
        get {
            return _objectSprite!
        }
        
        set (objSprite){
            
            _objectSprite = objSprite
            
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
    
    func goUp() {
        
        currentDirection = .Up
        runAnimation()
    }
    
    func goDown() {
        
        currentDirection = .Down
        runAnimation()
    }
    
    func goLeft() {
        
        currentDirection = .Left
        runAnimation()
        
    }
    
    func goRight() {
        
        currentDirection = .Right
        runAnimation()
        
    }
    
    
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
    
}
