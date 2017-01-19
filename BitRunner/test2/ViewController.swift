//
//  ViewController.swift
//
//  Created by Ivan Huang on 12/22/16.
//  Copyright © 2016 Ivan Huang. All rights reserved.
//

import UIKit
import SpriteKit
import Darwin
import AVFoundation

class ViewController: UIViewController {
    
    
    // major labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var controlsLabel: UILabel!
    @IBOutlet weak var exitLabel: UILabel!
    @IBOutlet weak var ninjaLogo: UIImageView!
    @IBOutlet weak var creditsLabel1: UILabel!
    let controlsImage = UIImage(named: "question")!.withRenderingMode(.alwaysTemplate)
    let exitImage = UIImage(named: "exit")!.withRenderingMode(.alwaysTemplate)
    
    // lock image
    let lockImage = UIImage(named: "lock")
    var lockImageViews = [UIImageView](repeating: UIImageView(), count: 7)
    
    // level labels and locks
    @IBOutlet weak var L7: UILabel!
    @IBOutlet weak var L6: UILabel!
    @IBOutlet weak var L5: UILabel!
    @IBOutlet weak var L4: UILabel!
    @IBOutlet weak var L3: UILabel!
    @IBOutlet weak var L2: UILabel!
    @IBOutlet weak var L1: UILabel!
    var levelLabels = [UILabel](repeating: UILabel(), count: 7)
    
    // score labels
    var scoreLabels = [UILabel](repeating: UILabel(), count: 7)
    
    // data from NSDefaults
    var lastLevel = 1
    var highScores = [Int](repeating: 0, count: 7)


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()


        // loading resources
        Resources.loadAnimations()
        Resources.loadMusic()
        
        let screenSize = UIScreen.main.bounds
        Utils.scaleFactor = (x: screenSize.width / 375.0, y: screenSize.height / 667.0)
        
        self.view.backgroundColor = Resources.darkGray
        
        ninjaLogo.image = UIImage(named: "run-5")!.withRenderingMode(.alwaysTemplate)
        ninjaLogo.tintColor = Resources.cyan
        ninjaLogo.center = Utils.map(point: CGPoint(x: 220, y: 90))
        ninjaLogo.layer.zPosition = 0.0
        
        
        titleLabel.center = Utils.map(point: CGPoint(x: 187.5, y: 75))
        titleLabel.layer.zPosition = 1.0
        
