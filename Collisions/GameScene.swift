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

enum CircleType: String {
  case Big = "Big"
  case Little = "Little"
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var gameView: SKView!
  var bigCircle: Circle!
  
  let bottomAreaHeight = CGFloat(170);
  
  override func didMoveToView(view: SKView) {
    gameView = view
    
    backgroundColor = UIColor.blackColor()
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    
    for wall in Wall.allValues {
      addChild(createWallFromWallType(wall)!)
    }
    
    createBigCircle()
    addCircleToView(gameView, withVelocity: CGVector(dx: 200, dy: 400), atPosition: CGPoint(x: 300, y: 400))
  }
  
  func createWallFromWallType(wall: Wall) -> SKNode? {
    var beginPoint: CGPoint?
    var endPoint: CGPoint?
    
    let borderName = wall.rawValue
    let wallView = UIView()
    wallView.backgroundColor = UIColor.whiteColor()
    
    switch(wall) {
    case Wall.Bottom:
      beginPoint = CGPoint(x: gameView.frame.origin.x, y: bottomAreaHeight)
      endPoint = CGPoint(x: gameView.frame.width, y: bottomAreaHeight)
      wallView.frame = CGRect(origin: CGPoint(x: 0, y: gameView.frame.height - bottomAreaHeight), size: CGSize(width: gameView.frame.width, height: 0.5))
    case Wall.Left:
      beginPoint = gameView.frame.origin
      endPoint = CGPoint(x: gameView.frame.origin.x, y: gameView.frame.height)
      wallView.frame = CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: 0.5, height: gameView.frame.height - bottomAreaHeight))
    case Wall.Right:
      beginPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.origin.y)
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.height)
      wallView.frame = CGRect(origin: CGPoint(x: gameView.frame.width - 0.5, y: 0), size: CGSize(width: 0.5, height: gameView.frame.height - bottomAreaHeight))
    case Wall.Top:
      beginPoint = CGPoint(x: gameView.frame.origin.x, y: gameView.frame.height)
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.height)
      wallView.frame = CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: gameView.frame.width, height: 0.5))
    }
    
    gameView.addSubview(wallView)
    
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
    
    if let physicsBody = circle.physicsBody {
      physicsBody.categoryBitMask = 1
      physicsBody.contactTestBitMask = 1
      physicsBody.collisionBitMask = 2
      physicsBody.velocity = velocity
    }
    
    circle.position = position
    circle.name = CircleType.Little.rawValue
    
    addChild(circle)
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    var circle: SKPhysicsBody!
    var wall: SKPhysicsBody!
    
    if contact.bodyA.contactTestBitMask < contact.bodyB.contactTestBitMask {
      circle = contact.bodyA
      wall = contact.bodyB
    } else if contact.bodyA.contactTestBitMask > contact.bodyB.contactTestBitMask {
      circle = contact.bodyB
      wall = contact.bodyA
    } else {
      return
    }
    
    let wallName = wall.node!.name!
    var oldVelocity = circle.velocity
    var updatedVelocity: CGVector?
    
    if wallName == Wall.Top.rawValue || wallName == Wall.Bottom.rawValue {
      updatedVelocity = CGVector(dx: oldVelocity.dx, dy: -oldVelocity.dy)
    } else if wallName == Wall.Left.rawValue || wallName == Wall.Right.rawValue {
      updatedVelocity = CGVector(dx: -oldVelocity.dx, dy: oldVelocity.dy)
    }
    
    if let updatedVelocity = updatedVelocity {
      circle.velocity = updatedVelocity
    } else {
      println("problem updating velocity...")
    }
  }
  
  func createBigCircle() {
    bigCircle = Circle(radius: 20, color: UIColor.whiteColor())
    bigCircle.position = CGPoint(x: CGRectGetMidX(gameView.frame), y: CGRectGetMidY(gameView.frame))
    bigCircle.name = CircleType.Big.rawValue
    addChild(bigCircle)
  }
  
  var lastTouchLocation: CGPoint!
  var lastTouchTimestamp: NSTimeInterval!
  let baseMovementFactor = CGFloat(1.8)
  let velocityDampingFactor = CGFloat(0.02)
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    var touch = touches.anyObject() as UITouch?
    if let touch = touch {
      lastTouchLocation = touch.locationInNode(self)
      lastTouchTimestamp = touch.timestamp
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    var touch = touches.anyObject() as UITouch?
    if let touch = touch {
      let currentTouchLocation = touch.locationInNode(self)
      let currentTouchTimestamp = touch.timestamp
      let time = CGFloat(currentTouchTimestamp - lastTouchTimestamp)
      
      let dx = currentTouchLocation.x - lastTouchLocation.x
      let dy = currentTouchLocation.y - lastTouchLocation.y
      
      let horizontalVelocity = CGFloat(abs(dx / time))
      let verticalVelocity = CGFloat(abs(dy / time))
      
      let horizontalMovementFactor = CGFloat(baseMovementFactor + (horizontalVelocity * velocityDampingFactor))
      let verticalMovementFactor = CGFloat(baseMovementFactor + (verticalVelocity * velocityDampingFactor))
      
      var newX = bigCircle.position.x + (dx * horizontalMovementFactor)
      var newY = bigCircle.position.y + (dy * verticalMovementFactor)
      
      if newX > self.frame.width - bigCircle.radius {
        newX = self.frame.width - bigCircle.radius
      } else if newX < 0 + bigCircle.radius {
        newX = 0 + bigCircle.radius
      }
      
      if newY > self.frame.height - bigCircle.radius {
        newY = self.frame.height - bigCircle.radius
      } else if newY < bottomAreaHeight + bigCircle.radius {
        newY = bottomAreaHeight + bigCircle.radius
      }
      
      bigCircle.position = CGPoint(x: newX, y: newY)
      lastTouchLocation = currentTouchLocation
    }
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
  }
}























































