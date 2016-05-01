//
//  Boundary.swift
//  MazeGame
//
//  Created by Jack Hider on 01/05/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import Foundation
import SpriteKit

class Boundary: SKNode {

    // MARK: Initialisers
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(fromSKSWithRect rect: CGRect) {
       super.init()
       
        let newLocation = CGPoint(x: -(rect.size.width/2), y: -(rect.size.height/2) )
        let newRect:CGRect = CGRect (origin: newLocation, size: rect.size)
        
        createBoundary(newRect)
        
    }
    
    init( theDict: Dictionary<String, String> ) {
        super.init()
        let theX:String = theDict["x"]!
        let x:Int = Int(theX)!
    
        let theY:String = theDict["y"]!
        let y:Int = Int(theY)!
        
        let theWidth:String = theDict["width"]!
        let width:Int = Int(theWidth)!
        
        let theHeight:String = theDict["height"]!
        let height:Int = Int(theHeight)!
        
        let location: CGPoint = CGPoint(x: x, y: y * -1)
        let size: CGSize = CGSize(width: width, height: height)
        
        self.position = CGPoint(x: location.x + (size.width / 2), y: location.y - (size.height / 2))
        let rect: CGRect = CGRectMake(-(size.width / 2), -(size.height / 2), size.width, size.height)
        
        createBoundary(rect)
    }
    
    
    // MARK: Functions
    
    func createBoundary(rect: CGRect) {
        
        let shape = SKShapeNode(rect: rect, cornerRadius: 19)
        shape.fillColor = SKColor.clearColor()
        shape.strokeColor = SKColor.whiteColor()
        shape.lineWidth = 1
        
        addChild(shape)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        self.physicsBody!.dynamic = false
        self.physicsBody!.categoryBitMask = BodyType.boundary.rawValue
        self.physicsBody!.friction = 0
        self.physicsBody!.allowsRotation = false
        self.zPosition = 100
        
    }
    
}