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
    
    var objectSprite:SKSpriteNode?
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implimented")
    }
    
    override init() {
        super.init()
        
        print("hero was added")
        
        objectSprite = SKSpriteNode(imageNamed: "hero")
        addChild(objectSprite!)
    }
}
