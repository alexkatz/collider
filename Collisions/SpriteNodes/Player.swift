//
//  PlayerCircle.swift
//  Collisions
//
//  Created by Alexander Katz on 3/19/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import UIKit

class Player: Circle {
  
  var playerRadius = CGFloat(20)
  
  override var radius: CGFloat! {
    get {
      return playerRadius
    }
    set {}
  }
  
  init() {
    super.init(radius: playerRadius, color: UIColor.whiteColor())
    physicsBody!.categoryBitMask = Category.Player.rawValue
    physicsBody!.collisionBitMask = 0
  }
  
  convenience init(x: CGFloat, y: CGFloat) {
    self.init()
    self.position = CGPoint(x: x, y: y);
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}