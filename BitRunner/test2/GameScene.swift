//
//  GameScene.swift
//
//  Created by Ivan Huang on 12/7/16.
//  Copyright © 2016 Ivan Huang. All rights reserved.
//

import SpriteKit
import GameplayKit
import Darwin

protocol GameSceneDelegate: class {
    func levelEnded()
}


class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameSceneDelegate: GameSceneDelegate?
    
    class ScreenTouch {
        var short = false
        var long = false
        var location = CGPoint()
    }
    
    
    // label nodes
    var menuLabel = SKLabelNode()
    var finishLabel = SKLabelNode()
    var headingLabel = SKLabelNode()
    var levelCompleteShape = SKShapeNode()
    var scoreLabel = SKLabelNode()
    var timeLabel = SKLabelNode()
    var doorLabel = SKLabelNode()

    // level nodes
    var player = Player()
    var key = SKSpriteNode()
    var door = SKSpriteNode()
    var enemies = [Enemy]()
    var projectiles = [Projectile]()
    
    var playerTrail = [SKSpriteNode](repeating: SKSpriteNode(), count: 6)
    var playerTrailIndex = 0
    
    
    
    // level variables
    var sceneLevel = Level()
    var level = -1
    var unlocked = false
    var newHighScore = false
    static var gravity:CGFloat = 0.0
    static var pusherSpeed:CGFloat = 0.0
    
    
    // screen touch variables
    var touch = ScreenTouch()
    var touchTimers = [UITouch:Int]()
    var touchLocations = [UITouch: CGPoint]()
    var touchStack = [UITouch]()
    static let tapTime = 7
    
    // scene variables
    let sceneColors = [Resources.darkRed, Resources.darkBlueRed, Resources.darkBlue, Resources.darkBlueRed]
    var colorIndex = 0
    
    

    
    override func didMove(to view: SKView) {
        
        colorIndex = Int(arc4random_uniform(UInt32(sceneColors.count)))
        
        self.physicsWorld.contactDelegate = self
        self.scene?.backgroundColor = sceneColors[colorIndex]
        
        // loading level objects
        sceneLevel.level = self.level
        sceneLevel.load()
        loadWalls(walls: sceneLevel.walls)
        loadPlayer(location: sceneLevel.startLocation)        
        loadObjects(objects: sceneLevel.objects)
        loadEnemies(enemies: sceneLevel.enemies)
        
        // altering physics
        GameScene.gravity = CGFloat(-15.0) * sceneLevel.gravityMultiplier
        GameScene.pusherSpeed = CGFloat(1000.0) * sceneLevel.pusherMultiplier
        
        
        // loading labels
        levelCompleteShape = self.childNode(withName: "levelCompleteShape") as! SKShapeNode
        
        menuLabel = self.childNode(withName: "menuLabel") as! SKLabelNode
        finishLabel = self.childNode(withName: "finishLabel") as! SKLabelNode
        
        headingLabel = self.childNode(withName: "headingLabel") as! SKLabelNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        timeLabel = self.childNode(withName: "timeLabel") as! SKLabelNode
        
        headingLabel.text = "LEVEL " + String(self.level)
        
        
        
        // training level
        if (sceneLevel.level == 0) {
            
            
            var headerTexts = [String]()
            headerTexts.append("- to move -")
            headerTexts.append(" - to jump -")
            headerTexts.append(" - to grip a wall -")
            headerTexts.append(" - to push off a wall -")
            
            var instructionTexts = [String]()
            instructionTexts.append("hold the screen in the desired direction")
            instructionTexts.append("tap the screen while standing or moving")
            instructionTexts.append("hold the screen while airborne and near a wall")
            instructionTexts.append("tap the screen while near a wall")
            
            for i in 0..<headerTexts.count {
                let headerLabel = SKLabelNode(fontNamed: "Futura")
                headerLabel.position = CGPoint(x: 0, y: 667 - 500 - CGFloat(150*i))
                headerLabel.text = headerTexts[i]
                self.addChild(headerLabel)
                
                let instructionLabel = SKLabelNode(fontNamed: "Futura")
                instructionLabel.position = CGPoint(x: 0, y: 667 - 550 - CGFloat(150*i))
                instructionLabel.text = instructionTexts[i]
                self.addChild(instructionLabel)
            }
            
            // re-positioning menu label
            menuLabel.position = CGPoint(x: 0, y: -500)
            menuLabel.fontColor = UIColor.white
        }
        
    }
    
    
    /**
     loading the player
     **/
    func loadPlayer(location: (CGPoint, Double)) {
        
        let n = SKSpriteNode()
        
        // using elliptical path to avoid corner problems
        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: -10, y: -25, width: 20, height: 50), cornerWidth: 4, cornerHeight: 4)
        path.closeSubpath()
        n.physicsBody = SKPhysicsBody(polygonFrom: path)
        n.physicsBody!.mass = CGFloat(1.0)
        n.position = location.0
        
        n.physicsBody!.isDynamic = true
        n.physicsBody!.pinned = false
        n.physicsBody!.allowsRotation = false
        n.physicsBody!.affectedByGravity = false
        n.physicsBody!.restitution = 0
        n.physicsBody!.linearDamping = 0
        
        
        n.physicsBody!.categoryBitMask = Level.objectType.player.rawValue
        n.physicsBody!.contactTestBitMask = Level.objectType.projectile.rawValue | Level.objectType.enemy.rawValue | Level.objectType.leftWall.rawValue | Level.objectType.rightWall.rawValue | Level.objectType.bottomWall.rawValue | Level.objectType.topWall.rawValue | Level.objectType.blockWall.rawValue
        n.physicsBody!.collisionBitMask = Level.objectType.blockWall.rawValue
        
        n.isHidden = true
        n.zPosition = 2
        n.size = CGSize(width: 50, height: 50)
        
        
        player.body = n
        player.active = true
        player.direction = location.1
        player.animationFrames = Resources.playerFrames
        player.frameSplits = Resources.playerFrameSplits
        player.animate()
        self.addChild(player.body!)
    }
    
    
    /**
     loading the level objects: keys, doors, pushers, gold
     **/
    func loadObjects(objects: [(CGPoint, UInt32)]) {
    
        let bitMask = Level.objectType.player.rawValue
        var objectFrames = [SKTexture]()
        
        // for each wall in array
        for object in objects {
            
            var o = SKSpriteNode()
            
            if (object.1 == Level.objectType.key.rawValue) {
                
                o.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 17, height: 51))
                o.physicsBody!.categoryBitMask = Level.objectType.key.rawValue
                o.physicsBody!.collisionBitMask = Level.objectType.key.rawValue
                
                o.size = CGSize(width: 17, height: 51)

                
                // setting animation
                objectFrames = Resources.keyFrames
                o.run(SKAction.repeatForever(
                    SKAction.animate(with: objectFrames,
                                     timePerFrame: 0.1,
                                     resize: false,
                                     restore: true)),
                         withKey:"keyAnimation")
                
                // setting color
                o.run(SKAction.colorize(with: Resources.cyan, colorBlendFactor: 1.0, duration: 0.0))
                
                // setting angle
                o.run(SKAction.rotate(toAngle: CGFloat(-1.88*M_PI), duration: 0.0))
                key = o
                
            } else if (object.1 == Level.objectType.door.rawValue) {

                o.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 70))
                o.physicsBody!.categoryBitMask = Level.objectType.door.rawValue
                o.physicsBody!.collisionBitMask = Level.objectType.door.rawValue
                
                o.color = Resources.white
                o.size = CGSize(width: 50, height: 70)
                o.alpha = 0.0       // door is locked
                
                
                doorLabel = SKLabelNode(fontNamed: "Futura")
                doorLabel.fontColor = Resources.cyan
                doorLabel.text = "EXIT"
                doorLabel.fontSize = 15
                doorLabel.run(SKAction.fadeAlpha(to: 0, duration: 0.0))
                doorLabel.position = CGPoint(x: object.0.x, y: object.0.y + 40)
                
                self.addChild(doorLabel)
                
                self.door = o
                
            } else if (object.1 == Level.objectType.gold.rawValue) {
                
                let gold = SKShapeNode(circleOfRadius: 6.0)
                gold.lineWidth = 0.0
                gold.fillColor = Resources.white
                let goldTexture = view?.texture(from: gold)
                
                o = SKSpriteNode(texture: goldTexture)
                o.physicsBody = SKPhysicsBody(circleOfRadius: 6.0)
                
                o.physicsBody!.categoryBitMask = Level.objectType.gold.rawValue
                o.physicsBody!.collisionBitMask = Level.objectType.gold.rawValue
                
                
                // setting color
                o.run(SKAction.colorize(with: Resources.yellow, colorBlendFactor: 1.0, duration: 0.0))
                
                
            } else if (object.1 == Level.objectType.pusher.rawValue) {
                
                o.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 24, height: 50))
                
                o.physicsBody!.categoryBitMask = Level.objectType.pusher.rawValue
                o.physicsBody!.collisionBitMask = Level.objectType.pusher.rawValue
                
                o.size = CGSize(width: 24, height: 50)
                
                // setting color
                o.run(SKAction.colorize(with: Resources.green, colorBlendFactor: 1.0, duration: 0.0))
                
                
                objectFrames = Resources.pusherFrames
                o.run(SKAction.repeatForever(
                    SKAction.animate(with: objectFrames,
                                     timePerFrame: 0.1,
                                     resize: false,
                                     restore: true)),
                           withKey:"pusherAnimation")
            }

            
            o.physicsBody!.contactTestBitMask = bitMask

            // setting object movement properties
            o.physicsBody!.isDynamic = true
            o.physicsBody!.pinned = true
            o.physicsBody!.allowsRotation = false
            o.physicsBody!.affectedByGravity = false
            
            // setting object position
            o.position = object.0
            o.zPosition = -2
            
            self.addChild(o)

            
        }
    }
    
    
    
    /**
     loading the level walls
    **/
    func loadWalls(walls: [(CGPoint, CGPoint)]) {

        
        let contactBitMask = Level.objectType.player.rawValue | Level.objectType.enemy.rawValue | Level.objectType.projectile.rawValue
        let collisionBitMask = Level.objectType.player.rawValue | Level.objectType.debris.rawValue | Level.objectType.enemy.rawValue | Level.objectType.projectile.rawValue
        
        // for each wall in array
        for wall in walls {
            
            let borderWidth = CGFloat(1)
            
            
            let width = abs(wall.1.x - wall.0.x)
            let height = abs(wall.1.y - wall.0.y)
            let x = CGFloat(0.5*(wall.0.x+wall.1.x))
            let y = CGFloat(0.5*(wall.0.y+wall.1.y))
            
            
            var dims = [CGSize(width: width - 2, height: borderWidth), CGSize(width: borderWidth, height: height - 2), CGSize(width: borderWidth, height: height - 2), CGSize(width: width, height: borderWidth)]
            var pos = [CGPoint(x: x, y: wall.0.y), CGPoint(x: wall.0.x, y: y), CGPoint(x: wall.0.x + width, y: y), CGPoint(x: x, y: wall.1.y)]
            var masks = [Level.objectType.topWall.rawValue, Level.objectType.leftWall.rawValue, Level.objectType.rightWall.rawValue, Level.objectType.bottomWall.rawValue]
            
            // loading top border, the left border, then right border, then bottom border
            for i in 0...3 {
                let border = SKSpriteNode()
                
                border.position = pos[i]
                
                border.physicsBody = SKPhysicsBody(rectangleOf:dims[i])
                border.physicsBody!.isDynamic = true
                border.physicsBody!.pinned = true
                border.physicsBody!.affectedByGravity = false
                border.physicsBody!.restitution = 0

                border.physicsBody!.categoryBitMask = masks[i]
                border.physicsBody!.contactTestBitMask = Level.objectType.player.rawValue | Level.objectType.enemy.rawValue
                border.physicsBody!.collisionBitMask = 0
                border.size = dims[i]
                border.color = Resources.black
                self.addChild(border)
            }
            
            
            // adding wall block for collisions
            let w = SKSpriteNode()
            w.position = CGPoint(x: x, y: y)
            w.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
            w.physicsBody!.isDynamic = true
            w.physicsBody!.pinned = true
            w.physicsBody!.affectedByGravity = false
            w.physicsBody!.allowsRotation = false
            w.physicsBody!.restitution = 0
            w.physicsBody!.friction = 0
            w.physicsBody!.mass = 1000
            
            w.physicsBody!.categoryBitMask = Level.objectType.blockWall.rawValue
            w.physicsBody!.contactTestBitMask = contactBitMask
            w.physicsBody!.collisionBitMask = collisionBitMask
            w.size = CGSize(width: width, height: height)
            w.color = Resources.black
            
            self.addChild(w)
        }
    }
    
    /**
     loading the enemies
     **/
    func loadEnemies(enemies: [(CGPoint, Double, Int, CGRect)]) {
        
        var enemy = Enemy()
        var body = SKSpriteNode()
        var size = CGSize()
        
        for e in enemies {
            
            enemy = Enemy()
            
            // scanner has different size properties and optional bounds properties
            if (e.2 == Enemy.EnemyType.scanner.rawValue) {
                enemy.scannerBounds = e.3
                // scanner going left or right
                if (abs(cos(e.1)) > 0.25) {
                    size = CGSize(width: e.3.height / 2, height: e.3.height)
                }
                    // scanner going up or down
                else {
                    size = CGSize(width: e.3.width / 2, height: e.3.width)
                }
            } else {
                size = Enemy.sizes[e.2]
            }
                

            enemy.type = Enemy.types[e.2]
            enemy.ammo = Enemy.clipSizes[e.2]
            enemy.angSpeed = Enemy.angularSpeeds[e.2]
            enemy.visualAngle = Enemy.visualAngles[e.2]
            enemy.speed = Enemy.speeds[e.2]
                
            body = SKSpriteNode(imageNamed: Enemy.imageNames[e.2])
            body.physicsBody = SKPhysicsBody(rectangleOf: size)
            body.run(SKAction.colorize(with: Enemy.colors[e.2], colorBlendFactor: 1.0, duration: 0.0))
            body.physicsBody!.pinned = Enemy.isPinned[e.2]
            body.physicsBody!.allowsRotation = Enemy.isRotatable[e.2]
            body.physicsBody!.isDynamic = true
            body.physicsBody!.affectedByGravity = false
            body.physicsBody!.restitution = 0

            // setting bitmasks
            body.physicsBody!.categoryBitMask = Level.objectType.enemy.rawValue
            body.physicsBody!.contactTestBitMask = Level.objectType.player.rawValue | Level.objectType.blockWall.rawValue | Level.objectType.topWall.rawValue | Level.objectType.bottomWall.rawValue | Level.objectType.leftWall.rawValue | Level.objectType.rightWall.rawValue
            body.physicsBody!.collisionBitMask =  Level.objectType.blockWall.rawValue
            
            // setting start position
            enemy.angle = e.1
            
            if (enemy.type == .drone) {
                enemy.rotateTo = enemy.angle
            }
            
            body.position = e.0
            body.size = size
            body.zPosition = 1 + 0.1*CGFloat(e.2)
            body.run(SKAction.rotate(toAngle: CGFloat(enemy.angle), duration: 0.0, shortestUnitArc: true))
            
            // saving enemy object
            enemy.body = body
            
            // adding to scene
            self.addChild(body)
            self.enemies.append(enemy)
            
        }
    }


    /**
     loading the projectiles
     **/
    func loadProjectile(parent: Enemy) {
        let projectile = Projectile()
        var p = SKSpriteNode()
        var speed = 0.0
        
        switch(parent.type) {
            
        case .turret:
            p = SKSpriteNode()
            p.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 8, height:3))
            
            // setting new projectile location
            p.position = (parent.body?.position)!
            p.size = CGSize(width: 8, height: 3)
            p.color = Resources.white
            
            speed = 500.0
            
            break
        case .launcher:
            
            p = SKSpriteNode()
            p.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 45, height:6))
            
            // setting new projectile location
            p.position = (parent.body?.position)!
            p.size = CGSize(width: 45, height: 6)
            
            speed = 300.0

            
            p.run(SKAction.repeatForever(
                SKAction.animate(with: Resources.missileFrames,
                                 timePerFrame: 0.05,
                                 resize: false,
                                 restore: true)),
                     withKey:"projectileAnimation")

            
            
            break
        case .drone:
            
            p = SKSpriteNode()
            p.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 12, height:3))
            
            // setting new projectile location
            p.position = (parent.body?.position)!
            p.size = CGSize(width: 12, height: 3)
            p.color = Resources.orange
            
            
            speed = 700.0
            break
            
        default:
            break
        }
        
        
        // setting new projectile movement properties
        p.physicsBody!.isDynamic = true
        p.physicsBody!.pinned = false
        p.physicsBody!.affectedByGravity = false
        p.physicsBody!.allowsRotation = false
        p.zPosition = 0
        
        // setting new projectile bitmask
        p.physicsBody!.categoryBitMask = Level.objectType.projectile.rawValue
        p.physicsBody!.contactTestBitMask = Level.objectType.player.rawValue | Level.objectType.blockWall.rawValue
        p.physicsBody!.collisionBitMask = Level.objectType.blockWall.rawValue
        
        projectile.parent = parent
        projectile.angle = parent.angle
        projectile.speed = speed
        projectile.active = true

        p.run(SKAction.rotate(toAngle: CGFloat(projectile.angle), duration: 0.0))
        
        projectile.body = p
        projectiles.append(projectile)
        
        self.addChild(p)
    }
    



    /**
     called when user touches screen
    **/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            let location = t.location(in: self)
            
            
            // if return to menu label was selected
            if (Utils.distance(first: location, second: menuLabel.position) <= 100) {
                player.active = false
                gameSceneDelegate?.levelEnded()
            }
            
            // update touch location, timer, and stack
            touchLocations[t] = location
            touchTimers[t] = 0
            touchStack.append(t)

        }

    }
    

    /**
     called when user touches ends screen touch
     **/
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            // if tap short touch
            if(touchTimers[t]! < GameScene.tapTime) {
                touch.short = true
            }
            
            // delete touch timer and locations and remove from touchStack
            touchLocations[t] = nil
            touchTimers[t] = nil
            touchStack.remove(at: touchStack.index(of: t)!)
        }
        

    }
    
    
    /**
     for each screen touch, increment touch timer
     **/
    func updateTouches() {
        
        // if no touches...
        if (touchStack.count == 0) {
            touch.long = false
            touch.location = CGPoint(x: 0, y: 0)
        }
        
        // update touches in stack
        for t in touchStack {
            touchTimers[t] = touchTimers[t]! + 1
                
            // if touch time is long enough, store most recent long touch
            if (touchTimers[t]! > GameScene.tapTime) {
                touch.long = true
                touch.location = touchLocations[t]!
            }
        }
    
    }
    
    
    
    // detecting contacts
    func didBegin(_ contact: SKPhysicsContact) {
        let categoryMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        var nodeA: SKNode?
        var nodeB: SKNode?
        
        
        // nodeA will be player, then enemy, then projectile, then gold, then debris, then los
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            nodeA = contact.bodyA.node
            nodeB = contact.bodyB.node
        } else {
            nodeA = contact.bodyB.node
            nodeB = contact.bodyA.node
        }
        
    
        switch (categoryMask) {
        
            
        // player hits wall
        case Level.objectType.player.rawValue | Level.objectType.blockWall.rawValue:
            let force = contact.collisionImpulse
            let touchGround = Bool(player.touchGround > 0)
            let touchLeftWall = Bool(player.touchLeftWall > 0)
            let touchRightWall = Bool(player.touchRightWall > 0)
            
            var angle = M_PI_2
            
            if (!touchGround && touchLeftWall) {
                angle = M_PI
            } else if (!touchGround && touchRightWall) {
                angle = 0.0
            }
            
            if (force >= 1200) {
                kill(angle: angle)
            }
            return
        case Level.objectType.player.rawValue | Level.objectType.topWall.rawValue:
            player.touchGround += 1
            return
        case Level.objectType.player.rawValue | Level.objectType.leftWall.rawValue:
            player.touchLeftWall += 1
            return
        case Level.objectType.player.rawValue | Level.objectType.rightWall.rawValue:
            player.touchRightWall += 1
            return
            
        // player hits objects
        case Level.objectType.player.rawValue | Level.objectType.gold.rawValue:
            nodeB?.removeFromParent()
            sceneLevel.score += 100
            return
        case Level.objectType.player.rawValue | Level.objectType.pusher.rawValue:
            player.objectContact = Level.objectType.pusher.rawValue
            return
        case Level.objectType.player.rawValue | Level.objectType.key.rawValue:
            key.removeFromParent()
            door.run(SKAction.fadeAlpha(to: 1.0, duration: 3.0))
            doorLabel.run(SKAction.fadeAlpha(to: 1.0, duration: 3.0))
            sceneLevel.score += 500
            unlocked = true
            return
        case Level.objectType.player.rawValue | Level.objectType.door.rawValue:
            player.objectContact = Level.objectType.door.rawValue
            return
            
        // player hits projectiles
        case Level.objectType.player.rawValue | Level.objectType.projectile.rawValue:
            
            let proj = nearestProjectile(point: (nodeB?.position)!)
            
            if (levelCompleteShape.isHidden) {
                kill(angle: proj.angle)
                proj.active = false
            }
            
            return
            
        // player hits scanner
        case Level.objectType.player.rawValue | Level.objectType.enemy.rawValue:
            let enemy = nearestEnemy(point: (nodeB?.position)!)

            if (enemy.type == .scanner) {
                kill(angle: enemy.angle)
            }
            return
            
        // projectile hits walls
        case Level.objectType.projectile.rawValue | Level.objectType.blockWall.rawValue:
            let proj = nearestProjectile(point: (nodeA?.position)!)
            proj.active = false
            return

        default:
            return
        }
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        let categoryMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
        
        switch (categoryMask) {
            
        // player leaves walls
        case Level.objectType.player.rawValue | Level.objectType.topWall.rawValue:
            player.touchGround = max(player.touchGround - 1, 0)
            return
        case Level.objectType.player.rawValue | Level.objectType.leftWall.rawValue:
            player.touchLeftWall = max(player.touchLeftWall - 1, 0)
            return
        case Level.objectType.player.rawValue | Level.objectType.rightWall.rawValue:
            player.touchRightWall = max(player.touchRightWall - 1, 0)
            return
            
        // object contacts
        case Level.objectType.player.rawValue | Level.objectType.gold.rawValue:
            player.objectContact = Level.objectType.none.rawValue
            return
        case Level.objectType.player.rawValue | Level.objectType.pusher.rawValue:
            player.objectContact = Level.objectType.none.rawValue
            return
        case Level.objectType.player.rawValue | Level.objectType.door.rawValue:
            player.objectContact = Level.objectType.none.rawValue
            return
        
            
        default:
            return
        }
    }

    
    

    


    
    func updatePlayer() {

        if (player.active) {
            player.updateState(touch: touch)
            
            touch.short = false
            
            player.move(touch: touch)
            player.animate()
        }
        
        
        
        
        ///////// UPDATING MOTION TRAIL //////////
        playerTrail[playerTrailIndex].removeFromParent()
        
        // adding fading effects
        playerTrail[(playerTrailIndex + 1) % 6].alpha = 0.1
        playerTrail[(playerTrailIndex + 2) % 6].alpha = 0.25
        playerTrail[(playerTrailIndex + 3) % 6].alpha = 0.5
        playerTrail[(playerTrailIndex + 4) % 6].alpha = 0.95
        
        if let nBody = player.body {
            let n = SKSpriteNode(texture: Resources.playerFrames[Int(player.frameIndex)])
            n.size = CGSize(width: 50, height: 50)
            n.position = nBody.position
            n.run(SKAction.colorize(with: Resources.cyan, colorBlendFactor: 1.0, duration: 0.0))
            n.xScale = CGFloat(player.direction)
            self.addChild(n)
            playerTrail[(playerTrailIndex + 5) % 6] = n
        }



        
    }
    
    

    func updateEnemies() {
        

        for enemy in enemies {
            
            enemy.updateSeesPlayer(player: player)
            enemy.updateState()
            
            // if enemy is firing, load new projectile onto scene
            if(enemy.state == Enemy.States.firing) {
                loadProjectile(parent: enemy)
            }
            
            // if enemy is not idle, aim towards player
            if(enemy.state != Enemy.States.idle && player.active) {
                enemy.aim(to: (player.body?.position)!)
            }
            

            
            enemy.move()
            
        }
        


    }
    
    /**
     iterates through all projectiles in game scene
    **/
    func updateProjectiles() {
        var i = 0
        while( i < projectiles.count) {
            
            // if projectile is no longeractive
            if (!projectiles[i].active) {
                        
                // reloading enemy
                projectiles[i].parent.ammo += 1
                
                
                // remove from game scene
                projectiles[i].body!.removeFromParent()
                
                
                // remove from array
                projectiles.remove(at: i)
                
                
                
            } else {
                i += 1
            }

        }
        
        for i in 0..<projectiles.count {
            
            // setting homing capabilities for missiles
            if (player.active && projectiles[i].parent.type == .launcher) {
                let dy = (player.body?.position.y)! - (projectiles[i].body?.position.y)!
                let dx = (player.body?.position.x)! - (projectiles[i].body?.position.x)!
                let targetAngle = Double(atan2(dy, dx))
                projectiles[i].angle = Utils.slowRotate(targetAngle: targetAngle, startAngle: projectiles[i].angle, speed: 0.0314)
            }
            
            // moving projectiles
            projectiles[i].move()

        }
    }
    
    
    /**
     returns the nearest enemy to a point
    **/
    func nearestEnemy(point: CGPoint) -> Enemy {
        var minDist = 10000.0
        var dist = 0.0
        var nearestEnemy = Enemy()
        
        for enemy in enemies {
            dist = Utils.distance(first: (enemy.body?.position)!, second: point)
            if (dist <= minDist) {
                nearestEnemy = enemy
                minDist = dist
            }
        }
        
        return nearestEnemy
    }
    
    
    /**
     returns the nearest projectile to a point
     **/
    func nearestProjectile(point: CGPoint) -> Projectile {
        var minDist = 10000.0
        var dist = 0.0
        var nearestProjectile = Projectile()
        
        for projectile in projectiles {
            dist = Utils.distance(first: (projectile.body?.position)!, second: point)
            if (dist <= minDist) {
                nearestProjectile = projectile
                minDist = dist
            }
        }
        
        return nearestProjectile
    }
    

    
    /**
     unlocks the next level if levelComplete == true and saves the HS if applicable
    **/
    func saveData() {
        

        var lastLevel = Utils.userDefaults.value(forKey: "lastLevel") as? Int
            
        if ((lastLevel) != nil) {
            lastLevel = max(lastLevel!, sceneLevel.level + 1)
        } else {
            lastLevel = 2
        }
        
        Utils.userDefaults.set(lastLevel, forKey: "lastLevel")
            
        // saving high score
        let scoreKey = "L"+String(sceneLevel.level)
        let highScore = Utils.userDefaults.value(forKey: scoreKey) as? Int
            
        if (highScore != nil) {
            if (sceneLevel.score > highScore!) {
                Utils.userDefaults.set(sceneLevel.score, forKey: scoreKey)
                newHighScore = true
            }
        } else {
            Utils.userDefaults.set(sceneLevel.score, forKey: scoreKey)
            newHighScore = true
        }
    }
        

    
    /**
     if the level is complete, fade player out and call end of level functions
    **/
    func levelComplete() {
        
        sceneLevel.score += (sceneLevel.time / 6)
        saveData()
        
        if (newHighScore) {
            scoreLabel.text = "new hs: " + String(sceneLevel.score)
            scoreLabel.fontColor = Resources.cyan
        } else {
            scoreLabel.text = "score: " + String(sceneLevel.score)
        }
        
        
        
        
        
        // clearing motion trails
        playerTrail[playerTrailIndex].run(SKAction.fadeAlpha(to: 0, duration: 0.1))
        playerTrail[(playerTrailIndex + 1) % 6].run(SKAction.fadeAlpha(to: 0, duration: 0.2))
        playerTrail[(playerTrailIndex + 2) % 6].run(SKAction.fadeAlpha(to: 0, duration: 0.4))
        playerTrail[(playerTrailIndex + 3) % 6].run(SKAction.fadeAlpha(to: 0, duration: 0.6))
        playerTrail[(playerTrailIndex + 4) % 6].run(SKAction.fadeAlpha(to: 0, duration: 0.8))
        playerTrail[(playerTrailIndex + 5) % 6].run(SKAction.fadeAlpha(to: 0, duration: 1.6))
        
        
        
        player.body?.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        player.active = false
        
        finishLabel.text = "LEVEL " + String(sceneLevel.level) + " Complete!"
        
        
        
        showAllLabels()
        
    }
    
    /**
     if player is killed or time runs out, remove player from scene, add blood animations, and call end of level functions
    **/
    func kill(angle: Double) {
        
        if (player.active) {
            
            for i in 1...20 {
                let randAngle = angle+0.003*(-157.0+Double(arc4random_uniform(314)))
                let pixel = SKSpriteNode()
                
                pixel.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: 5))
                pixel.size = CGSize(width: 5, height: 5)
                pixel.position = (player.body?.position)!
                pixel.physicsBody!.isDynamic = true
                pixel.physicsBody!.affectedByGravity = true
                pixel.physicsBody!.allowsRotation = true
                pixel.physicsBody!.pinned = false
                pixel.physicsBody!.linearDamping = 1.0
                
                
                pixel.physicsBody!.restitution = 0.4
                pixel.physicsBody!.mass = 0.1
                
                
                pixel.physicsBody!.categoryBitMask = Level.objectType.debris.rawValue
                pixel.physicsBody!.collisionBitMask = Level.objectType.debris.rawValue | Level.objectType.blockWall.rawValue
                pixel.physicsBody!.contactTestBitMask = Level.objectType.none.rawValue
                
                pixel.color = UIColor(red: 0.0, green: 0.4 + 0.05*CGFloat(i % 5), blue: 0.6 + 0.1*CGFloat(i % 5), alpha: 1.0)
                
                self.addChild(pixel)
                
                
                
                pixel.physicsBody!.applyImpulse(CGVector(dx: 30*cos(randAngle), dy: 30*sin(randAngle)))
                
                let fadeTime = 0.5 + 0.1*Double(i)
                pixel.run(SKAction.fadeAlpha(to: 0.0, duration: fadeTime))
                
            }
            
            player.active = false
            
            // clearing motion trails
            playerTrail[playerTrailIndex].alpha = 0.0
            playerTrail[(playerTrailIndex + 1) % 6].alpha = 0.0
            playerTrail[(playerTrailIndex + 2) % 6].alpha = 0.0
            playerTrail[(playerTrailIndex + 3) % 6].alpha = 0.0
            playerTrail[(playerTrailIndex + 4) % 6].alpha = 0.0
            playerTrail[(playerTrailIndex + 5) % 6].alpha = 0.0
            
            
            player.body?.physicsBody!.pinned = true
            
            finishLabel.text = "Game Over"
            
            showAllLabels()
        }

    }
    
    /**
     sets all labels visible
    **/
    func showAllLabels() {
        levelCompleteShape.isHidden = false
        menuLabel.isHidden = false
        finishLabel.isHidden = false
    }
    
    
    /**
     called on every frame update
    **/
    override func update(_ currentTime: TimeInterval) {
            
        
        
        sceneLevel.time -= 1
        
        // if time expires
        if (sceneLevel.time == 0) {
            kill(angle: 3*M_PI_2)
        }
        
        // preventing overflow
        if (sceneLevel.time == -1000001) {
            sceneLevel.time = -1
        }
        
        // change background every 2 seconds
        if (sceneLevel.time % 120 == 0) {
            colorIndex = (colorIndex + 1) % sceneColors.count
            self.scene?.run(SKAction.colorize(with: sceneColors[colorIndex], colorBlendFactor: 1.0, duration: 2.0))
        }
        
        
        // if level is not over
        if (levelCompleteShape.isHidden) {
            

            // if player reaches door, go to level complete
            if(player.objectContact == Level.objectType.door.rawValue && unlocked && (Utils.distance(first: door.position, second: (player.body?.position)!) <= 25)) {
                levelComplete()
            } else {
                updatePlayer()
            }
            

            
            updateTouches()
            
            
            
            // update labels every 0.25 seconds
            if (sceneLevel.time % 15 == 0) {
                scoreLabel.text = "score: " + String(sceneLevel.score)
                // scoreLabel.text = enemies[0].toString()
                
                var time = String(sceneLevel.time / 60)
                if (sceneLevel.time < 0) {
                    time = "∞"
                }
                timeLabel.text = "time: " + time
            }
        }
        
        playerTrailIndex = (playerTrailIndex + 1) % 6
        
        updateEnemies()
        updateProjectiles()


    }
    
}
