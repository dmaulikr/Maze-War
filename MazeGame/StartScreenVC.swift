//
//  StartScreenVC.swift
//  MazeGame
//
//  Created by Jack Hider on 09/05/2016.
//  Copyright © 2016 Jack Hider. All rights reserved.
//

import UIKit

class StartScreenVC: UIViewController {



    
    @IBAction func buttonPressed(_ sender: AnyObject) {
    
            performSegue(withIdentifier: "startScreen" , sender: nil)
    
    }

}
