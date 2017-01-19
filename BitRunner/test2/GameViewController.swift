//
//  GameViewController.swift
//  NinjaWarrior
//
//  Created by Ivan Huang on 12/7/16.
//  Copyright © 2016 Ivan Huang. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameSceneDelegate {
    
    weak var scene: GameScene? = GameScene()
    var level = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            scene = GameScene(fileNamed: "GameScene")!

            // Set the scale mode to scale to fit the window
            scene!.scaleMode = .aspectFill
            scene!.level = self.level
            scene!.gameSceneDelegate = self
                
            // Present the scene
            view.presentScene(scene!)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            // view.showsNodeCount = true
            // view.showsPhysics = true
            
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func levelEnded() {
        
        let appWindow = self.view?.window
        
        // dismissing game view controller
        self.dismiss(animated: true, completion: {})

        /*
        // cleaning game scene
        for c in scene!.children {
            c.removeAllActions()
            c.removeFromParent()
        }*/
        
        scene!.removeAllChildren()
        scene!.removeAllActions()
        
        
        
        // removing main labels
        scene!.scoreLabel.removeFromParent()
        scene!.headingLabel.removeFromParent()
        scene!.timeLabel.removeFromParent()
        scene!.levelCompleteShape.removeFromParent()
        scene!.finishLabel.removeFromParent()
        scene!.menuLabel.removeFromParent()
        
        // deleting scene objects
        scene!.sceneLevel = Level()
        scene!.player = Player()
        scene!.enemies.removeAll()
        scene!.projectiles.removeAll()
        scene!.doorLabel.removeFromParent()
        scene!.door.removeFromParent()
        scene!.key.removeFromParent()
        
        // removing touch variables
        scene!.touchTimers = [UITouch:Int]()
        scene!.touch = GameScene.ScreenTouch()
        
        scene = GameScene()
        
 
        

        
        
        
        // loading new view
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        appWindow?.rootViewController = mainVC
        

    }
    
    
}
