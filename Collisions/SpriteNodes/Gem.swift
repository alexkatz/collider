//
//  Gem.swift
//  Collisions
//
//  Created by Alexander Katz on 3/22/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import UIKit

class Gem: Square {
  
  static var SizeFromCenter = CGFloat(15)
  static var Color = UIColor.cyanColor()
  
  init() {
    super.init(size: Gem.SizeFromCenter, color: Gem.Color)
    
    if let physicsBody = physicsBody {
      physicsBody.categoryBitMask = Category.Gem.rawValue
      physicsBody.collisionBitMask = 0
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
