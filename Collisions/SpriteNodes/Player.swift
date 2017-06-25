//
//  PlayerCircle.swift
//  Collisions
//
//  Created by Alexander Katz on 3/19/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import UIKit

class Player: Circle {

  static let Radius = CGFloat(8)
  static let Color = UIColor.white
  
  var radius: CGFloat {
    return Player.Radius
  }
  
  init() {
    super.init(radius: Player.Radius, color: Player.Color)

    if let physicsBody = physicsBody {
      physicsBody.categoryBitMask = Category.player.rawValue
      physicsBody.collisionBitMask = 0
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  convenience init(x: CGFloat, y: CGFloat) {
    self.init()
    self.position = CGPoint(x: x, y: y);
  }
  
}
