//
//  Projectile.swift
//
//  Created by Ivan Huang on 12/13/16.
//  Copyright © 2016 Ivan Huang. All rights reserved.
//

import Foundation
import SpriteKit

class Projectile {
    
    weak var body: SKSpriteNode?
    var speed: Double
    var angle: Double
    var parent: Enemy
    var active: Bool
    

    
    
    init() {
        body = SKSpriteNode()
        speed = 0
        angle = 0
        parent = Enemy()
        active = false
    }
    
    
    func move() {
        
        if let body = self.body {
            // setting angle
            body.run(SKAction.rotate(toAngle: CGFloat(angle), duration: 0.0, shortestUnitArc: true))
            
            // moving
            body.physicsBody!.velocity = CGVector(dx: speed*cos(Double(angle)), dy: speed*sin(Double(angle)))
        }

    }
    

    
    
    func toString() -> String {
        var pString = ""
        
        let printAngle = round(Double(angle*180/M_PI))
        
        return pString
    }
    
    
}
