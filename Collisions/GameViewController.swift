//
//  GameViewController.swift
//  Collisions
//
//  Created by Alexander Katz on 3/8/15.
//  Copyright (c) 2015 Katz. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
  class func unarchiveFromFile(_ file : NSString) -> SKNode? {
    if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
      let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
      let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
      
      archiver.setClass(classForKeyedUnarchiver(), forClassName: "SKScene")
      let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
      archiver.finishDecoding()
      scene.size = UIScreen.main.bounds.size
      return scene
    } else {
      return nil
    }
  }
}

class GameViewController: UIViewController {
  
  let skView = SKView()
  
  var isPresenting = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.orange
    
    skView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(skView)
    skView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    skView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    skView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    skView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if skView.bounds.width > 0 && skView.bounds.height > 0 && !isPresenting {
      presentGameScene()
      isPresenting = true
    }
  }
  
  func presentGameScene() {
    if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
      skView.showsFPS = true
      skView.showsNodeCount = true
      skView.ignoresSiblingOrder = true
      scene.scaleMode = .aspectFill
      skView.presentScene(scene)
    }
  }
  
}
