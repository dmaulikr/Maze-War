//
//  GameScene.swift
//  MazeGame
//
//  Created by Jack Hider on 30/04/2016.
//  Copyright (c) 2016 Jack Hider. All rights reserved.
//

import SpriteKit

enum BodyType:UInt32 {
    
    case hero = 1
    case boundary = 2
    case sensorUp = 4
    case sensorDown = 8
    case sensorRight = 16
    case sensorLeft = 32
    case star = 64
    case enemy = 128
    case boundary2 = 256
}


class GameScene: SKScene, SKPhysicsContactDelegate, NSXMLParserDelegate {
    
    // MARK: VARS
    
    
    var currentSpeed:Float = 2
    var heroLocation:CGPoint = CGPointZero
    var mazeWorld:SKNode?
    var hero:Hero?
    var useTMXFiles:Bool = true
    var heroIsDead:Bool = false
    var starAquired:Int = 0
    var starsTotal:Int = 0
    
    // MARK: Overide Functions
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = SKColor.blackColor()
        view.showsPhysics = true
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        physicsWorld.contactDelegate = self
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        /* USe TMX File */
        if (useTMXFiles == true) {
            self.enumerateChildNodesWithName("*") {
                node, stop in
            
                node.removeFromParent()
            }
            mazeWorld = SKNode()
            addChild(mazeWorld!)
            
        }else {
            
            mazeWorld = childNodeWithName("mazeWorld")
            heroLocation = mazeWorld!.childNodeWithName("startingPoint")!.position

        }
        
        /* hero and Maze */
        
        
        hero = Hero()
        hero!.position = heroLocation
        mazeWorld?.addChild(hero!)
        hero?.currentSpeed = currentSpeed
        
        let waitAction: SKAction = SKAction.waitForDuration(0.5)
        self.runAction(waitAction, completion: {
            
            let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:") )
            swipeRight.direction = .Right
            view.addGestureRecognizer(swipeRight)
            
            let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:") )
            swipeLeft.direction = .Left
            view.addGestureRecognizer(swipeLeft)
            
            let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:") )
            swipeUp.direction = .Up
            view.addGestureRecognizer(swipeUp)
            
            let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:") )
            swipeDown.direction = .Down
            view.addGestureRecognizer(swipeDown)
        })
        
        /* Set up based on TMX or SKS */
        
        if (useTMXFiles == false) {
            
            print("setup with SKS")
            setUpBoundaryFromSKS()
            
        }else {
            
            parseTMXFileWithName("Maze")
            mazeWorld!.position = CGPoint(x: mazeWorld!.position.x, y: mazeWorld!.position.y + 800)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
//        for touch in touches {
//            let location = touch.locationInNode(self)
            
            
//        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        hero?.update()
    }
    
    
    // MARK: Functions
    
    
    func parseTMXFileWithName(name: String) {
        
        let path:String = NSBundle.mainBundle().pathForResource(name, ofType: "tmx")!
        let data:NSData = NSData(contentsOfFile: path)!
        let parser:NSXMLParser = NSXMLParser(data: data)
        
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if (elementName == "object") {
            let type:String = attributeDict["type"]!
            
            if(type  == "Boundary") {
                
                let newBoundary:Boundary = Boundary(theDict: attributeDict)
                mazeWorld?.addChild(newBoundary)
            }else if ( type == "Portal") {
                
                let theName:String = attributeDict["name"]!
                if (theName == "StartingPoint") {
                    let theX:String = attributeDict["x"]!
                    let x:Int = Int(theX)!
                    
                    let theY:String = attributeDict["y"]!
                    let y:Int = Int(theY)!
                    
                    hero!.position = CGPoint(x: x, y: y * -1)
                    heroLocation = hero!.position
                    
                }
            }
                
        }
    }
    
    func setUpBoundaryFromSKS() {
       
        mazeWorld?.enumerateChildNodesWithName("boundary") {
            node, stop in
            
            if let boundary = node as? SKSpriteNode {
                
                print("found Boundary")
                let rect: CGRect = CGRect(origin: boundary.position, size: boundary.size)
                let newBoundary: Boundary = Boundary(fromSKSWithRect: rect)
                newBoundary.position = boundary.position
                self.mazeWorld?.addChild(newBoundary)
                
                
                boundary.removeFromParent()

            }
        }
    }
    
    
    func swipedRight(sender: UISwipeGestureRecognizer) {
        
        hero?.goRight()
    }
    
    func swipedLeft(sender: UISwipeGestureRecognizer) {
        
        hero?.goLeft()
    }
    
    func swipedUp(sender: UISwipeGestureRecognizer) {
        
        hero?.goUp()
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer) {
        
        hero?.goDown()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
        case BodyType.hero.rawValue | BodyType.boundary.rawValue :
                print("ran into wall")
            
            
        default:
            return
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
          let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
        case BodyType.hero.rawValue | BodyType.boundary.rawValue :
            print("not into wall")
            
        default:
            return
        }
    }
    
    override func didSimulatePhysics() {
        
        if (heroIsDead == false) {
            
            self.centerOnNode(hero!)
            
        }
    }
    
    func centerOnNode(node: SKNode) {
        
        let cameraPositionInScene:CGPoint = self.convertPoint(node.position, fromNode: mazeWorld!)
        mazeWorld!.position = CGPoint(x: mazeWorld!.position.x - cameraPositionInScene.x, y: mazeWorld!.position.y - cameraPositionInScene.y)
        
        
        
    }
}
