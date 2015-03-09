//
//  GameScene.swift
//  Collisions
//
//  Created by Alexander Katz on 3/8/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import SpriteKit

enum Wall: String {
  case Top = "Top"
  case Left = "Left"
  case Right = "Right"
  case Bottom = "Bottom"
  
  static let allValues = [Top, Left, Right, Bottom]
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var gameView: SKView!
  
  override func didMoveToView(view: SKView) {
    gameView = view
    
    backgroundColor = UIColor.blackColor()
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self

    for wall in Wall.allValues {
      addChild(createSKNodeForWall(wall)!)
    }
  }
  
  func createSKNodeForWall(wall: Wall) -> SKNode? {
    var beginPoint: CGPoint?
    var endPoint: CGPoint?
    var borderName = wall.rawValue
    
    switch(wall) {
    case Wall.Bottom:
      beginPoint = gameView.frame.origin
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.origin.y)
    case Wall.Left:
      beginPoint = gameView.frame.origin
      endPoint = CGPoint(x: gameView.frame.origin.x, y: gameView.frame.height)
    case Wall.Right:
      beginPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.origin.y)
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.height)
    case Wall.Top:
      beginPoint = CGPoint(x: gameView.frame.origin.x, y: gameView.frame.height)
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.height)
    }
    
    if let beginPoint = beginPoint {
      if let endPoint = endPoint {
        var physicsBody = SKPhysicsBody(edgeFromPoint: beginPoint, toPoint: endPoint)
        physicsBody.categoryBitMask = 1
        physicsBody.contactTestBitMask = 2
        physicsBody.collisionBitMask = 1
        physicsBody.friction = 0
        
        var border = SKNode()
        border.name = borderName
        border.physicsBody = physicsBody
        
        return border
      } else {
          return nil
      }
    } else {
      return nil
    }
  }
  
  // TODO: erase this thing, subclass SKSpriteNode for circle or something
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
      addSquareToView(gameView, withVelocity: CGVector(dx: 100, dy: 300), atPosition: gameView.center)
    }
  }
}
