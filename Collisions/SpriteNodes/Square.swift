//
//  Square.swift
//  Collisions
//
//  Created by Alexander Katz on 3/22/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import SpriteKit

class Square: SKSpriteNode {
  
  init(size: CGFloat, color: UIColor) {
    let drawingView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
    drawingView.backgroundColor = UIColor.clearColor()
    
    let squareLayer = CALayer()
    squareLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
    squareLayer.backgroundColor = color.CGColor
    squareLayer.opaque = false
    squareLayer.masksToBounds = true
    
    drawingView.layer.addSublayer(squareLayer)
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, UIScreen.mainScreen().scale)
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor.clearColor().CGColor)
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: size, height: size))
    drawingView.layer.renderInContext(UIGraphicsGetCurrentContext())
    
    let layerImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    super.init(texture: SKTexture(image: layerImage), color: color, size: CGSize(width: size, height: size))
    
    let physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size, height: size))
    physicsBody.friction = 0
    physicsBody.restitution = 1
    physicsBody.linearDamping = 0
    physicsBody.allowsRotation = false
    
    self.physicsBody = physicsBody
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
