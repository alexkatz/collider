//
//  Circle.swift
//  Collisions
//
//  Created by Alexander Katz on 3/12/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import SpriteKit


class Circle: SKSpriteNode {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(radius: CGFloat, color: UIColor) {
    var drawingView = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
    drawingView.backgroundColor = UIColor.clearColor()
    
    var circleLayer = CALayer()
    circleLayer.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
    circleLayer.backgroundColor = color.CGColor
    circleLayer.opaque = false
    circleLayer.cornerRadius = CGFloat(radius)
    circleLayer.masksToBounds = true
    
    drawingView.layer.addSublayer(circleLayer)
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: radius * 2, height: radius * 2), false, UIScreen.mainScreen().scale)
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor.clearColor().CGColor)
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
    drawingView.layer.renderInContext(UIGraphicsGetCurrentContext())
    
    var layerImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    super.init(texture: SKTexture(image: layerImage), color: color, size: CGSize(width: radius * 2, height: radius * 2))
    
    var physicsBody = SKPhysicsBody(circleOfRadius: radius)
    physicsBody.friction = 0
    physicsBody.restitution = 1
    physicsBody.linearDamping = 0
    physicsBody.allowsRotation = false
    
    // TODO: move this bitmask stuff elsewhere?
    physicsBody.categoryBitMask = 1
    physicsBody.contactTestBitMask = 1
    physicsBody.collisionBitMask = 2
    
    self.physicsBody = physicsBody
  }
}
