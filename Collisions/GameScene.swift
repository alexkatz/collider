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

enum Category: UInt32 {
  case Obstacle = 1
  case Player = 2
  case Gem = 4
  case Boundary = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var gameView: SKView!
  var gameRect: CGRect!
  var player: Player!
  
  let bottomAreaHeight = CGFloat(220)
  let maxObstacleSpeed = CGFloat(100)
  
  override func didMoveToView(view: SKView) {
    gameView = view
    
    backgroundColor = UIColor.blackColor()
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    
    gameRect = CGRect(origin: gameView.frame.origin, size: CGSize(width: gameView.frame.width, height: gameView.frame.height - bottomAreaHeight))
    
    for boundary in Boundary.allValues {
      addChild(createBoundaryFromBoundaryType(boundary)!)
    }
    
    player = Player(x: CGRectGetMidX(gameView.frame), y: CGRectGetMidY(gameView.frame))
    addChild(player)
  }
  
  func createBoundaryFromBoundaryType(boundary: Boundary) -> SKNode? {
    
    let beginPoint: CGPoint?
    let endPoint: CGPoint?
    
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
    
    if let beginPoint = beginPoint, endPoint = endPoint {
      let physicsBody = SKPhysicsBody(edgeFromPoint: beginPoint, toPoint: endPoint)
      physicsBody.categoryBitMask = Category.Boundary.rawValue
      physicsBody.collisionBitMask = 0
      physicsBody.friction = 0
      physicsBody.dynamic = false
      
      let border = SKNode()
      border.name = borderName
      border.physicsBody = physicsBody
      
      return border
    } else {
      return nil
    }
  }

  // MARK: Collision Handling
  
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
  
  // MARK: Category Placement
  
  func randomPositionForRadius(radius: CGFloat) -> CGPoint {
    var point: CGPoint!
    
    do {
      point = CGPoint(x: randomCGFloatWithMax(gameRect.width - radius), y: randomCGFloatWithMax(gameRect.height - radius))
    } while (point.x < radius || point.y < radius)
    
    point.y += bottomAreaHeight
    
    return point
  }
  
  func randomCGFloatWithMax(max: CGFloat) -> CGFloat {
    return max * CGFloat(arc4random()) / CGFloat(UINT32_MAX)
  }
  
  func randomCGFloatWithRange(#min: CGFloat, max: CGFloat) -> CGFloat {
    return (randomCGFloatWithMax(1) * (max - min)) + min
  }
  
  // MARK: Touch Handling
  
  var lastTouchLocation: CGPoint!
  var lastTouchTimestamp: NSTimeInterval!
  let baseMovementFactor = CGFloat(1.8)
  let velocityDampingFactor = CGFloat(0.2)
  let softenPeriod = 2.0
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    if let touch = touches.first as? UITouch {
      lastTouchLocation = touch.locationInNode(self)
      lastTouchTimestamp = touch.timestamp
    }
  }
  
  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    if let touch = touches.first as? UITouch {
      let currentTouchLocation = touch.locationInNode(self)
      let currentTouchTimestamp = touch.timestamp
      let time = CGFloat(currentTouchTimestamp - lastTouchTimestamp)
      
      let dx = currentTouchLocation.x - lastTouchLocation.x
      let dy = currentTouchLocation.y - lastTouchLocation.y
      
      let timeSinceTouchdown = currentTouchTimestamp - lastTouchTimestamp
      let movementDampingFactor = CGFloat(timeSinceTouchdown < softenPeriod ? timeSinceTouchdown / softenPeriod : 1)
      
      let horizontalVelocity = CGFloat(abs(dx / time) * movementDampingFactor)
      let verticalVelocity = CGFloat(abs(dy / time) * movementDampingFactor)
      
      let horizontalMovementFactor = CGFloat(baseMovementFactor + (horizontalVelocity * velocityDampingFactor))
      let verticalMovementFactor = CGFloat(baseMovementFactor + (verticalVelocity * velocityDampingFactor))
      
      var newX = player.position.x + (dx * horizontalMovementFactor)
      var newY = player.position.y + (dy * verticalMovementFactor)
      
      if newX > self.frame.width - player.radius {
        newX = self.frame.width - player.radius
      } else if newX < 0 + player.radius {
        newX = 0 + player.radius
      }
      
      if newY > self.frame.height - player.radius {
        newY = self.frame.height - player.radius
      } else if newY < bottomAreaHeight + player.radius {
        newY = bottomAreaHeight + player.radius
      }
      
      player.position = CGPoint(x: newX, y: newY)
      lastTouchLocation = currentTouchLocation
    }
  }

}























































