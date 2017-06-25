//
//  Circle.swift
//  Collisions
//
//  Created by Alexander Katz on 3/12/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import SpriteKit

class Circle: SKSpriteNode {

  init(radius: CGFloat, color: UIColor) {
    let drawingView = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
    drawingView.backgroundColor = UIColor.clear
    
    let circleLayer = CALayer()
    circleLayer.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
    circleLayer.backgroundColor = color.cgColor
    circleLayer.isOpaque = false
    circleLayer.cornerRadius = CGFloat(radius)
    circleLayer.masksToBounds = true
    
    drawingView.layer.addSublayer(circleLayer)
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: radius * 2, height: radius * 2), false, UIScreen.main.scale)
    UIGraphicsGetCurrentContext()?.setFillColor(UIColor.clear.cgColor)
    UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
    drawingView.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let layerImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    super.init(texture: SKTexture(image: layerImage!), color: color, size: CGSize(width: radius * 2, height: radius * 2))
    
    let physicsBody = SKPhysicsBody(circleOfRadius: radius)
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



















