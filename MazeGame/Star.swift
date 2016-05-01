//
//  Star.swift
//  MazeGame
//
//  Created by Jack Hider on 01/05/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import Foundation
import SpriteKit

class Star: SKNode {
    
    // MARK Variables
    
    var starSprite: SKSpriteNode!
    
    //MARK: Initialisers
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implimented")
    }
    
    override init() {
        
        super.init()
        starSprite = SKSpriteNode(imageNamed: "star")
        addChild(starSprite)
        
        createPhysicsBody()
    }
    
    init(fromTMXFileWithDict theDict: Dictionary<String, String> ) {
        
        super.init()
        let theX:String = theDict["x"]!
        let x:Int = Int(theX)!
        
        let theY:String = theDict["y"]!
        let y:Int = Int(theY)!
        
        let location: CGPoint = CGPoint(x: x, y: y * -1)
        starSprite = SKSpriteNode(imageNamed: "star")
        addChild(starSprite!)
        
        self.position = CGPoint(x: location.x + (starSprite.size.width / 2), y: location.y - (starSprite.size.height / 2) )
        
        createPhysicsBody()
    }
    
    //MARK: Functions )
    
    func createPhysicsBody() {
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: starSprite.size.width / 2)
        self.physicsBody?.categoryBitMask = BodyType.star.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = BodyType.hero.rawValue
        
        self.zPosition = 90
    }
    
}
