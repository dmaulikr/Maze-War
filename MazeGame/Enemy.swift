//
//  Enemy.swift
//  MazeGame
//
//  Created by Jack Hider on 02/05/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import Foundation
import SpriteKit


enum HeroIs {
    
    case Southwest, Southeast, Northwest, Northeast
}

enum EnemyDirection {
    
    case Up, Down, Left, Right
}

class Enemy: SKNode {
    
    // MARK: Variables
    var heroLocationIs = HeroIs.Southwest
    var currentDirection = EnemyDirection.Up
    var enemySpeed:Float = 2
    var previousLocation1: CGPoint = CGPointZero
    var previousLocation2: CGPoint = CGPoint(x: 1, y: 1)
    var isStuck:Bool = false
    
    // MARK: Initialisers
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    init(fromSKSWithImage image:String) {
        
        super.init()
        
        let enemySprite = SKSpriteNode(imageNamed: image)
        addChild(enemySprite)
        
        setupPhysics(enemySprite.size)
    }

    
    init(fromTMXFileWithDict theDict: Dictionary<String, String> ) {
        
        super.init()
        
        let theX:String = theDict["x"]!
        let x:Int = Int(theX)!
        
        let theY:String = theDict["y"]!
        let y:Int = Int(theY)!
        
        let location: CGPoint = CGPoint(x: x, y: y * -1)
        
        let image = theDict["name"]
        
        let enemySprite = SKSpriteNode(imageNamed: image! )
        
        self.position = CGPoint(x: location.x + (enemySprite.size.width / 2), y: location.y - (enemySprite.size.height / 2) )
        
        addChild(enemySprite)
        
        setupPhysics(enemySprite.size)
        
    }
    
    // MARK: Functions
    
    func setupPhysics(size: CGSize) {
        
        // self.physicsBody = SKPhysicsBody(circleOfRadius: enemySprite.size.width / 2  )
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size )
        self.physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        self.physicsBody?.collisionBitMask = BodyType.boundary.rawValue | BodyType.boundary2.rawValue | BodyType.enemy.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.hero.rawValue | BodyType.enemy.rawValue
        self.physicsBody?.allowsRotation = false
        self.zPosition = 90
        
    }
    
    func decideDirection() {
        
        let previousDirection = currentDirection
        
        switch (heroLocationIs) {
            
        case .Southwest:
            if (previousDirection == .Down) {
                
                currentDirection = .Left
            } else {
                
                currentDirection = .Down
            }
        case .Southeast:
            
            if ( previousDirection == .Down) {
                
                currentDirection = .Right
            } else {
                
                currentDirection = .Down
            }
            
        case .Northeast:
            
            if ( previousDirection == .Up) {
                
                currentDirection = .Right
            } else {
                
                currentDirection = .Up
            }
            
        case .Northwest:
            
            if ( previousDirection == .Up) {
                
                currentDirection = .Left
            } else {
                
                currentDirection = .Up
            }
            
            
            
            
        }
        

    }
    
    func update() {
        
        /*  check if enemy is stuck has stayed in same location for more than one update */
        if ( Int(previousLocation2.y) == Int(previousLocation1.y) && Int(previousLocation2.x) == Int(previousLocation1.x) ) {
            
            isStuck = true
            decideDirection()
        
        }
        
        
        let superDice = arc4random_uniform(1000)
        if (superDice == 0) {
            
            let dice = arc4random_uniform(4)
            
            switch (dice) {
            case 0:
                currentDirection = .Up
                
            case 1:
                currentDirection = .Left
                
            case 2:
                currentDirection = .Right
                
            default:
                currentDirection = .Down
            }
        }
        
        
        /*    save a location variable prior to moving */
            previousLocation2 = previousLocation1
        
        
        /*    check direction enemy is moving, increment primarily in that direction
            then add some to either left up down depending on hero compass location
            
        */
        if (currentDirection == .Up) {
            
            self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(enemySpeed) )
            
            if (heroLocationIs == .Northeast) {
                
                self.position = CGPoint(x: self.position.x + CGFloat(enemySpeed), y: self.position.y  )
                
            } else if (heroLocationIs == .Northwest) {
                
                self.position = CGPoint(x: self.position.x -  CGFloat(enemySpeed), y: self.position.y  )
            }
            
        } else if ( currentDirection == .Down){
            
            self.position = CGPoint(x: self.position.x  , y: self.position.y - CGFloat(enemySpeed) )
            
            if ( heroLocationIs == .Southeast) {
                
                self.position = CGPoint(x: self.position.x + CGFloat(enemySpeed)  , y: self.position.y  )
                
            } else if ( heroLocationIs == .Southwest) {
                
                self.position = CGPoint(x: self.position.x - CGFloat(enemySpeed)  , y: self.position.y  )
            }
            
        } else if ( currentDirection == .Right){
            
            self.position = CGPoint(x: self.position.x + CGFloat(enemySpeed) , y: self.position.y )
            
            if ( heroLocationIs == .Southeast) {
                
                self.position = CGPoint(x: self.position.x , y: self.position.y - CGFloat(enemySpeed) )
                
            } else  if ( heroLocationIs == .Northeast) {
                
                self.position = CGPoint(x: self.position.x , y: self.position.y + CGFloat(enemySpeed)  )
            }
            
        } else if ( currentDirection == .Left){
            
            self.position = CGPoint(x: self.position.x - CGFloat(enemySpeed) , y: self.position.y  )
            
            if ( heroLocationIs == .Southwest) {
                
                self.position = CGPoint(x: self.position.x , y: self.position.y - CGFloat(enemySpeed) )
                
            } else if ( heroLocationIs == .Northwest) {
                
                self.position = CGPoint(x: self.position.x , y: self.position.y + CGFloat(enemySpeed)  )
            }
            
        }
        
        /* After moving enemy save the location for comparing later if stuck */
        
        previousLocation1 = self.position
    }
    
    
}








