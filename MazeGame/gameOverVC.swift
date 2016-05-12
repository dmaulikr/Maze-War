//
//  gameOverVC.swift
//  MazeGame
//
//  Created by Jack Hider on 10/05/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import UIKit


class gameOverVC: UIViewController {


    @IBAction func restartPressed(sender: AnyObject) {
    
        performSegueWithIdentifier("restartGame", sender: nil)
        
    }


}
