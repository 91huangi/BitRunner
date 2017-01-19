//
//  Level.swift
//
//  Created by Ivan Huang on 12/22/16.
//  Copyright © 2016 Ivan Huang. All rights reserved.
//

import Foundation
import SpriteKit

class Level {
    
    
    // object categories
    enum objectType:UInt32 {
        case none = 0
        
        case player = 1
        case enemy = 2
        case projectile = 4
        case gold = 8
        case key = 16
        case door = 32
        case pusher = 64
        case debris = 128
        
        case leftWall = 1024
        case rightWall = 2048
        case topWall = 4096
        case bottomWall = 8192
        case blockWall = 16384
    }
    
    
    // screen variables
    var maxY: CGFloat
    var minY: CGFloat
    var maxX: CGFloat
    var minX: CGFloat
    var screen: (top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat)
    
    
    // level variables
    var level: Int
    var score: Int
    var time: Int
    var pusherMultiplier: CGFloat
    var gravityMultiplier: CGFloat
    
    
    // object variables
    var startLocation: (CGPoint, Double)
    var walls: [(CGPoint, CGPoint)]
    var objects: [(CGPoint, UInt32)]
    var enemies: [(CGPoint, Double, Int, CGRect)]
    
    
    
    init() {
        self.level = -1
        self.startLocation = (CGPoint(), 1.0)
        self.walls = [(CGPoint, CGPoint)]()
        self.objects = [(CGPoint, UInt32)]()
        self.enemies = [(CGPoint, Double, Int, CGRect)]()
        self.score = 0
        self.time = -1
        
        // physics variables
        self.pusherMultiplier = 1.0
        self.gravityMultiplier = 1.0
        
        // screen variables
        self.screen = (top: 667, bottom: -667, left: -375, right: 375)
        self.maxY = screen.top - 67      // leaving room for labels
        self.minY = screen.bottom + 50
        self.minX = screen.left + 20
        self.maxX = screen.right - 20


    }
    
