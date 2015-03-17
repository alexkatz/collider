//
//  GameScene.swift
//  Collisions
//
//  Created by Alexander Katz on 3/8/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import SpriteKit

enum Boundary: String {
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

enum Category: UInt32 {
  case Obstacle = 1
  case Player = 2
  case Gem = 4
  case Boundary = 8
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
    
    for boundary in Boundary.allValues {
      addChild(createBoundaryFromBoundaryType(boundary)!)
    }
    
    createBigCircle()
    addCircleToView(gameView, withVelocity: CGVector(dx: 20, dy: 40), atPosition: CGPoint(x: 300, y: 400))
  }
  
  func createBoundaryFromBoundaryType(boundary: Boundary) -> SKNode? {
    var beginPoint: CGPoint?
    var endPoint: CGPoint?
    
    let borderName = boundary.rawValue
    let boundaryView = UIView()
    boundaryView.backgroundColor = UIColor.whiteColor()
    
    switch(boundary) {
    case Boundary.Bottom:
      beginPoint = CGPoint(x: gameView.frame.origin.x, y: bottomAreaHeight)
      endPoint = CGPoint(x: gameView.frame.width, y: bottomAreaHeight)
      boundaryView.frame = CGRect(origin: CGPoint(x: 0, y: gameView.frame.height - bottomAreaHeight), size: CGSize(width: gameView.frame.width, height: 0.5))
    case Boundary.Left:
      beginPoint = gameView.frame.origin
      endPoint = CGPoint(x: gameView.frame.origin.x, y: gameView.frame.height)
      boundaryView.frame = CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: 0.5, height: gameView.frame.height - bottomAreaHeight))
    case Boundary.Right:
      beginPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.origin.y)
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.height)
      boundaryView.frame = CGRect(origin: CGPoint(x: gameView.frame.width - 0.5, y: 0), size: CGSize(width: 0.5, height: gameView.frame.height - bottomAreaHeight))
    case Boundary.Top:
      beginPoint = CGPoint(x: gameView.frame.origin.x, y: gameView.frame.height)
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.height)
      boundaryView.frame = CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: gameView.frame.width, height: 0.5))
    }
    
    gameView.addSubview(boundaryView)
    
    if let beginPoint = beginPoint {
      if let endPoint = endPoint {
        var physicsBody = SKPhysicsBody(edgeFromPoint: beginPoint, toPoint: endPoint)
        physicsBody.categoryBitMask = Category.Boundary.rawValue
        physicsBody.collisionBitMask = 0
        physicsBody.friction = 0
        physicsBody.dynamic = false
        
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
  
  func addCircleToView(view: UIView, withVelocity velocity: CGVector, atPosition position: CGPoint) {
    var circle = Circle(radius: 5, color: UIColor.whiteColor())
    
    if let physicsBody = circle.physicsBody {
      physicsBody.categoryBitMask = Category.Obstacle.rawValue
      physicsBody.contactTestBitMask = Category.Boundary.rawValue | Category.Player.rawValue
      physicsBody.collisionBitMask = 0
      physicsBody.velocity = velocity
    }
    
    circle.position = position
    circle.name = CircleType.Little.rawValue
    
    addChild(circle)
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    switch(contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) {
    case Category.Boundary.rawValue | Category.Obstacle.rawValue:
      handleObstacleBoundaryCollision(bodyA: contact.bodyA, bodyB: contact.bodyB)
    case Category.Player.rawValue | Category.Obstacle.rawValue:
      handleObstaclePlayerCollision(bodyA: contact.bodyA, bodyB: contact.bodyB)
    default:
      return
    }
  }
  
  func handleObstacleBoundaryCollision(#bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) {
    var obstacle: SKPhysicsBody!
    var boundary: SKPhysicsBody!
    
    if bodyA.categoryBitMask > bodyB.categoryBitMask {
      boundary = bodyA
      obstacle = bodyB
    } else {
      boundary = bodyB
      obstacle = bodyA
    }
    
    let boundaryName = boundary.node!.name!
    var oldVelocity = obstacle.velocity
    var updatedVelocity: CGVector?
    
    if boundaryName == Boundary.Top.rawValue || boundaryName == Boundary.Bottom.rawValue {
      updatedVelocity = CGVector(dx: oldVelocity.dx, dy: -oldVelocity.dy)
    } else if boundaryName == Boundary.Left.rawValue || boundaryName == Boundary.Right.rawValue {
      updatedVelocity = CGVector(dx: -oldVelocity.dx, dy: oldVelocity.dy)
    }
    
    if let updatedVelocity = updatedVelocity {
      obstacle.velocity = updatedVelocity
    } else {
      NSException(name:"CollisionException", reason:"Could not calculate updated velocity upon obstacle/boundary collision", userInfo:nil).raise()
    }
  }
  
  func handleObstaclePlayerCollision(#bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) {
    println("GAME OVER LOLOLOLOL")
  }
  
  func createBigCircle() {
    bigCircle = Circle(radius: 20, color: UIColor.whiteColor())
    bigCircle.position = CGPoint(x: CGRectGetMidX(gameView.frame), y: CGRectGetMidY(gameView.frame))
    bigCircle.name = CircleType.Big.rawValue

    bigCircle.physicsBody!.categoryBitMask = Category.Player.rawValue
    bigCircle.physicsBody!.collisionBitMask = 0
    
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























































