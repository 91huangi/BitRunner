//
//  Utils.swift
//  NinjaWarrior
//
//  Created by Ivan Huang on 12/15/16.
//  Copyright © 2016 Ivan Huang. All rights reserved.
//

import Foundation
import SpriteKit

class Utils {
    
    // screen size scaling
    static var scaleFactor: (x: CGFloat, y: CGFloat) = (x: 1.0, y: 1.0)
    
    // NSDefaults
    static let userDefaults = UserDefaults.standard
    
    
    /**
     maps point from iPhone 6 (750x1334) to a new screen
    **/
    static func map(point: CGPoint) -> CGPoint {
        return CGPoint(x: scaleFactor.x * point.x, y: scaleFactor.y * point.y)
    }
    
    
    /**
     maps size from iPhone 6 (750x1334) to a new screen
     **/
    static func map(size: CGSize) -> CGSize {
        return CGSize(width: scaleFactor.x * size.width, height: scaleFactor.y * size.height)
    }
    
    
    /**
     calculates the distance between two points
    **/
    static func distance(first: CGPoint, second: CGPoint) -> Double {
        return Double(hypotf(Float(Double(second.x - first.x)), Float(second.y - first.y)))
    }
    
    
    /**
     takes an angle in radians and returns it in [0, 2*PI)
    **/
    static func normalizeAngle(angle: Double) -> Double {
        
        var normedAngle = angle
        
        // keeping angle between [0, 2*pi]
        while( normedAngle < 0 || 2*M_PI <= normedAngle) {
            if (normedAngle < 0) {
                normedAngle += 2*M_PI
            } else if (normedAngle >= 2*M_PI) {
                normedAngle -= 2*M_PI
            }
        }

        return normedAngle
    }
    
    
    /**
     takes an angle in radians and returns it rounded to the nearest PI/2
    **/
    static func nearest90(angle: Double) -> Double {
        var angleAt90 = Double(round(angle / M_PI_2))*M_PI_2
        angleAt90 = Utils.normalizeAngle(angle: angleAt90)
        return angleAt90
    }
    
    
    /**
     takes a starting angle and increments it to the target angle via the shortest arc distance
    **/
    static func slowRotate(targetAngle: Double, startAngle: Double, speed: Double) -> Double {

        let normedStartAngle = normalizeAngle(angle: startAngle)
        let normedTargetAngle = normalizeAngle(angle: targetAngle)
        var newAngle = normedStartAngle
        
        let arcDist = Utils.arcDistance(angle1: normedStartAngle, angle2: normedTargetAngle)
        
        // if turning CW minimizes arc distance, go CW
        if (Utils.arcDistance(angle1: normedStartAngle - speed, angle2: normedTargetAngle) < arcDist) {
            newAngle -= min(speed, arcDist)
        }
        // otherwise go CCW
        else {
            newAngle += min(speed, arcDist)
        }
        
        return Utils.normalizeAngle(angle: newAngle)
        
    }
    
    /**
     calculates the arc distance between two angles in radians... result in [0, PI)
    **/
    static func arcDistance(angle1: Double, angle2: Double) -> Double{
        // choosing the smaller arc distance
        let arcDiff = normalizeAngle(angle: (angle1 - angle2))
        return min(abs(arcDiff), abs(arcDiff - 2*M_PI))
    }
    
}