    func load() {
        
        let fps = 60
        
        if (level == 0) {
            time = -1*fps
        } else if (level == 1) {
            time = 60*fps
        } else if (level == 2) {
            time = 60*fps
        } else if (level == 3) {
            time = 60*fps
        } else if (level == 4) {
            time = 60*fps
        } else if (level == 5) {
            time = 60*fps
        } else if (level == 6) {
            time = 100*fps
        } else if (level == 7) {
            time = 120*fps
            pusherMultiplier = 1.5
        }
        
        setStartLocation()
        setWalls()
        setObjects()
        setEnemies()
    }
    
    
    func setStartLocation() {
        
        if (level == 0) {
            startLocation = (CGPoint(x: 0, y: maxY - 300), 1.0)
        } else if (level == 1) {
            startLocation = (CGPoint(x: 0, y: -400), -1.0)
        } else if(level == 2) {
            startLocation = (CGPoint(x: -250, y: -350), 1.0)
        } else if (level == 3) {
            startLocation = (CGPoint(x: -250, y: 550), 1.0)
        } else if (level == 4) {
            startLocation = (CGPoint(x: -280, y: -150), 1.0)
        } else if (level == 5) {
            startLocation = (CGPoint(x: 0, y: -550), 1.0)
        } else if (level == 6) {
            startLocation = (CGPoint(x: -30, y: 550), -1.0)
        } else if (level == 7) {
            startLocation = (CGPoint(x: minX + 150, y: minY + 150), -1.0)
            
            //startLocation = (CGPoint(x: maxX - 200, y: maxY - 150), 1.0) debugging
        }
    }
    
    
    func setWalls() {
        

        // adding edges
        walls.append((CGPoint(x: screen.left, y: screen.top), CGPoint(x: screen.right, y: maxY)))
        walls.append((CGPoint(x: screen.left, y: maxY), CGPoint(x: minX, y: minY)))
        walls.append((CGPoint(x: maxX, y: maxY), CGPoint(x: screen.right, y: minY)))
        walls.append((CGPoint(x: screen.left, y: minY), CGPoint(x: screen.right, y: screen.bottom)))
        
        
        if (level == 0) {
            
            // block
            walls.append((CGPoint(x: minX, y: maxY - 350), CGPoint(x: maxY, y: minY)))
            
        } else if (level == 1) {
            
            // starting platform
            walls.append((CGPoint(x: -100, y: -450), CGPoint(x: 100, y: -550)))
            
            // center block
            walls.append((CGPoint(x: minX + 60, y: maxY - 100), CGPoint(x: maxX - 60, y: -100)))
            
            // top-mid block
            walls.append((CGPoint(x: -75, y: maxY), CGPoint(x: 75, y: maxY - 100)))
        } else if(level == 2) {
            
            // initial cover
            walls.append((CGPoint(x: -380, y: -90), CGPoint(x: -180, y: -140)))
            
            // middle wall
            walls.append((CGPoint(x: -15, y: -30), CGPoint(x: 15, y: minY)))
            
            // step2 on right
            walls.append((CGPoint(x: maxX-160, y: -140), CGPoint(x: maxX, y: -190)))
            // step1 on right
            walls.append((CGPoint(x: 15, y: -390), CGPoint(x: 175, y: -440)))
            
            // top platform for gold
            walls.append((CGPoint(x: 180, y: 310), CGPoint(x: maxX, y: 260)))
            
        } else if (level == 3) {
            
            // floor 1
            walls.append((CGPoint(x: minX, y: 500), CGPoint(x: maxX - 100, y: 470)))
            
            // floor 2
            walls.append((CGPoint(x: minX + 100, y: 200), CGPoint(x: maxX, y: 170)))
            
            // floor 3
            walls.append((CGPoint(x: minX, y: -100), CGPoint(x: maxX - 100, y: -130)))
            
            // floor 4
            walls.append((CGPoint(x: minX + 100, y: -400), CGPoint(x: maxX, y: -430)))
            
        } else if (level == 4) {
            
            // second floor
            walls.append((CGPoint(x: minX, y: 15), CGPoint(x: maxX - 60, y: -15)))
            
            // vertical divider
            walls.append((CGPoint(x: -15, y: maxY - 70), CGPoint(x: 15, y: 15)))
            
            // starting platform
            walls.append((CGPoint(x: minX, y: -250), CGPoint(x: -20, y: -280)))
            
            // back-left room
            walls.append((CGPoint(x: -50, y: -280), CGPoint(x: -20, y: minY + 80)))
            
            // vertical hanging wall
            walls.append((CGPoint(x: 100, y: -15), CGPoint(x: 130, y: minY + 80)))
            
            
        } else if (level == 5) {
            
            // floor 1 platforms
            walls.append((CGPoint(x: -200, y: -500), CGPoint(x: 200, y: -530)))
            
            // floor 2 platforms
            walls.append((CGPoint(x: minX, y: -350), CGPoint(x: minX+150, y: -380)))
            walls.append((CGPoint(x: maxX-150, y: -350), CGPoint(x: maxX, y: -380)))
            

            // left hanging walls
            walls.append((CGPoint(x: minX + 150, y: 400), CGPoint(x: minX+180, y: 175)))
            walls.append((CGPoint(x: minX + 150, y: 25), CGPoint(x: minX+180, y: -200)))
            
            
            // right hanging walls
            walls.append((CGPoint(x: maxX - 180, y: 400), CGPoint(x: maxX-150, y: -200)))
            
            // top platform
            walls.append((CGPoint(x: minX + 150, y: 430), CGPoint(x: maxX - 150, y: 400)))
            
            // extra wall on top
            walls.append((CGPoint(x: minX, y: maxY), CGPoint(x: maxX - 150, y: maxY - 70)))

        } else if (level == 6) {
            
            // top divider
            walls.append((CGPoint(x: -10, y: maxY), CGPoint(x: 10, y: maxY - 190)))
            
            // box 1 tops
            walls.append((CGPoint(x: minX + 90, y: maxY - 90), CGPoint(x: 10, y: maxY-110)))
            walls.append((CGPoint(x: 70, y: maxY - 90), CGPoint(x: maxX - 90, y: maxY-110)))
            
            // box 1 left & right
            walls.append((CGPoint(x: minX + 90, y: maxY - 110), CGPoint(x: minX + 110, y: minY + 110)))
            walls.append((CGPoint(x: maxX - 110, y: maxY - 110), CGPoint(x: maxX - 90, y: minY + 110)))
            
            // box 1 left ledges
            walls.append((CGPoint(x: minX, y: 205), CGPoint(x: minX + 35, y: 195)))
            walls.append((CGPoint(x: minX + 90 - 35, y: -195), CGPoint(x: minX + 90, y: -205)))
            
            // box 1 bottom
            walls.append((CGPoint(x: minX + 90, y: minY + 110), CGPoint(x: maxX - 90, y: minY + 90)))
            
            
            // box 2 top
            walls.append((CGPoint(x: minX + 190, y: maxY - 190), CGPoint(x: maxX - 190, y: maxY-210)))
            
            // box 2 lefts & right
            walls.append((CGPoint(x: minX + 190, y: maxY - 210), CGPoint(x: minX + 210, y: 50)))
            walls.append((CGPoint(x: minX + 190, y: -50), CGPoint(x: minX + 210, y: minY + 210)))
            walls.append((CGPoint(x: maxX - 210, y: maxY - 210), CGPoint(x: maxX - 190, y: minY + 210)))
            
            // box 2 bottom
            walls.append((CGPoint(x: minX + 190, y: minY + 210), CGPoint(x: maxX - 190, y: minY + 190)))
            
            
            // inside vertical divider
            walls.append((CGPoint(x: -15, y: maxY - 310), CGPoint(x: 15, y: minY + 310)))
            
        } else if (level == 7) {
            
            
            // main 'H'
            walls.append((CGPoint(x: minX + 60, y: maxY - 190), CGPoint(x: maxX - 220 - 60, y: maxY - 210)))
            walls.append((CGPoint(x: 0.5*(minX + maxX - 220) - 10, y: maxY - 210), CGPoint(x: 0.5*(minX + maxX - 220) + 10, y: minY + 80)))
            walls.append((CGPoint(x: minX + 60, y: minY + 80), CGPoint(x: maxX - 220 - 60, y: minY + 60)))
            
            // 'H' dividers
            walls.append((CGPoint(x: minX + 60, y: 230), CGPoint(x: 0.5*(minX + maxX - 220) - 10, y: 210)))
            walls.append((CGPoint(x: minX + 60, y: -330), CGPoint(x: 0.5*(minX + maxX - 220) - 10, y: -350)))
            
            
            // top room
            walls.append((CGPoint(x: minX + 60, y: maxY - 70), CGPoint(x: minX + 80, y: maxY - 190)))
            walls.append((CGPoint(x: maxX - 220 - 80, y: maxY - 90), CGPoint(x: maxX - 220 - 60, y: maxY - 190)))
            
            // s-bend at top right
            walls.append((CGPoint(x: maxX - 220 - 80, y: maxY - 80), CGPoint(x: maxX - 60, y: maxY - 100)))
            walls.append((CGPoint(x: maxX - 90, y: maxY - 170), CGPoint(x: maxX, y: maxY - 190)))
            
            
            // right pipe
            walls.append((CGPoint(x: maxX - 220, y: maxY - 270), CGPoint(x: maxX - 110, y: maxY - 310)))
            walls.append((CGPoint(x: maxX - 220, y: maxY - 310), CGPoint(x: maxX - 180, y: minY)))
            
        }

    }
    
    
    func setObjects() {
        
        if (level == 0) {

        } else if (level == 1) {
            objects.append((CGPoint(x: -100, y: maxY - 50), objectType.key.rawValue))
            objects.append((CGPoint(x: 110, y: maxY - 100 + 37), objectType.door.rawValue))
            objects.append((CGPoint(x: minX + 20, y: minY + 30), objectType.pusher.rawValue))
            objects.append((CGPoint(x: maxX - 20, y: minY + 30), objectType.pusher.rawValue))
            
            // vertical gold
            for i in 0...15 {
                objects.append((CGPoint(x: minX + 30, y: maxY - 125.0 - CGFloat(36*i)), objectType.gold.rawValue))
                objects.append((CGPoint(x: maxX - 30, y: maxY - 125.0 - CGFloat(36*i)), objectType.gold.rawValue))
            }
            
        } else if (level == 2) {
            objects.append((CGPoint(x: 35, y: minY + 30), objectType.key.rawValue))
            objects.append((CGPoint(x: -300, y: minY + 37), objectType.door.rawValue))
            objects.append((CGPoint(x: -40, y: minY + 30), objectType.pusher.rawValue))
            objects.append((CGPoint(x: 0, y: 0), objectType.pusher.rawValue))
            
            // gold on top right ledge
            for i in 1...6 {
                objects.append((CGPoint(x: maxX - 25*CGFloat(i), y: 335), objectType.gold.rawValue))
                objects.append((CGPoint(x: maxX - 25*CGFloat(i), y: 360), objectType.gold.rawValue))
            }
            
            // gold on top left ledge
            for i in 1...6 {
                objects.append((CGPoint(x: minX + 25*CGFloat(i), y: -65), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + 25*CGFloat(i), y: -40), objectType.gold.rawValue))
            }
            
        } else if (level == 3) {
            objects.append((CGPoint(x: maxX - 30, y: minY + 30), objectType.key.rawValue))
            objects.append((CGPoint(x: minX + 80, y: 500 + 37), objectType.door.rawValue))
            
            // gold surrounding turrets
            for i in 2...6 {
                objects.append((CGPoint(x: -30*i, y: 400), objectType.gold.rawValue))
                objects.append((CGPoint(x: 30*i, y: 400), objectType.gold.rawValue))
                objects.append((CGPoint(x: -30*i, y: 100), objectType.gold.rawValue))
                objects.append((CGPoint(x: 30*i, y: 100), objectType.gold.rawValue))
                objects.append((CGPoint(x: -30*i, y: -200), objectType.gold.rawValue))
                objects.append((CGPoint(x: 30*i, y: -200), objectType.gold.rawValue))
            }
            
            // gold on bottom level
            for i in 0...12 {
                objects.append((CGPoint(x: -180+CGFloat(30*i), y: minY + 30), objectType.gold.rawValue))
            }
            
        } else if (level == 4) {
            objects.append((CGPoint(x: 30, y: maxY - 30), objectType.key.rawValue))
            objects.append((CGPoint(x: minX + 50, y: -250 + 37), objectType.door.rawValue))
            objects.append((CGPoint(x: maxX - 20, y: minY + 30), objectType.pusher.rawValue))
            objects.append((CGPoint(x: -35, y: 45), objectType.pusher.rawValue))
            objects.append((CGPoint(x: 35, y: 45), objectType.pusher.rawValue))

            // gold in top room
            for i in 1...13 {
                objects.append((CGPoint(x: minX + 20, y: 15 + CGFloat(30*i)), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + 50, y: 15 + CGFloat(30*i)), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + 80, y: 15 + CGFloat(30*i)), objectType.gold.rawValue))
            }
            
            // gold in bottom room
            for i in 2...8 {
                objects.append((CGPoint(x: minX + CGFloat(30*i), y: minY + 50), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + CGFloat(30*i), y: minY + 80), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + CGFloat(30*i), y: minY + 110), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + CGFloat(30*i), y: minY + 140), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + CGFloat(30*i), y: minY + 170), objectType.gold.rawValue))
            }
        } else if (level == 5) {
            objects.append((CGPoint(x: 0, y: 430 + 30), objectType.key.rawValue))
            objects.append((CGPoint(x: 0, y: -500 + 37), objectType.door.rawValue))
            
            for i in 0...20 {
                objects.append((CGPoint(x: minX + 75, y: 400 - CGFloat(30*i)), objectType.gold.rawValue))
                objects.append((CGPoint(x: maxX - 75, y: 400 - CGFloat(30*i)), objectType.gold.rawValue))
            }
        } else if (level == 6) {
            objects.append((CGPoint(x: 85, y: maxY - 210 - 50), objectType.key.rawValue))
            objects.append((CGPoint(x: 85, y: minY + 210 + 37), objectType.door.rawValue))
            
            // horizontal gold gold
            for i in -5...5 {
                objects.append((CGPoint(x: CGFloat(40*i), y: minY + 45), objectType.gold.rawValue))
                objects.append((CGPoint(x: CGFloat(40*i), y: minY + 150), objectType.gold.rawValue))
            }
            
            // vertical gold
            for i in 0...19 {
                if (i >= 9) {
                    objects.append((CGPoint(x: minX + 155, y: maxY - 150 - CGFloat(46*i)), objectType.gold.rawValue))
                }
                objects.append((CGPoint(x: maxX - 155, y: maxY - 150 - CGFloat(46*i)), objectType.gold.rawValue))
            }
            
        } else if (level == 7) {
            objects.append((CGPoint(x: maxX - 220 - 30, y: minY + 30), objectType.key.rawValue))
            objects.append((CGPoint(x: maxX - 90, y: minY + 37), objectType.door.rawValue))
            objects.append((CGPoint(x: minX + 30, y: minY + 30), objectType.pusher.rawValue))
            
            // gold in bottom row
            for i in 0...11 {
                objects.append((CGPoint(x: minX + 80 + CGFloat(30*i), y: minY + 30), objectType.gold.rawValue))
            }
            
            // gold in top room
            for i in 0...4 {
                objects.append((CGPoint(x: minX + 90 + CGFloat(30*i), y: 265), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + 90 + CGFloat(30*i), y: 295), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + 90 + CGFloat(30*i), y: 325), objectType.gold.rawValue))
                objects.append((CGPoint(x: minX + 90 + CGFloat(30*i), y: 355), objectType.gold.rawValue))
            }
        }
    }
    
    
    func setEnemies() {
        

        if (level == 0) {
            
        } else if (level == 1) {
            
        } else if (level == 2) {
            enemies.append((CGPoint(x: -300, y: 400), 0.0, Enemy.EnemyType.turret.rawValue, CGRect()))
        } else if (level == 3) {
            enemies.append((CGPoint(x: 0, y: 400), 3*M_PI_2, Enemy.EnemyType.turret.rawValue, CGRect()))
            enemies.append((CGPoint(x: 0, y: 100), 3*M_PI_2, Enemy.EnemyType.turret.rawValue, CGRect()))
            enemies.append((CGPoint(x: 0, y: -200), 3*M_PI_2, Enemy.EnemyType.turret.rawValue, CGRect()))
        } else if (level == 4) {
            enemies.append((CGPoint(x: minX + 40, y: 30), M_PI_2, Enemy.EnemyType.drone.rawValue, CGRect()))
            enemies.append((CGPoint(x: maxX - 40, y: maxY - 40), 3*M_PI_2, Enemy.EnemyType.drone.rawValue, CGRect()))
            enemies.append((CGPoint(x: minX + 50, y: -330), 3*M_PI_2, Enemy.EnemyType.turret.rawValue, CGRect()))
            enemies.append((CGPoint(x: -50 - 50, y: -330), 3*M_PI_2, Enemy.EnemyType.turret.rawValue, CGRect()))
        } else if (level == 5) {
            enemies.append((CGPoint(x: 0, y: 100), 3*M_PI_2, Enemy.EnemyType.launcher.rawValue, CGRect()))
            enemies.append((CGPoint(x: maxX - 75, y: maxY - 35), M_PI + M_PI_4, Enemy.EnemyType.turret.rawValue, CGRect()))
        } else if (level == 6) {
            
            // scanner bounds from bottom left of CGRect
            let boundsStart = CGPoint(x: maxX - 89, y: minY + 100)
            // scanner bounds range
            let boundsSize = CGSize(width: 88, height: CGFloat(maxY - 100 - (minY + 100)))
            
            
            enemies.append((CGPoint(x: minX + 45, y: 333), M_PI_2, Enemy.EnemyType.turret.rawValue, CGRect()))
            enemies.append((CGPoint(x: minX + 45, y: 0), M_PI, Enemy.EnemyType.turret.rawValue, CGRect()))
            enemies.append((CGPoint(x: minX + 45, y: -333), 3*M_PI_2, Enemy.EnemyType.turret.rawValue, CGRect()))
            
            enemies.append((CGPoint(x: maxX - 45, y: minY + 100), M_PI_2, Enemy.EnemyType.scanner.rawValue, CGRect(origin: boundsStart, size: boundsSize)))
            
            enemies.append((CGPoint(x: -45, y: maxY - 150), M_PI, Enemy.EnemyType.drone.rawValue, CGRect()))
            
            enemies.append((CGPoint(x: 85, y: 0), 3*M_PI_2, Enemy.EnemyType.launcher.rawValue, CGRect()))
        } else if (level == 7) {
            
            
            enemies.append((CGPoint(x: minX + 60 + 40, y: maxY - 40), 0.0, Enemy.EnemyType.drone.rawValue, CGRect()))
            
            enemies.append((CGPoint(x: minX + 180, y: -50), M_PI, Enemy.EnemyType.turret.rawValue, CGRect()))
            
            
            enemies.append((CGPoint(x: maxX - 380, y: -50), 0.0, Enemy.EnemyType.launcher.rawValue, CGRect()))
            
            
            // scanners going left
            for i in 0...1 {
                let boundsStart = CGPoint(x: maxX - 179, y: maxY - 500 - CGFloat(400*i))
                let boundsSize = CGSize(width: 168, height: 58)
                enemies.append((CGPoint(x: maxX - 85, y: maxY - 470 - CGFloat(400*i)), M_PI, Enemy.EnemyType.scanner.rawValue, CGRect(origin: boundsStart, size: boundsSize)))
            }
            // scanners going right
            for i in 0...1 {
                let boundsStart = CGPoint(x: maxX - 169, y: maxY - 700 - CGFloat(400*i))
                let boundsSize = CGSize(width: 168, height: 58)
                enemies.append((CGPoint(x: maxX - 85, y: maxY - 670 - CGFloat(400*i)), 0.0, Enemy.EnemyType.scanner.rawValue, CGRect(origin: boundsStart, size: boundsSize)))
            }

        }
    }
    
}
