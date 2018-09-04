//
//  GameScene.swift
//  block
//
//  Created by UDONKONET on 2018/08/26.
//  Copyright © 2018年 UDONKONET. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var player : SKSpriteNode?
    private var fire : SKEmitterNode?
    private var ball : SKSpriteNode?
    private var blocks : SKNode?
    private var endFlg : Bool?
    private var node : SKEmitterNode?

    override func didMove(to view: SKView) {

        //プレイヤー爆発 & 削除
        self.node = SKEmitterNode(fileNamed: "MyParticle")
        self.node?.isHidden = true
        addChild(self.node!)


        //ゲーム終了フラグ（true:終了 false:プレイ中）
        self.endFlg = false

        //衝突判定のdelegate
        self.physicsWorld.contactDelegate = self


        //ブロックを配置しているノードを取得
        self.blocks = self.childNode(withName: "//BLOCKS")


        //ラベル
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        self.label?.isHidden = true

        //プレイヤー
        self.player = self.childNode(withName: "//PLAYER") as? SKSpriteNode


        let vector = CGVector(dx: 5, dy: -10)
        self.ball = self.childNode(withName: "//BALL") as? SKSpriteNode
        self.ball?.physicsBody?.applyImpulse(vector)

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
        //ゲームオーバーの時にタップしたらゲーム再開
        if(endFlg == true){
            backToStart()
        }

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

        //ゲームオーバー判定
        if( CGFloat((self.ball?.position.y)!) < CGFloat((self.player?.position.y)!)){
            self.gameEnd(message: "GAME OVER");
        }
    }

    //ボールとブロックの衝突発生時の処理
    func didBegin(_ contact: SKPhysicsContact) {
        //BLOCKに何かがぶつかったらブロックを消す
        if (contact.bodyA.node?.name == "BLOCK"){
            contact.bodyA.node?.removeFromParent()
        }else if(contact.bodyB.node?.name == "BLOCK" ){
            contact.bodyB.node?.removeFromParent()
        }

        //ブロックの数が0ならゲームクリア
        print(self.blocks!.children.count)
        if(self.blocks!.children.count <= 23){
            self.gameEnd(message: "GAME CLEAR")
        }
    }

    //ゲーム終了
    func gameEnd(message:String){
        print("GAME CLEAR or Game OVER")
        print(self.ball?.position.y)

        //ボールを削除
        self.ball?.removeFromParent()


        //プレイヤー爆発
        self.node!.isHidden = false;
        self.player?.removeFromParent()


        
        //endFlgをTrueにする
        self.endFlg = true

        //Label表示
        self.label?.isHidden = false
        self.label?.text = message
    }

    //シーン遷移
    func backToStart(){

        //同じGameSceneを開き直す
        let transition = SKTransition.fade(withDuration: 2.0)
        //GameScene.swiftを読み込み
        let scene = GameScene(fileNamed: "GameScene")
        //Sceneを画面いっぱいに表示設定
        scene!.scaleMode = .aspectFill
        //遷移実行
        self.view!.presentScene(scene!, transition:transition)
    }
}
