//
//  Gem.swift
//  Collisions
//
//  Created by Alexander Katz on 3/22/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import UIKit

class Gem: Square {
  
  static let SizeFromCenter = CGFloat(20)
  static let Color = UIColor.whiteColor()
  
  var sizeFromCenter: CGFloat {
    return Gem.SizeFromCenter
  }
  
  init() {
    super.init(size: Gem.SizeFromCenter, color: Gem.Color)
    
    if let physicsBody = physicsBody {
      physicsBody.categoryBitMask = Category.Gem.rawValue
      physicsBody.contactTestBitMask = Category.Player.rawValue
      physicsBody.collisionBitMask = 0
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
