//
//  Obstacle.swift
//  Collisions
//
//  Created by Alexander Katz on 3/22/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import UIKit

class Obstacle: Circle {
  
  static let Radius = CGFloat(3)
  static let Color = UIColor.white
  
  var radius: CGFloat {
    return Obstacle.Radius
  }
  
  init() {
    super.init(radius: Obstacle.Radius, color: Obstacle.Color)

    if let physicsBody = physicsBody {
      physicsBody.categoryBitMask = Category.obstacle.rawValue
      physicsBody.contactTestBitMask = Category.boundary.rawValue | Category.player.rawValue
      physicsBody.collisionBitMask = 0
    }
  }
  
  convenience init(position: CGPoint, velocity: CGVector) {
    self.init()
    self.position = position
    physicsBody!.velocity = velocity;
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
