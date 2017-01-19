//
//  Resources.swift
//  test2
//
//  Created by Ivan Huang on 1/2/17.
//  Copyright © 2017 Ivan Huang. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation


class Resources {
    
    // singletons
    static var texturesLoaded = false
    static var musicLoaded = false
    
    // animation textures
    static var playerFrames = [SKTexture]()
    static var missileFrames = [SKTexture]()
    static var pusherFrames = [SKTexture]()
    static var keyFrames = [SKTexture]()
    
    // frame indices
    static var playerFrameSplits = [Int]()
    
    
    
    // music
    static var themeMusic: AVAudioPlayer!

    
    // color scheme
    static let white = UIColor.white
    static let black = UIColor.black
    static let green = UIColor.green
    static let charcoal = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0)
    static let orange = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
    static let cyan = UIColor(red: 0, green: 0.6, blue: 1.0, alpha: 1.0)
    static let yellow = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    static let lightRed = UIColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
    static let darkGray = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    static let darkRed = UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0)
    static let darkGreen = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
    static let darkBlue = UIColor(red: 0.0, green: 0.0, blue: 0.6, alpha: 1.0)
    static let darkRedGreen = UIColor(red: 0.3, green: 0.3, blue: 0.0, alpha: 1.0)
    static let darkGreenBlue = UIColor(red: 0.0, green: 0.3, blue: 0.3, alpha: 1.0)
    static let darkBlueRed = UIColor(red: 0.3, green: 0.0, blue: 0.3, alpha: 1.0)
    
    
    /**
     loads animations into bank
    **/
    static func loadAnimations() {
        
        if(!texturesLoaded) {
            texturesLoaded = true
            
            // player animations
            playerFrames.append(SKTextureAtlas(named: "player").textureNamed("idle-1"))
            for i in 1...7 {
                let playerTextureName = "run-"+String(i)
                playerFrames.append(SKTextureAtlas(named: "player").textureNamed(playerTextureName))
            }
            playerFrames.append(SKTextureAtlas(named: "player").textureNamed("stop-1"))
            playerFrames.append(SKTextureAtlas(named: "player").textureNamed("jump-1"))
            playerFrames.append(SKTextureAtlas(named: "player").textureNamed("fall-1"))
            playerFrames.append(SKTextureAtlas(named: "player").textureNamed("grip-1"))
            playerFrameSplits = [0, 1, 8, 9, 10, 11]
            
            
            
            // missile animations
            for i in 1...6 {
                let missileTextureName = "missile-"+String(i)
                missileFrames.append(SKTextureAtlas(named: "objects").textureNamed(missileTextureName))
            }
            
            
            // pusher animations
            for i in 1...6 {
                let pusherTextureName = "push-"+String(i)
                pusherFrames.append(SKTextureAtlas(named: "objects").textureNamed(pusherTextureName))
            }
            
            // key animations
            for i in 1...16 {
                let keyTexture = "key-"+String(i)
                keyFrames.append(SKTextureAtlas(named: "objects").textureNamed(keyTexture))
            }
        }
        
    }
    
    
    /**
        loads music
    **/
    static func loadMusic() {
        
        if(!musicLoaded) {
            do {
                let themeSongURL = Bundle.main.path(forResource: "theme", ofType: "mp3")
                let themeSong = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: themeSongURL!))
                themeSong.numberOfLoops = -1
                themeMusic = themeSong
                themeSong.play()
                musicLoaded = true
            } catch {
                print("theme music not found")
            }
        }

        
    }
    
}
