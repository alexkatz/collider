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
  case obstacle = 1
  case player = 2
  case gem = 4
  case boundary = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var gameView: SKView!
  var gameRect: CGRect!
  var player: Player!
  
  var didCaptureGem = false
  var gameOver = false
  
  let bottomAreaHeight = CGFloat(220)
  let minObstacleSpeed = CGFloat(0)
  let maxObstacleSpeed = CGFloat(50)
  
  override func didMove(to view: SKView) {
    gameView = view
    
    backgroundColor = UIColor.black
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    
    gameRect = CGRect(origin: gameView.frame.origin, size: CGSize(width: gameView.frame.width, height: gameView.frame.height - bottomAreaHeight))
    
    startNewGame()
  }
  
  func startNewGame() {
    removeAllChildren()
    physicsWorld.speed = 1.0
    gameOver = false
    
    for boundary in Boundary.allValues {
      addChild(createBoundaryFromBoundaryType(boundary)!)
    }
    
    addPlayer()
    addGem()
  }
  
  func createBoundaryFromBoundaryType(_ boundary: Boundary) -> SKNode? {
    let beginPoint: CGPoint?
    let endPoint: CGPoint?
    let borderName = boundary.rawValue
    let boundaryView = UIView()
    
    boundaryView.backgroundColor = UIColor.white
    
    switch(boundary) {
    case Boundary.Bottom:
      beginPoint = CGPoint(x: gameView.frame.origin.x, y: bottomAreaHeight)
      endPoint = CGPoint(x: gameView.frame.width, y: bottomAreaHeight)
      boundaryView.frame = CGRect(origin: CGPoint(x: 0, y: gameView.frame.height - bottomAreaHeight), size: CGSize(width: gameView.frame.width, height: 0.5))
    case Boundary.Left:
      beginPoint = gameView.frame.origin
      endPoint = CGPoint(x: gameView.frame.origin.x, y: gameView.frame.height)
      boundaryView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 0.5, height: gameView.frame.height - bottomAreaHeight))
    case Boundary.Right:
      beginPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.origin.y)
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.height)
      boundaryView.frame = CGRect(origin: CGPoint(x: gameView.frame.width - 0.5, y: 0), size: CGSize(width: 0.5, height: gameView.frame.height - bottomAreaHeight))
    case Boundary.Top:
      beginPoint = CGPoint(x: gameView.frame.origin.x, y: gameView.frame.height)
      endPoint = CGPoint(x: gameView.frame.width, y: gameView.frame.height)
      boundaryView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: gameView.frame.width, height: 0.5))
    }
    
    gameView.addSubview(boundaryView)
    
    if let beginPoint = beginPoint, let endPoint = endPoint {
      let physicsBody = SKPhysicsBody(edgeFrom: beginPoint, to: endPoint)
      physicsBody.categoryBitMask = Category.boundary.rawValue
      physicsBody.collisionBitMask = 0
      physicsBody.friction = 0
      physicsBody.isDynamic = false
      
      let border = SKNode()
      border.name = borderName
      border.physicsBody = physicsBody
      
      return border
    } else {
      return nil
    }
  }
  
  // MARK: Collision Handling
  
  func didBegin(_ contact: SKPhysicsContact) {
    switch(contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) {
    case Category.boundary.rawValue | Category.obstacle.rawValue:
      handleObstacleBoundaryCollision(bodyA: contact.bodyA, bodyB: contact.bodyB)
    case Category.player.rawValue | Category.obstacle.rawValue:
      handleObstaclePlayerCollision(bodyA: contact.bodyA, bodyB: contact.bodyB)
    case Category.player.rawValue | Category.gem.rawValue:
      handlePlayerGemCollision(bodyA: contact.bodyA, bodyB: contact.bodyB)
    default:
      return
    }
  }
  
  func handlePlayerGemCollision(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) {
    let player: SKPhysicsBody
    let gem: SKPhysicsBody
    
    if (bodyA.categoryBitMask > bodyB.categoryBitMask) {
      gem = bodyA
      player = bodyB
    } else {
      gem = bodyB
      player = bodyA
    }
    
    gem.node!.removeFromParent()
    didCaptureGem = true
  }
  
  func handleObstacleBoundaryCollision(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) {
    let obstacle: SKPhysicsBody
    let boundary: SKPhysicsBody
    
    if bodyA.categoryBitMask > bodyB.categoryBitMask {
      boundary = bodyA
      obstacle = bodyB
    } else {
      boundary = bodyB
      obstacle = bodyA
    }
    
    let boundaryName = boundary.node!.name!
    let oldVelocity = obstacle.velocity
    var updatedVelocity: CGVector?
    
    if boundaryName == Boundary.Top.rawValue || boundaryName == Boundary.Bottom.rawValue {
      updatedVelocity = CGVector(dx: oldVelocity.dx, dy: -oldVelocity.dy)
    } else if boundaryName == Boundary.Left.rawValue || boundaryName == Boundary.Right.rawValue {
      updatedVelocity = CGVector(dx: -oldVelocity.dx, dy: oldVelocity.dy)
    }
    
    if let updatedVelocity = updatedVelocity {
      obstacle.velocity = updatedVelocity
    } else {
      NSException(name:NSExceptionName(rawValue: "CollisionException"), reason:"Could not calculate updated velocity upon obstacle/boundary collision", userInfo:nil).raise()
    }
  }
  
  func handleObstaclePlayerCollision(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) {
    print("GAME OVER LOLOLOLOL")
    self.physicsWorld.speed = 0
    gameOver = true
  }
  
  // MARK: Category Placement
  
  func randomPositionForRadius(_ radius: CGFloat) -> CGPoint {
    var point: CGPoint!
    
    repeat {
      point = CGPoint(x: randomCGFloatWithMax(gameRect.width - radius), y: randomCGFloatWithMax(gameRect.height - radius))
    } while (point.x < radius || point.y < radius)
    
    point.y += bottomAreaHeight
    
    return point
  }
  
  func randomCGFloatWithMax(_ max: CGFloat) -> CGFloat {
    return max * CGFloat(arc4random()) / CGFloat(UINT32_MAX)
  }
  
  func randomCGFloatWithRange(min: CGFloat, max: CGFloat) -> CGFloat {
    return (randomCGFloatWithMax(1) * (max - min)) + min
  }
  
  func addGem() {
    let gem = Gem()
    gem.position = randomPositionForRadius(gem.sizeFromCenter)
    addChild(gem)
  }
  
  func addPlayer() {
    player = Player(x: gameView.frame.midX, y: gameView.frame.midY)
    addChild(player)
  }
  
  func addObstacle() {
    let obstacle = Obstacle(position: randomPositionForRadius(Obstacle.Radius), velocity: CGVector(dx: randomCGFloatWithRange(min: minObstacleSpeed, max: maxObstacleSpeed), dy: randomCGFloatWithRange(min: minObstacleSpeed, max: maxObstacleSpeed)))
    addChild(obstacle)
  }
  
  // MARK: Touch Handling
  
  var lastTouchLocation: CGPoint!
  var lastTouchTimestamp: TimeInterval!
  let baseMovementFactor = CGFloat(1)
  let velocityDampingFactor = CGFloat(0.0)
  let softenPeriod = 0.0
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      lastTouchLocation = touch.location(in: self)
      lastTouchTimestamp = touch.timestamp
    }
    
    if gameOver {
      startNewGame()
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let currentTouchLocation = touch.location(in: self)
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
      
      if !gameOver {
        player.position = CGPoint(x: newX, y: newY)
        lastTouchLocation = currentTouchLocation
      }
    }
  }
  
  // MARK: update
  
  override func update(_ currentTime: TimeInterval) {
    if didCaptureGem {
      addGem()
      addObstacle()
      didCaptureGem = false
    }
  }
  
}























































