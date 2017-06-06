//
//  GameScene.swift
//  MazeGame
//
//  Created by Jack Hider on 30/04/2016.
//  Copyright (c) 2016 Jack Hider. All rights reserved.
//

import SpriteKit
import AVFoundation
import UIKit


class GameScene: SKScene, SKPhysicsContactDelegate, XMLParserDelegate {
    
    // MARK: VARS
   
    // Game Variables should be in a singleton
    var currentSpeed:Float = 2
    var heroLocation:CGPoint = CGPoint.zero
    var mazeWorld:SKNode?
    var hero:Hero?
    var heroIsDead:Bool = false
    var starAquired:Int = 0
    var starsTotal:Int = 0
    var enemyCount: Int = 0
    var enemyDict:[String : CGPoint] = [:]
    var enemySpeed:Float = 2
    var gameLabel:SKLabelNode?
    var parallaxBG:SKSpriteNode?
    var parallaxOffset:CGPoint = CGPoint.zero
    var bgSoundPlayer:AVAudioPlayer?
    var viewController: UIViewController?
    
    // MARK: Overide Functions
    
    override func didMove(to view: SKView) {
       
        /* Parse Property List */
        
        let path = Bundle.main.path(forResource: "GameData", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)!
        let heroDict:NSDictionary = dict.object(forKey: "HeroSettings")! as! NSDictionary
        let gameDict:NSDictionary = dict.object(forKey: "GameSettings")! as! NSDictionary
        let levelArray:NSArray = dict.object(forKey: "LevelSettings")! as! NSArray
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
        
        if let musicFile = levelDict["Music"] as? String {
            
             playBackgroundSound(musicFile)
            
        }
        
        
  
        /* Setup your scene here */
        // set our delegates that the class conforms to
        physicsWorld.contactDelegate = self
        
        // set background colour of our view
        self.backgroundColor = SKColor.black
        
        //show physics bodies
        view.showsPhysics = gameDict["ShowPhysics"] as! Bool
        
        if (gameDict["Gravity"] != nil) {
            let newGravity:CGPoint = CGPointFromString(gameDict["Gravity"] as! String)
            physicsWorld.gravity = CGVector(dx: newGravity.x, dy: newGravity.y)
            
        }else {
        
            // set gravity to zero for now
            physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        }
        
        // background Stuff
        
        if (gameDict["ParallaxOffset"] != nil) {
            
            parallaxOffset = CGPointFromString( (gameDict["ParallaxOffset"] as? String)! )
            
        }
        
        // set the anchor point of the maze
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        /* Use TMX File */
        
        useTMXFiles = gameDict["UseTMXFile"] as! Bool
        
        if (useTMXFiles == true) {
            self.enumerateChildNodes(withName: "*") {
                node, stop in
            
                node.removeFromParent()
            }
            mazeWorld = SKNode()
            addChild(mazeWorld!)
            
        }else {
            
            mazeWorld = childNode(withName: "mazeWorld")
            heroLocation = mazeWorld!.childNode(withName: "startingPoint")!.position

        }
        
        /* hero and Maze */
        hero = Hero(heroDict: heroDict as! Dictionary)
        hero!.position = heroLocation
        mazeWorld?.addChild(hero!)
        hero?.currentSpeed = currentSpeed
        
        if(bgImage != nil) {
            
            createBackground(bgImage!)
        }
        
        
        let waitAction: SKAction = SKAction.wait(forDuration: 0.5)
        self.run(waitAction, completion: {
            
            let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight(_:)) )
            swipeRight.direction = .right
            view.addGestureRecognizer(swipeRight)
            
            let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedLeft(_:)) )
            swipeLeft.direction = .left
            view.addGestureRecognizer(swipeLeft)
            
            let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedUp(_:)) )
            swipeUp.direction = .up
            view.addGestureRecognizer(swipeUp)
            
            let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedDown(_:)) )
            swipeDown.direction = .down
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
        createLabel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
