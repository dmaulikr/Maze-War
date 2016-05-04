//
//  GameScene.swift
//  MazeGame
//
//  Created by Jack Hider on 30/04/2016.
//  Copyright (c) 2016 Jack Hider. All rights reserved.
//

import SpriteKit

//enum BodyType:UInt32 {
//    
//    case hero = 1
//    case boundary = 2
//    case sensorUp = 4
//    case sensorDown = 8
//    case sensorRight = 16
//    case sensorLeft = 32
//    case star = 64
//    case enemy = 128
//    case boundary2 = 256
//}


class GameScene: SKScene, SKPhysicsContactDelegate, NSXMLParserDelegate {
    
    // MARK: VARS
   
    // Game Variables should be in a singleton
    var currentSpeed:Float = 2
    var heroLocation:CGPoint = CGPointZero
    var mazeWorld:SKNode?
    var hero:Hero?
    var heroIsDead:Bool = false
    var starAquired:Int = 0
    var starsTotal:Int = 0
    var enemyCount: Int = 0
    var enemyDict:[String : CGPoint] = [:]
    var enemySpeed:Float = 2
    
    
    
    // MARK: Overide Functions
    
    override func didMoveToView(view: SKView) {
       
        /* Parse Property List */
        
        let path = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)!
        let heroDict:NSDictionary = dict.objectForKey("HeroSettings")! as! NSDictionary
        let gameDict:NSDictionary = dict.objectForKey("GameSettings")! as! NSDictionary
        let levelArray:NSArray = dict.objectForKey("LevelSettings")! as! NSArray
        let levelDict:NSDictionary = levelArray[currentLevel] as! NSDictionary
        
        if let tmxFile = levelDict["TMXFile"] as? String {
            
            currentTMXFile = tmxFile
        }
        
        if let sksFile = levelDict["NextSKSFile"] as? String {
            
            nextSKSFile = sksFile
        }
        
        if let speed = levelDict["Speed"] as? Float {
            
            currentSpeed = speed
        }
        
        if let eSpeed = levelDict["EnemySpeed"] as? Float {
            
           enemySpeed = eSpeed
        
        }
        
        if let Image = levelDict["Background"] as? String {
            
            bgImage = Image
            
        }
        
        if let logic = levelDict["EnemyLogic"] as? Double {
            
            enemyLogic = logic
            
        }
        
        
//        print(levelArray)
  
        /* Setup your scene here */
        // set our delegates that the class conforms to
        physicsWorld.contactDelegate = self
        
        // set background colour of our view
        self.backgroundColor = SKColor.blackColor()
        //show physics bodies
        view.showsPhysics = gameDict["ShowPhysics"] as! Bool
        
        if (gameDict["Gravity"] != nil) {
            let newGravity:CGPoint = CGPointFromString(gameDict["Gravity"] as! String)
            physicsWorld.gravity = CGVector(dx: newGravity.x, dy: newGravity.y)
            
        }else {
        
            // set gravity to zero for now
            physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        }
        
        // set the anchor point of the maze
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        /* Use TMX File */
        
        useTMXFiles = gameDict["UseTMXFile"] as! Bool
        
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
        hero = Hero(heroDict: heroDict as! Dictionary)
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
            
            setUpBoundaryFromSKS()
            setUpStarsFromSKS()
            setUpEdgeFromSKS()
            setupEnemiesFromSKS()
            
        }else {
            
            parseTMXFileWithName(currentTMXFile!)
        }
        
        tellEnemiesWhereHeroIs()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
