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
  func addCircleToView(view: UIView, withVelocity velocity: CGVector, atPosition position: CGPoint) {
    var circle = Circle(radius: 5, color: UIColor.whiteColor())
    circle.physicsBody!.velocity = velocity
    circle.position = position
    
    addChild(circle)
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
      addCircleToView(gameView, withVelocity: CGVector(dx: 100, dy: 300), atPosition: gameView.center)
    }
  }
}