//        for touch in touches {
//            let location = touch.locationInNode(self)
            
            
//        }
    }
   
    // updates the hero position
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if (heroIsDead == false) {
        
            hero?.update()
        
            mazeWorld!.enumerateChildNodes(withName: "enemy*") {
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
            hero!.currentDirection = .right
            hero!.desiredDirection = .none
            hero!.goRight()
            hero!.runAnimation()
            
        }
    }
    // center the maze node on the hero
    override func didSimulatePhysics() {
        
        if (heroIsDead == false) {
            
            self.centerOnNode(hero!)
            
        }
    }

    
    
    // MARK: Functions
   
    
    
    // gets the path of the tmx file and sets up the parser
    func parseTMXFileWithName(_ name: String) {
        
        let path:String = Bundle.main.path(forResource: name, ofType: "tmx")!
        let data:Data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let parser:XMLParser = XMLParser(data: data)
        
        parser.delegate = self
        parser.parse()
    }
    //this parses the tmx file and sets teh positions of the boundaries and other game items
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
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
                starsTotal += 1

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
                
                enemyCount += 1
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
       
        mazeWorld?.enumerateChildNodes(withName: "boundary") {
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
        
        mazeWorld?.enumerateChildNodes(withName: "edge") {
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
        mazeWorld!.enumerateChildNodes(withName: "star") {
            node, stop in
            
            if let star = node as? SKSpriteNode {
                
                let newStar:Star = Star()
                self.mazeWorld!.addChild(newStar)
                newStar.position = star.position
                
                self.starsTotal += 1
                
                star.removeFromParent()
                
            }
        }
    }
    
    // swipe control functions
    func swipedRight(_ sender: UISwipeGestureRecognizer) {
        
        hero?.goRight()
    }
    
    func swipedLeft(_ sender: UISwipeGestureRecognizer) {
        
        hero?.goLeft()
    }
    
    func swipedUp(_ sender: UISwipeGestureRecognizer) {
        
        hero?.goUp()
    }
    
    func swipedDown(_ sender: UISwipeGestureRecognizer) {
        
        hero?.goDown()
    }
    
    // MARK: Collision Functions
    
    func didBegin(_ contact: SKPhysicsContact) {
        
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
            
            let collectSound:SKAction = SKAction.playSoundFileNamed("collect_something.caf", waitForCompletion: false)
            self.run(collectSound)
            
            if let star = contact.bodyA.node as? Star {
                
                star.removeFromParent()
                
            }else if let star = contact.bodyB.node as? Star {
                
                star.removeFromParent()
                
            }
            
            starAquired += 1
            
            if( starAquired == starsTotal ) {
                
                loadNextLevel()
            }
            
           
            
        default:
            return
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
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
    
    
    func centerOnNode(_ node: SKNode) {
        
        let cameraPositionInScene:CGPoint = self.convert(node.position, from: mazeWorld!)
        mazeWorld!.position = CGPoint(x: mazeWorld!.position.x - cameraPositionInScene.x, y: mazeWorld!.position.y - cameraPositionInScene.y)
        
        if(parallaxOffset.x != 0) {
           
            if( Int(cameraPositionInScene.x) < 0 ) {
                
                parallaxBG!.position = CGPoint(x: parallaxBG!.position.x + parallaxOffset.x, y: parallaxBG!.position.y)
               
                
            }else if( Int(cameraPositionInScene.x) > 0 ) {
            
                parallaxBG!.position = CGPoint(x: parallaxBG!.position.x - parallaxOffset.x, y: parallaxBG!.position.y)
                

                
            }
            
        }
        
        if(parallaxOffset.y != 0) {
            
            if( Int(cameraPositionInScene.y) < 0 ) {
                
                parallaxBG!.position = CGPoint(x: parallaxBG!.position.x , y: parallaxBG!.position.y + parallaxOffset.y)
             

                
            }else if( Int(cameraPositionInScene.y) > 0 ) {
                
                parallaxBG!.position = CGPoint(x: parallaxBG!.position.x , y: parallaxBG!.position.y - parallaxOffset.y)
               

                
            }
            
        }
        
    }
    
    // MARK: Enemy Stuff
    
    func setupEnemiesFromSKS() {
        
        mazeWorld?.enumerateChildNodes(withName: "enemy*") {
            node, stop in
            
            if let enemy = node as? SKSpriteNode {
                
                self.enemyCount += 1
                
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
        
        let enemyAction:SKAction = SKAction.wait(forDuration: enemyLogic)
        self.run(enemyAction, completion: {
                self.tellEnemiesWhereHeroIs()
            } )
        
        mazeWorld!.enumerateChildNodes(withName: "enemy*") {
            node, stop in
            
            if let enemy = node as? Enemy {
                
                enemy.heroLocationIs = self.returnTheDirection(enemy)

            }
        }
        
    }
    
    func returnTheDirection(_ enemy:Enemy) -> HeroIs {
        
        if (self.hero!.position.x < enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
           return HeroIs.southwest
            
        }else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
            return HeroIs.southeast
            
        } else if (self.hero!.position.x < enemy.position.x && self.hero!.position.y >  enemy.position.y) {
            
            return HeroIs.northwest
            
        } else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y >  enemy.position.y) {
            
            return HeroIs.northeast
        }else {
           
            return HeroIs.northeast
        }
        
    }
    
    // MARK: Level Stuff
    
    func reloadLevel() {
        
        
        loseLife()
        heroIsDead = true
        
    }
    
    
    func  resetEnemies() {
        
        
        
        for (name, location) in enemyDict {
            
            mazeWorld!.childNode(withName: name)?.position = location
        }
        
    }
    
    
    func loadNextLevel() {
    
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }

        currentLevel += 1
        
        
        
        
        if ( useTMXFiles == true) {
    
            loadNextTMXLevel()
    
        }else {
        
            loadNextSKSLevel()
            }
    
    }
    
    
    func loadNextTMXLevel() {
        
        let scene:GameScene = GameScene(size: self.size)
        scene.scaleMode = .aspectFill
        
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1) )
        
    }
    
    
    func loadNextSKSLevel() {
        
        currentSKSFile = nextSKSFile!
        
        let scene = GameScene.unarchiveFromFile(currentSKSFile) as? GameScene
        scene!.scaleMode = .aspectFill
        
        self.view?.presentScene(scene!, transition: SKTransition.fade(withDuration: 1))
        
        
    }
    
    func loseLife() {
        
        livesLeft = livesLeft - 1
        
        if(livesLeft == 0) {
            
            gameLabel!.text = "Game Over"
            gameLabel!.position = CGPoint.zero
            gameLabel!.horizontalAlignmentMode = .center
            
            playBackgroundSound("endgame")
            
            let scaleAction:SKAction = SKAction.scale(to: 0.2, duration: 3.0)
            let fadeAction:SKAction = SKAction.fadeOut(withDuration: 2)
            let seqAction:SKAction = SKAction.group([fadeAction, scaleAction])
            
            mazeWorld!.run(seqAction, completion: {
                
                self.resetGame()
            } )
            
        }else {
            
            // lives left label
            gameLabel!.text = "Lives: \(livesLeft)"
        }
        
    }
    
    
    func resetGame() {
        
        livesLeft = 3
        currentLevel = 0
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }

       self.viewController!.performSegue(withIdentifier: "gameOver" , sender: nil)
        
