//
//  Enemy.swift
//  MazeGame
//
//  Created by Jack Hider on 02/05/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: SKNode {
    
    
    // MARK: Initialisers
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    init(fromSKSWithImage image:String) {
        
        super.init()
        
        let enemySprite = SKSpriteNode(imageNamed: image)
        addChild(enemySprite)
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
        
    }
    
    // MARK: Functions
    
    
}
