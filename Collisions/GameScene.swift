//
//  GameScene.swift
//  Collisions
//
//  Created by Alexander Katz on 3/8/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import SpriteKit

enum ContactCategory: UInt32 {
  case Wall = 1
  case LittleCircle = 2
}

enum Wall: String {
  case Top = "Top"
  case Left = "Left"
  case Right = "Right"
  case Bottom = "Bottom"
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var gameView: SKView!
  
  override func didMoveToView(view: SKView) {
    /* Setup your scene here */
    
    gameView = view
    
    backgroundColor = UIColor.blackColor()
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    
    addSquareToView(view, withVelocity: CGVector(dx: 300, dy: 100), atPosition: CGPoint(x: 200, y: 100))
    addSquareToView(view, withVelocity: CGVector(dx: 150, dy: -10), atPosition: CGPoint(x: 100, y: 300))
    addSquareToView(view, withVelocity: CGVector(dx: 200, dy: 150), atPosition: CGPoint(x: 200, y: 150))
    
    var bottomBorderBody = SKPhysicsBody(edgeFromPoint: view.frame.origin, toPoint: CGPoint(x: view.frame.width, y: view.frame.origin.y))
    bottomBorderBody.friction = 0
    bottomBorderBody.restitution = 1
    bottomBorderBody.usesPreciseCollisionDetection = true
    bottomBorderBody.categoryBitMask = ContactCategory.Wall.rawValue
    bottomBorderBody.contactTestBitMask = ContactCategory.LittleCircle.rawValue
    bottomBorderBody.collisionBitMask = ContactCategory.Wall.rawValue
    var bottomBorder = SKNode()
    bottomBorder.name = Wall.Bottom.rawValue
    bottomBorder.physicsBody = bottomBorderBody
    
    var leftBorderBody = SKPhysicsBody(edgeFromPoint: view.frame.origin, toPoint: CGPoint(x: view.frame.origin.x, y: view.frame.height))
    leftBorderBody.friction = 0
    leftBorderBody.usesPreciseCollisionDetection = true
    leftBorderBody.categoryBitMask = ContactCategory.Wall.rawValue
    leftBorderBody.contactTestBitMask = ContactCategory.LittleCircle.rawValue
    leftBorderBody.collisionBitMask = ContactCategory.Wall.rawValue
    var leftBorder = SKNode()
    leftBorder.name = Wall.Left.rawValue
    leftBorder.physicsBody = leftBorderBody
    
    var rightBorderBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: view.frame.width, y: view.frame.origin.y), toPoint: CGPoint(x: view.frame.width, y: view.frame.height))
    rightBorderBody.friction = 0;
    rightBorderBody.usesPreciseCollisionDetection = true
    rightBorderBody.categoryBitMask = ContactCategory.Wall.rawValue
    rightBorderBody.contactTestBitMask = ContactCategory.LittleCircle.rawValue
    rightBorderBody.collisionBitMask = ContactCategory.Wall.rawValue
    var rightBorder = SKNode()
    rightBorder.name = Wall.Right.rawValue
    rightBorder.physicsBody = rightBorderBody
    
    var topBorderBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: view.frame.origin.x, y: view.frame.height), toPoint: CGPoint(x: view.frame.width, y: view.frame.height))
    topBorderBody.friction = 0;
    topBorderBody.usesPreciseCollisionDetection = true
    topBorderBody.categoryBitMask = ContactCategory.Wall.rawValue
    topBorderBody.contactTestBitMask = ContactCategory.LittleCircle.rawValue
    topBorderBody.collisionBitMask = ContactCategory.Wall.rawValue
    var topBorder = SKNode()
    topBorder.name = Wall.Top.rawValue
    topBorder.physicsBody = topBorderBody
    
    addChild(bottomBorder)
    addChild(leftBorder)
    addChild(rightBorder)
    addChild(topBorder)
  }
  
//  func createSKNodeForWall(wall: Wall) -> SKNode? {
//    var beginPoint: CGPoint?
//    var endPoint: CGPoint?
//    
//    switch(wall) {
//    case Wall.Bottom:
//      beginPoint = gameView.frame.origin
//      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.origin.y)
//    case Wall.Left:
//      beginPoint
//    }
//    
//    return nil
//  }
  
  func addSquareToView(view: UIView, withVelocity velocity: CGVector, atPosition position: CGPoint) {
    
    var circleSize = 5.0;
    
    var drawingView = UIView(frame: CGRect(x: 0, y: 0, width: circleSize, height: circleSize))
    drawingView.backgroundColor = UIColor.clearColor()
    
    var circleLayer = CALayer()
    circleLayer.frame = CGRect(x: 0, y: 0, width: circleSize, height: circleSize)
    circleLayer.backgroundColor = UIColor.whiteColor().CGColor
    circleLayer.opaque = false
    circleLayer.cornerRadius = CGFloat(circleSize / 2)
    circleLayer.masksToBounds = true
    
    drawingView.layer.addSublayer(circleLayer)
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: circleSize, height: circleSize), false, UIScreen.mainScreen().scale)
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor.clearColor().CGColor)
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: circleSize, height: circleSize))
    drawingView.layer.renderInContext(UIGraphicsGetCurrentContext())
    
    var layerImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    var circle = SKSpriteNode(texture: SKTexture(image: layerImage))
    
    circle.name = "Circle"
    circle.position = position
    addChild(circle)
    circle.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(circleSize / 2))
    
    if let physicsBody = circle.physicsBody {
      physicsBody.friction = 0
      physicsBody.restitution = 1
      physicsBody.linearDamping = 0
      physicsBody.allowsRotation = false
      physicsBody.categoryBitMask = 1
      physicsBody.contactTestBitMask = 1
      physicsBody.collisionBitMask = 2
      physicsBody.velocity = velocity
    }
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    var circle: SKPhysicsBody!
    var wall: SKPhysicsBody!
    
    if (contact.bodyA.contactTestBitMask < contact.bodyB.contactTestBitMask) {
      circle = contact.bodyA
      wall = contact.bodyB
    } else if (contact.bodyA.contactTestBitMask > contact.bodyB.contactTestBitMask) {
      circle = contact.bodyB
      wall = contact.bodyA
    } else {
      return
    }
    
    let wallName = wall.node!.name!
    var oldVelocity = circle.velocity
    var updatedVelocity: CGVector?
    
    if (wallName == Wall.Top.rawValue || wallName == Wall.Bottom.rawValue) {
      updatedVelocity = CGVector(dx: oldVelocity.dx, dy: -oldVelocity.dy)
    } else if (wallName == Wall.Left.rawValue || wallName == Wall.Right.rawValue) {
      updatedVelocity = CGVector(dx: -oldVelocity.dx, dy: oldVelocity.dy)
    }
  
    if let updatedVelocity = updatedVelocity {
      circle.velocity = updatedVelocity
    } else {
      println("problem updating velocity...");
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    /* Called when a touch begins */
    
    for touch: AnyObject in touches {
      
    }
  }
}
