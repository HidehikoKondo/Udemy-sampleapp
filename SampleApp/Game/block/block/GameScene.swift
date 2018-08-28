//
//  GameScene.swift
//  block
//
//  Created by UDONKONET on 2018/08/26.
//  Copyright © 2018年 UDONKONET. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var player : SKSpriteNode?
    private var fire : SKEmitterNode?
    private var ball : SKSpriteNode?

    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        
        self.player = self.childNode(withName: "//PLAYER") as? SKSpriteNode


        let vector = CGVector(dx: 10, dy: 10)
        self.ball = self.childNode(withName: "//BALL") as? SKSpriteNode
        self.ball?.physicsBody?.applyImpulse(vector)


        //self.player?.run(SKAction.init(named: "rectAnim")!, withKey: "fadeInOut")

       // let emitter = SKEmitterNode(fileNamed: "fire")!
//        if let node = SKEmitterNode(fileNamed: "MyParticle") {
//            node.position.x = 100;
//            node.position.y = 100;
//            addChild(node)
//        }
//
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //プレイヤーのxの位置を指の位置にする
            self.player?.position.x = t.location(in: self).x
            print( t.location(in: self).x)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //self.touchMoved(toPoint: t.location(in: self))
            
            //プレイヤーのxの位置を指の位置にする
            self.player?.position.x = t.location(in: self).x
            print( t.location(in: self).x)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
