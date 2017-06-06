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
    
    init(fromSKSWithRect rect: CGRect, isEdge: Bool) {
       
        super.init()
       
        let newLocation = CGPoint(x: -(rect.size.width / 2), y: -(rect.size.height / 2) )
        let newRect:CGRect = CGRect (origin: newLocation, size: rect.size)
        
        createBoundary(newRect,createAsEdge: isEdge)
        
    }
    
    init( theDict: [String: String] ) {
        super.init()
        
        let isEdgeAsString:String = theDict["isEdge"]!
        var isEdge: Bool
        
        if (isEdgeAsString == "true" ) {
            
            isEdge = true
        }else {
            isEdge = false
        }
        
        
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
        let rect: CGRect = CGRect(x: -(size.width / 2), y: -(size.height / 2), width: size.width, height: size.height)
        
        createBoundary(rect, createAsEdge: isEdge)
    }
    
    
    // MARK: Functions
    
    func createBoundary(_ rect: CGRect, createAsEdge: Bool) {
        
        let shape = SKShapeNode(rect: rect, cornerRadius: 19)
        shape.fillColor = SKColor.clear
        shape.strokeColor = SKColor.white
        shape.lineWidth = 1
        
        addChild(shape)
        
        if (createAsEdge == false) {
            
            self.physicsBody = SKPhysicsBody(rectangleOf: rect.size)
            
        }else {
            
            self.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        }
        
        
        self.physicsBody!.isDynamic = false
        self.physicsBody!.categoryBitMask = BodyType.boundary.rawValue
        self.physicsBody!.friction = 0
        self.physicsBody!.allowsRotation = false
        self.zPosition = 100
        
    }
    
}