//        for touch in touches {
//            let location = touch.locationInNode(self)
            
            
//        }
    }
   
    // updates the hero position
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if (heroIsDead == false) {
        
            hero?.update()
        
            mazeWorld!.enumerateChildNodesWithName("enemy*") {
                node, stop in
            
                if let enemy = node as? Enemy {
            
                    if(enemy.isStuck == true) {
                    
                        enemy.heroLocationIs = self.returnTheDirection(enemy)
                        enemy.decideDirection()
                        enemy.isStuck = false
                    }
                    enemy.update()
                
                }
            }
        }else {
            
            resetEnemies()
            
            hero!.rightBlocked = false
            hero!.position = heroLocation
            heroIsDead = false
            hero!.currentDirection = .Right
            hero!.desiredDirection = .None
            hero!.goRight()
            hero!.runAnimation()
            
        }
    }
    // center the maze node on teh hero
    override func didSimulatePhysics() {
        
        if (heroIsDead == false) {
            
            self.centerOnNode(hero!)
            
        }
    }

    
    
    // MARK: Functions
   
    
    
    // gets the path of the tmx file and sets up the parser
    func parseTMXFileWithName(name: String) {
        
        let path:String = NSBundle.mainBundle().pathForResource(name, ofType: "tmx")!
        let data:NSData = NSData(contentsOfFile: path)!
        let parser:NSXMLParser = NSXMLParser(data: data)
        
        parser.delegate = self
        parser.parse()
    }
    //this parses the tmx file and sets teh positions of the boundaries and other game items
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if (elementName == "object") {
            let type:String = attributeDict["type"]!
            
            if(type  == "Boundary") {
                
                var tmxDict = attributeDict
                tmxDict.updateValue("false", forKey: "isEdge")
                
                let newBoundary:Boundary = Boundary(theDict: tmxDict)
                mazeWorld?.addChild(newBoundary)
                
            }else if (type == "Edge") {
                
                var tmxDict = attributeDict
                tmxDict.updateValue("true", forKey: "isEdge")
            
                let newBoundary:Boundary = Boundary(theDict: tmxDict)
                mazeWorld?.addChild(newBoundary)
                
            }else if (type  == "Star") {
                
                let newStar:Star = Star(fromTMXFileWithDict: attributeDict)
                mazeWorld?.addChild(newStar)
                starsTotal++

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
            }else if (type == "Enemy") {
                
                enemyCount++
                let theName:String = attributeDict["name"]!
                let newEnemy:Enemy = Enemy(fromTMXFileWithDict: attributeDict)
                mazeWorld!.addChild(newEnemy)
                
                newEnemy.enemySpeed = self.enemySpeed
                newEnemy.name = theName
                
                let location:CGPoint = newEnemy.position
                enemyDict.updateValue(location, forKey: newEnemy.name!)
                
            }
                
        }
    }
    
    
    
   
    
    // set boudaries from sks file if used
    func setUpBoundaryFromSKS() {
       
        mazeWorld?.enumerateChildNodesWithName("boundary") {
            node, stop in
            
            if let boundary = node as? SKSpriteNode {
                
                let rect: CGRect = CGRect(origin: boundary.position, size: boundary.size)
                let newBoundary: Boundary = Boundary(fromSKSWithRect: rect, isEdge: false)
                newBoundary.position = boundary.position
                self.mazeWorld?.addChild(newBoundary)
                
                
                boundary.removeFromParent()

            }
        }
    }
    
    func setUpEdgeFromSKS() {
        
        mazeWorld?.enumerateChildNodesWithName("edge") {
            node, stop in
            
            if let edge = node as? SKSpriteNode {
                
            
                let rect: CGRect = CGRect(origin: edge.position, size: edge.size)
                let newEdge: Boundary = Boundary(fromSKSWithRect: rect, isEdge: true)
                newEdge.position = edge.position
                self.mazeWorld?.addChild(newEdge)
                
                
                edge.removeFromParent()
                
            }
        }
    }
    
    // set up starts from sks file
    func setUpStarsFromSKS() {
        mazeWorld!.enumerateChildNodesWithName("star") {
            node, stop in
            
            if let star = node as? SKSpriteNode {
                
                let newStar:Star = Star()
                self.mazeWorld!.addChild(newStar)
                newStar.position = star.position
                
                self.starsTotal++
                
                star.removeFromParent()
                
            }
        }
    }
    
    // swipe control functions
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
    
    // MARK: Collision Functions
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
        
        case BodyType.hero.rawValue | BodyType.enemy.rawValue :
            reloadLevel()
        
        case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue :
            hero!.upSensorContactStart()
            
        case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue :
            hero!.downSensorContactStart()
            
        case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue :
            hero!.rightSensorContactStart()
            
        case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue :
            hero!.leftSensorContactStart()
            
        case BodyType.hero.rawValue | BodyType.star.rawValue :
            
            if let star = contact.bodyA.node as? Star {
                
                star.removeFromParent()
                
            }else if let star = contact.bodyB.node as? Star {
                
                star.removeFromParent()
                
            }
            
            starAquired++
            
            
           
            
        default:
            return
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
          let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
        
        case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue :
            hero!.upSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue :
            hero!.downSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue :
            hero!.rightSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue :
            hero!.leftSensorContactEnd()
            
        default:
            return
        }
    }
    
    
    func centerOnNode(node: SKNode) {
        
        let cameraPositionInScene:CGPoint = self.convertPoint(node.position, fromNode: mazeWorld!)
        mazeWorld!.position = CGPoint(x: mazeWorld!.position.x - cameraPositionInScene.x, y: mazeWorld!.position.y - cameraPositionInScene.y)
        
        
        
    }
    
    // MARK: Enemy Stuff
    
    func setupEnemiesFromSKS() {
        
        mazeWorld?.enumerateChildNodesWithName("enemy*") {
            node, stop in
            
            if let enemy = node as? SKSpriteNode {
                
                self.enemyCount++
                
                let newEnemy:Enemy = Enemy(fromSKSWithImage: enemy.name!)
                self.mazeWorld!.addChild(newEnemy)
                newEnemy.position = enemy.position
                newEnemy.name = enemy.name
                newEnemy.enemySpeed = self.enemySpeed
                
                self.enemyDict.updateValue(newEnemy.position, forKey: newEnemy.name!)
                
                enemy.removeFromParent()
            }
        }
        
        
    }
    
    
    func tellEnemiesWhereHeroIs() {
        
        let enemyAction:SKAction = SKAction.waitForDuration(enemyLogic)
        self.runAction(enemyAction, completion: {
                self.tellEnemiesWhereHeroIs()
            } )
        
        mazeWorld!.enumerateChildNodesWithName("enemy*") {
            node, stop in
            
            if let enemy = node as? Enemy {
                
                enemy.heroLocationIs = self.returnTheDirection(enemy)

            }
        }
        
    }
    
    func returnTheDirection(enemy:Enemy) -> HeroIs {
        
        if (self.hero!.position.x < enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
           return HeroIs.Southwest
            
        }else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
            return HeroIs.Southeast
            
        } else if (self.hero!.position.x < enemy.position.x && self.hero!.position.y >  enemy.position.y) {
            
            return HeroIs.Northwest
            
        } else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y >  enemy.position.y) {
            
            return HeroIs.Northeast
        }else {
           
            return HeroIs.Northeast
        }
        
    }
    
    // MARK: Level Stuff
    
    func reloadLevel() {
        
        heroIsDead = true
        
    }
    
    
    func  resetEnemies() {
        
        currentLevel++
        
        for (name, location) in enemyDict {
            
            mazeWorld!.childNodeWithName(name)?.position = location
        }
        
    }
    
    
    func loadNextLevel() {
    
    if ( useTMXFiles == true) {
    
        loadNextTMXLevel()
    
    }else {
        
            loadNextSKSLevel()
        }
    
    }
    
    
    func loadNextTMXLevel() {
        
        let scene:GameScene = GameScene(size: self.size)
        scene.scaleMode = .AspectFill
        
        self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(1) )
        
    }
    
    
    func loadNextSKSLevel() {
        
        currentSKSFile = nextSKSFile!
        
        let scene = GameScene.unarchiveFromFile(currentSKSFile) as? GameScene
        scene!.scaleMode = .AspectFill
        
        self.view?.presentScene(scene!, transition: SKTransition.fadeWithDuration(1))
        
        
    }
    
    
    
    
}//end of class