        // tutorial label
        controlsLabel.center = Utils.map(point: CGPoint(x: 100, y: 557))
        controlsLabel.textColor = Resources.green
        controlsLabel.isUserInteractionEnabled = true
        let controlsTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.controlsLabelTap))
        controlsLabel.addGestureRecognizer(controlsTap)
        
        // tutorial label icon
        let controlsImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Utils.map(size: CGSize(width: 20, height: 20))))
        controlsImageView.image = controlsImage
        controlsImageView.tintColor = Resources.green
        controlsImageView.center = Utils.map(point: CGPoint(x: 55, y: 557))
        // controlsImageView.addGestureRecognizer(controlsTap)
        self.view.addSubview(controlsImageView)
        
        
        // exit label
        exitLabel.center = Utils.map(point: CGPoint(x: 275, y: 557))
        exitLabel.textColor = Resources.lightRed
        exitLabel.isUserInteractionEnabled = true
        let exitTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.exitLabelTap))
        exitLabel.addGestureRecognizer(exitTap)
        
        // exit label icon
        let exitImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Utils.map(size: CGSize(width: 20, height: 20))))
        exitImageView.image = exitImage
        exitImageView.tintColor = Resources.lightRed
        exitImageView.center = Utils.map(point: CGPoint(x: 305, y: 557))
        // exitImageView.addGestureRecognizer(exitTap)
        self.view.addSubview(exitImageView)
        
        

        
        creditsLabel1.center = Utils.map(point: CGPoint(x: 187.5, y: 607))
        
        
        



        loadLevelLabels()
        updateLabels()
        
    }
    
    
    /**
     when view appears
     **/
    override func viewDidAppear(_ animated: Bool) {
        loadData()
        updateLabels()
    }
    
    /**
     updates the highscore and locked status of labels
    **/
    func loadLevelLabels() {
        
        
        // positioning labels
        L1.center = Utils.map(point: CGPoint(x: 107.5, y: 175))
        L2.center = Utils.map(point: CGPoint(x: 267.5, y: 175))
        L3.center = Utils.map(point: CGPoint(x: 107.5, y: 275))
        L4.center = Utils.map(point: CGPoint(x: 267.5, y: 275))
        L5.center = Utils.map(point: CGPoint(x: 107.5, y: 375))
        L6.center = Utils.map(point: CGPoint(x: 267.5, y: 375))
        L7.center = Utils.map(point: CGPoint(x: 187.5, y: 475))
        
        
        levelLabels[0] = L1
        levelLabels[1] = L2
        levelLabels[2] = L3
        levelLabels[3] = L4
        levelLabels[4] = L5
        levelLabels[5] = L6
        levelLabels[6] = L7
        
        for i in 0...6 {
            
            let position = CGPoint(x: levelLabels[i].center.x, y: levelLabels[i].center.y)
            
            // adding tap gestures
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.levelLabelTap))
            levelLabels[i].isUserInteractionEnabled = true
            levelLabels[i].addGestureRecognizer(gestureRecognizer)
            
            
            // creating lock imageviews
            let lockPosition = CGPoint(x: position.x, y: position.y)
            let lockImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Utils.map(size: CGSize(width: 60, height: 60))))
            lockImageView.center = lockPosition
            lockImageView.alpha = 0.2
            lockImageView.image = lockImage
            lockImageView.layer.zPosition = -1
            lockImageView.isHidden = true
            
            lockImageViews[i] = lockImageView
            self.view.addSubview(lockImageViews[i])
            
            
            // creating high-score label
            let scorePosition = CGPoint(x: position.x, y: position.y + 30*Utils.scaleFactor.y)
            let hsLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Utils.map(size: CGSize(width: 150, height: 30))))
            
            hsLabel.font = UIFont(name: "Futura", size: 12)
            hsLabel.textColor = UIColor.white
            hsLabel.text = "best: " + String(highScores[i])
            hsLabel.textAlignment = NSTextAlignment.center
            hsLabel.center = scorePosition
            
            scoreLabels[i] = hsLabel
            self.view.addSubview(scoreLabels[i])
        }

    
    }
    
    
    func updateLabels() {
        
        for i in 1...7 {
            
            scoreLabels[i-1].text = "best: " + String(highScores[i-1])
            
            // if level is locked
            if(i > lastLevel) {
                lockImageViews[i-1].isHidden = false
            }
        }

    }
    
    /**
     loading NSDefaults into run-time memory
     **/
    func loadData() {
        
        // retrieving highest locked level
        if let lastLevel = Utils.userDefaults.value(forKey: "lastLevel") {
            self.lastLevel = lastLevel as! Int
        }
        
        // retrieving high scores
        for i in 1...7 {
            let scoreKey = "L"+String(i)
            let highScore = Utils.userDefaults.value(forKey: scoreKey) as? Int
            if (highScore != nil) {
                highScores[i-1] = highScore!
            }
        }
    }
    
    
    /**
     on tapping of a level label
    **/
    func levelLabelTap(sender: UITapGestureRecognizer) {
        
        
        let tapLocation = sender.location(in: view)

        for i in 1...7 {
        
            // if level label is tapped and it is not locked, transition to game scene
            if (levelLabels[i-1].frame.contains(tapLocation) && i <= lastLevel) {
        
                let gameStoryboard = UIStoryboard(name: "Game", bundle: nil)
                let gameVC = gameStoryboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
                gameVC.level = i
                self.view?.window?.rootViewController = gameVC
        
            }
        }
        



    }
    
    
    /**
     on tapping of controls label
     **/
    func controlsLabelTap(sender: UITapGestureRecognizer) {
        
        let gameStoryboard = UIStoryboard(name: "Game", bundle: nil)
        let gameVC = gameStoryboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameVC.level = 0
        self.view?.window?.rootViewController = gameVC
        
        
    }
    
    
    /**
     on tapping of exit label
     **/
    func exitLabelTap(sender: UITapGestureRecognizer) {
        exit(0)
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
        // Dispose of any resources that can be recreated.
    }


}

