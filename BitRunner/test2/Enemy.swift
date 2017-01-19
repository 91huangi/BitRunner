//
//  Enemy.swift
//
//  Created by Ivan Huang on 12/15/16.
//  Copyright © 2016 Ivan Huang. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy {
    
    // default attributes for enemies
    static let types = [EnemyType.turret, EnemyType.launcher, EnemyType.drone, EnemyType.scanner]
    static let sizes = [CGSize(width: 70, height: 42), CGSize(width: 70, height: 34), CGSize(width: 60, height: 60), CGSize(width: 1, height: 1)]
    static let reloadTimes = [50, 50, 3, 0]
    static let clipSizes = [10, 1, 5, 0]
    static let angularSpeeds = [0.0628, 0.0314, 0.0628, 0.0]
    static let visualAngles = [2*M_PI, 2*M_PI, 0.67*M_PI, 0.0]
    static let speeds = [0, 0, 250.0, 300.0]
    static let imageNames = ["turret-idle-1", "launcher-idle-1", "drone-idle-1", "scanner-idle-1"]
    static let colors = [Resources.white, Resources.white, Resources.white, Resources.orange]
    static let isPinned =  [true, true, false, false]
    static let isRotatable = [true, true, false, false]

    
    enum EnemyType:Int {
        case turret = 0
        case launcher = 1
        case drone = 2
        case scanner = 3
    }
    
    enum States:Int {
        case idle = 0
        case active = 1
        case firing = 2
    }
    

    
    var state: States
    var type: EnemyType
    var ammo: Int
    var reloadTimer: Int
    weak var body: SKSpriteNode?
    var speed: Double
    var angSpeed: Double
    var angle: Double
    var rotateTo: Double?
    var visualAngle: Double
    var seesPlayer: Bool
    var scannerBounds: CGRect
    
    
    init() {
        body = SKSpriteNode()
        scannerBounds = CGRect()

        speed = 0
        angSpeed = 0
        angle = 0
        reloadTimer = 0
        visualAngle = 2*M_PI
        state = .idle
        type = .turret
        ammo = 1
        seesPlayer = false
    }
    
    
    
    /**
     updates enemy line of sight... returns true of the player is visible
    **/
    func updateSeesPlayer(player: Player) {
        
        // if enemy exists and player exists
        if let body = self.body, let pBody = player.body {
            
            let playerX = pBody.position.x
            let playerY = pBody.position.y
                
            let dy = Double(playerY - body.position.y)
            let dx = Double(playerX - body.position.x)
            let targetAngle = Utils.normalizeAngle(angle: atan2(Double(dy), Double(dx)))
            let minArcDistance = Utils.arcDistance(angle1: targetAngle, angle2: angle)
                
            // if player is within a certain visual angle check LOS
            if (minArcDistance <= 0.5*visualAngle) {
                    
                let rayStart = body.position
                let rayEnd = (player.body?.position)!
                    
                seesPlayer = true
                    
                body.parent?.scene.self?.physicsWorld.enumerateBodies(alongRayStart: rayStart, end:rayEnd) {
                    body, point, normal, stop in
                    if body.categoryBitMask >= Level.objectType.leftWall.rawValue {
                        self.seesPlayer = false
                        return
                    }
                }
                    
            }
            // otherwise check if player is touching enemy
            else if (abs(dy) < 30 && abs(dx) < 30) {
                seesPlayer = true
            }
            // otherwise enemy does not see player
            else {
                seesPlayer = false
            }
                
            seesPlayer = seesPlayer && player.active
        } else {
            seesPlayer = false
        }
        

        
    }
    
    
    /**
     casts a series of line segments in front of the enemy to detect if a wall is in front of it
     **/
    func isBlockedAt(angle: Double) -> Bool {
        
        var isBlocked = false
        
        // only applicable to drones
        if let body = self.body, type == .drone {
            let hRadius = 0.5*body.size.height
            let dist = Double(15.0 + 0.5*body.size.width)
            
            let ray1Start = CGPoint(x: body.position.x - 1.1*hRadius*CGFloat(sin(angle)), y: body.position.y + 1.1*hRadius*CGFloat(cos(angle)))
            let ray1End = CGPoint(x: ray1Start.x + CGFloat(dist*cos(angle)),
                                  y: ray1Start.y + CGFloat(dist*sin(angle)))
            
            
            body.parent?.scene.self?.physicsWorld.enumerateBodies(alongRayStart: ray1Start, end: ray1End) {
                body, point, normal, stop in
                if body.categoryBitMask >= Level.objectType.blockWall.rawValue {
                    isBlocked = true
                    return
                }
            }
            
            
            let ray2Start = CGPoint(x: body.position.x + 1.1*hRadius*CGFloat(sin(angle)), y: body.position.y - 1.1*hRadius*CGFloat(cos(angle)))
            let ray2End = CGPoint(x: ray2Start.x + CGFloat(dist*cos(angle)),
                                  y: ray2Start.y + CGFloat(dist*sin(angle)))
            body.parent?.scene.self?.physicsWorld.enumerateBodies(alongRayStart: ray2Start, end: ray2End) {
                body, point, normal, stop in
                if body.categoryBitMask == Level.objectType.blockWall.rawValue {
                    isBlocked = true
                    return
                }
            }

        }

        
        return isBlocked
    }
    
    
    func updateState() {
        
        var newState = state
        
        // if the player is not visible
        if (!seesPlayer) {
            newState = .idle
        } else {
            switch(state) {
            case .idle:
                if (seesPlayer) {
                    newState = .active
                }
                break
            case .active:
                
                reloadTimer += 1
                
                let loaded = Bool(reloadTimer >= Enemy.reloadTimes[type.rawValue])
                
                if ((ammo >= 1) && loaded) {
                    newState = .firing
                    reloadTimer = 0
                    ammo -= 1
                }
                
                break
            case .firing:
                newState = .active
                break
            }
            
        }
        
        // if active --> idle || idle --> active
        if (type == .drone) {
            if (newState == .idle && state != .idle) {
                body!.run(SKAction.colorize(with: Enemy.colors[2], colorBlendFactor: 1.0, duration: 0.2))
                rotateTo = angle
            } else if (newState != .idle && state == .idle) {
                body!.run(SKAction.colorize(with: Resources.orange, colorBlendFactor: 1.0, duration: 0.05))
            }
        }
        
        // updating to new state
        if (newState != state) {
            state = newState
        }
        
    }
    
    
    func move() {
        
        if let body = self.body {
            var moveSpeed = speed
            
            // for drone
            if (type == .drone) {
                
                // chasing player
                if (state != .idle) {
                    moveSpeed = 1.5*speed
                }
                
                
                // if enemy is blocked and is not already turning, turn to first available angle (if not right then left... then 180)
                if(isBlockedAt(angle: angle) && abs(rotateTo! - angle) < 0.005) {
                    let angleRight = Utils.nearest90(angle: Utils.normalizeAngle(angle: (angle - M_PI_2)))
                    let angleLeft = Utils.nearest90(angle: Utils.normalizeAngle(angle: (angle + M_PI_2)))
                    let angleReverse = Utils.nearest90(angle: Utils.normalizeAngle(angle: (angle + M_PI)))
                    
                    if (!isBlockedAt(angle: angleRight)) {
                        rotateTo = angleRight
                    } else if (!isBlockedAt(angle: angleLeft)) {
                        rotateTo = angleLeft
                    } else {
                        rotateTo = angleReverse
                    }
                }
                
                // if turning
                if (abs(rotateTo! - angle) > 0.005) {
                    angle = Utils.slowRotate(targetAngle: rotateTo!, startAngle: angle, speed: angSpeed)
                    moveSpeed = 0
                }
            }
                
            // for scanner
            else if (type == .scanner) {
                
                let scene = body.parent
                let scannerPos = body.position
                
                // going right
                if (cos(angle) > 0.25) {
                    
                    // reset scanner
                    if (body.position.x + 0.5*body.size.width >= scannerBounds.maxX) {
                        
                        body.removeFromParent()
                        body.position = CGPoint(x: scannerBounds.minX - 0.5*body.size.width, y: scannerPos.y)
                        
                        scene?.addChild(body)
                    }
                } else if (cos(angle) < -0.25) {     // going left
                    
                    // reset scanner
                    if (body.position.x - 0.5*body.size.width <= scannerBounds.minX) {
                        
                        body.removeFromParent()
                        body.position = CGPoint(x: scannerBounds.maxX + 0.5*body.size.width, y: scannerPos.y)
                        
                        scene?.addChild(body)
                    }
                } else if (sin(angle) > 0.25) {      // going up
                    
                    // reset scanner
                    if (body.position.y + 0.5*body.size.width >= scannerBounds.maxY) {
                        
                        body.removeFromParent()
                        body.position = CGPoint(x: scannerPos.x, y: scannerBounds.minY - 0.5*body.size.width)
                        
                        scene?.addChild(body)
                    }
                    
                } else if (sin(angle) < -0.25) {     // going down
                    // reset scanner
                    if (body.position.y - 0.5*body.size.width <= scannerBounds.minY) {
                        
                        body.removeFromParent()
                        body.position = CGPoint(x: scannerPos.x, y: scannerBounds.maxY + 0.5*body.size.width)
                        
                        scene?.addChild(body)
                    }
                    
                }
            }

            
            // movement
            body.run(SKAction.rotate(toAngle: CGFloat(angle), duration: 0.0, shortestUnitArc: true))
            body.physicsBody!.velocity = CGVector(dx: CGFloat(cos(angle)*moveSpeed), dy: CGFloat(sin(angle)*moveSpeed))
            

        }
        

    }
    
    

    
    /**
     returns a new angle for the enemy
    **/
    func aim(to: CGPoint) {
        
        if let body = self.body {
            // allow rotations for turret, launcher, and drone
            if (type != .scanner) {
                let dy = Double(to.y-body.position.y)
                let dx = Double(to.x-body.position.x)
                let targetAngle = Double(atan2(dy, dx))
                
                angle = Utils.slowRotate(targetAngle: targetAngle, startAngle: angle, speed: angSpeed)
                
                if (type == .drone) {
                    rotateTo = angle
                }
            }
        }
        

    }
    
    
    func toString() -> String {
        var eString = ""
        let dispAngle1 = 0.01*round(rotateTo!*100)
        let dispAngle2 = 0.01*round(angle*100)
        // eString = eString + "sees: " + String(seesPlayer) + " | "
        // eString = eString + "state: " + String(describing: state) + " | "
        // eString = eString + "loaded: " + String(readyToFire) + " | "
        // eString = eString + "angle: " + String(dispAngle) + " | "
        // eString = eString + String(describing: body.position.x) + ", " + String(describing: body.position.y)
        eString = String(dispAngle1) + " | " + String(dispAngle2)
        return eString
    }
    
}
