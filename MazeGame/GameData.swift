//
//  GameData.swift
//  MazeGame
//
//  Created by Jack Hider on 03/05/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import Foundation

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


enum Direction {
    case up, down, right, left, none
}

enum DesiredDirection {
    case up, down, right, left, none
}


enum HeroIs {
    
    case southwest, southeast, northwest, northeast
}

enum EnemyDirection {
    
    case up, down, left, right
}

var livesLeft:Int = 3
var currentLevel:Int = 0
var firstSKSFile:String = "GameScene"
var currentSKSFile:String = firstSKSFile
var useTMXFiles:Bool = false
var currentTMXFile:String?
var nextSKSFile:String?
var bgImage:String?
var enemyLogic:Double = 0