//        if( useTMXFiles == true) {
//            
//            loadNextTMXLevel()
//            
//        }else {
//            
//            currentSKSFile = firstSKSFile
//            let scene = GameScene.unarchiveFromFile(currentSKSFile) as? GameScene
//            scene!.scaleMode = .AspectFill
//            
//            self.view?.presentScene(scene!, transition: SKTransition.fadeWithDuration(1))
//
//        }
        
    }
    
    func createLabel() {
        
        gameLabel = SKLabelNode(fontNamed: "BM germar")
        gameLabel!.horizontalAlignmentMode = .left
        gameLabel!.verticalAlignmentMode = .center
        gameLabel!.fontColor = SKColor.white
        gameLabel!.text = "Lives: \(livesLeft)"
        
        addChild(gameLabel!)
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 3))
            
        }else if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 2.3))
            
        }
        
    }
    
    
    
    func createBackground(_ image:String) {
        
        parallaxBG = SKSpriteNode(imageNamed: image)
        mazeWorld!.addChild(parallaxBG!)
        parallaxBG!.position = CGPoint(x: parallaxBG!.size.width , y: -parallaxBG!.size.height / 2)
        parallaxBG!.alpha = 0.5
        
    }
    
    
    func playBackgroundSound(_ Sound:String) {
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        
        let fileURL:URL = Bundle.main.url( forResource: Sound, withExtension: "mp3" )!
        
        do {
        
                bgSoundPlayer = try AVAudioPlayer(contentsOf: fileURL)
            
        }catch {
            
            bgSoundPlayer = nil
            
        }
        
        bgSoundPlayer!.volume = 0.5  //half volume
        bgSoundPlayer!.numberOfLoops = -1
        bgSoundPlayer!.prepareToPlay()
        bgSoundPlayer!.play()

        
    }
    
    
    
}//end of class
