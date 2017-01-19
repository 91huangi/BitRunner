//
//  Player.swift
//
//  Created by Ivan Huang on 12/8/16.
//  Copyright © 2016 Ivan Huang. All rights reserved.
//

import Foundation
import SpriteKit

class Player {
    

    // contacts
    var touchGround: Int
    var touchLeftWall: Int
    var touchRightWall: Int
    var objectContact: UInt32
    
    
    weak var body: SKSpriteNode?
    var active: Bool
    var animationFrames: [SKTexture]
    var frameSplits: [Int]
    var frameIndex: Double
    
    
    enum States:Int {
        case idle = 0
        case running = 1
        case stopping = 2
        case jumping = 3
        case falling = 4
        case gripping = 5
    }
    
    var state: States
    var direction: Double
    
    init() {
        active = false
        
        body = SKSpriteNode()
        state = .falling
        
        touchGround = 0
        touchLeftWall = 0
        touchRightWall = 0
        objectContact = Level.objectType.none.rawValue
        
        

        direction = 1.0
        animationFrames = [SKTexture]()
        frameSplits = [Int]()
        frameIndex = 0.0
    }
    
    
    func animate() {
        
        if let body = self.body {
            // var frames = [SKTexture]()
            
            if(state == .running) {
                // frames = Array(animationFrames[frameSplits[1]..<frameSplits[2]])
                // frames.append(animationFrames[frameSplits[state.hashValue]])
                
                frameIndex = max(frameIndex, Double(frameSplits[1]))
                frameIndex += 0.2
                
                if (frameIndex >= Double(frameSplits[2])) {
                    frameIndex = Double(frameSplits[1])
                }
                
                
            } else {                
                frameIndex = Double(frameSplits[state.hashValue])
            }
            
            
        }

    }
    

    
    func updateState(touch: GameScene.ScreenTouch) {
        
        if let body = self.body {
            
            
            // converting the ninja contact counts to booleans
            let touchGround = Bool(self.touchGround > 0)
            let touchLeftWall = Bool(self.touchLeftWall > 0)
            let touchRightWall = Bool(self.touchRightWall > 0)
            
            
            var newState = state
            var newDirection = direction
            var newImpulse = CGVector(dx: 0, dy: 0)
            
            
            
            let touchDirection = Double(touch.location.x / abs(touch.location.x))
            let jumpPower = 600.0
            
            
            repeat {
                
                // on ground
                if (state == .idle || state == .running || state == .stopping) {
                    
                    // if touching pusher, jump regardless of taps
                    if (objectContact == Level.objectType.pusher.rawValue) {
                        newState = .jumping
                        body.physicsBody!.velocity.dy = GameScene.pusherSpeed
                        break
                    }
                    
                    // on tap, jump
                    if(touch.short) {
                        newImpulse = CGVector(dx: 0, dy: jumpPower)
                        newState = .jumping
                        break
                    }
                    // on long touch, run or grip
                    else if(touch.long) {
                        if(touchGround == true) {
                            
                            // if not running into a wall, set to running
                            if (!(touchDirection == -1 && touchRightWall) && !(touchDirection == 1 && touchLeftWall)) {
                                newDirection = touchDirection
                                newState = .running
                                break
                            }
                            
                        } else if (touchLeftWall) {
                            newDirection = 1
                            newState = .gripping
                            break
                        } else if (touchRightWall) {
                            newDirection = -1
                            newState = .gripping
                            break
                        }
                    }
                    // if no touches, but still moving laterally and on ground, default to stopping
                    else if ((abs(body.physicsBody!.velocity.dx) > 5) && touchGround) {
                        newState = .stopping
                        break
                    }
                    
                    
                    // running into a wall, go to idle state
                    if (state == .running) {
                        if (direction == -1 && touchRightWall) {
                            newState = .idle
                            break
                        } else if (direction == 1 && touchLeftWall) {
                            newState = .idle
                            break
                        }
                    }
                    
                    // if falling, set to falling
                    if (body.physicsBody!.velocity.dy < -0.25) {
                        newState = .falling
                        break
                    }
                    
                    // stopping to idle
                    if (state == .stopping) {
                        if(abs(body.physicsBody!.velocity.dx) < 5) {
                            body.physicsBody!.velocity.dx = 0
                            newState = .idle
                            break
                        }
                    }
                }
                
                
                // in air
                if (state == .jumping || state == .falling) {
                    
                    
                    // if falling, then tap push off wall
                    if (touch.short && state == .falling) {
                        
                        if(touchLeftWall == true) {
                            newDirection = -1
                            newImpulse = CGVector(dx: -CGFloat(0.33 * jumpPower), dy: CGFloat(jumpPower * 0.9))
                            newState = .jumping
                            break
                        } else if (touchRightWall == true) {
                            newDirection = 1
                            newImpulse = CGVector(dx: CGFloat(0.33 * jumpPower), dy: CGFloat(jumpPower * 0.9))
                            newState = .jumping
                            break
                        }
                    }
                    
                    // on long touch and not touching ground
                    if (touch.long && !touchGround) {
                        
                        // if facing wall
                        if (touchLeftWall && direction == 1) {
                            newState = .gripping
                            break
                        } else if (touchRightWall && direction == -1) {
                            newState = .gripping
                            break
                        }
                    }
                    
                    
                    // if falling ...
                    if (state == .falling) {
                        
                        // ... and hits ground
                        if (touchGround) {
                            newState = .idle
                            break
                        }
                            // ... and immediate jump
                        else if (body.physicsBody!.velocity.dy > 0.25) {
                            newState = .jumping
                            break
                        }
                    }
                        // if moving downwards set to falling
                    else if (body.physicsBody!.velocity.dy < -0.25) {
                        newState = .falling
                        break
                    }
                }
                
                
                // gripping state
                if (state == .gripping) {
                    
                    // slips onto ground
                    if (touchGround) {
                        newState = .idle
                        break
                    }
                    
                    // ensuring facing the right way
                    if (touchLeftWall) {
                        newDirection = 1
                    } else if (touchRightWall) {
                        newDirection = -1
                    }
                    // if slips off wall
                    else {
                        newState = .falling
                        break
                    }
                    
                    
                    // on tap push off wall
                    if (touch.short) {
                        if(touchLeftWall == true) {
                            newDirection = -1
                            newImpulse = CGVector(dx: -CGFloat(0.33 * jumpPower), dy: CGFloat(jumpPower * 0.9))
                        } else if (touchRightWall == true) {
                            newDirection = 1
                            newImpulse = CGVector(dx: CGFloat(0.3 * jumpPower), dy: CGFloat(jumpPower * 0.9))
                            
                            
                        }
                        
                        newState = .jumping
                        break
                    }
                    
                    
                    // if touches are released
                    if(!touch.short && !touch.long) {
                        newState = .falling
                        break
                    }
                }
                
                
                break
                
            } while (true)
            
            
            
            
            
            // if state is new
            if(state != newState || direction != newDirection) {
                
                state = newState
                direction = newDirection
                body.physicsBody!.applyImpulse(newImpulse)
            }
        }
        

        
    }
    
    
    func move(touch: GameScene.ScreenTouch)  {
        
        if let body = self.body, active {
            
            let maxVelocity = 350.0
            let touchGround = Bool(self.touchGround > 0)
            
            
            // if gripping then slide
            if(state == .gripping) {
                body.physicsBody!.velocity = CGVector(dx: 0, dy: -50)
            }
            
            // if running or jumping, then move horizontally
            if(state == .running || state == .falling || state == .jumping) {
                
                if(touch.long) {
                    
                    if(Double(body.physicsBody!.velocity.dx) < maxVelocity && direction == 1) {
                        body.physicsBody!.applyImpulse(CGVector(dx: 10, dy: 0))
                    } else if (Double(body.physicsBody!.velocity.dx) > -maxVelocity && direction == -1) {
                        body.physicsBody!.applyImpulse(CGVector(dx: -10, dy: 0))
                    }
                }
            }
            
            // if stopping, slow down
            if(state == .stopping) {
                body.physicsBody!.velocity.dx = 0.9*body.physicsBody!.velocity.dx
            }
            
            // if free fall then apply gravity
            if(!touchGround && state != .gripping) {
                body.physicsBody!.applyImpulse(CGVector(dx: 0, dy: GameScene.gravity))
            }
        }
        

        
    }
    
    
    func toString() -> String {
        var pString = ""
        // pString = "dir: " + String(describing: direction) + " | "
        
        
        pString += "g/l/r: "+String(touchGround) + "/"+String(touchLeftWall) + "/"+String(touchRightWall) + " | "
        
        pString += "state: " + String(describing: state)

        
        return pString
    }
        
}
