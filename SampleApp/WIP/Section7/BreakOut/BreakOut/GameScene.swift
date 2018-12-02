//
//  GameScene.swift
//  BreakOut
//
//  Created by iOS12カリキュラム on 2018/12/02.
//  Copyright © 2018 UDONKONET. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var player : SKSpriteNode?
    private var ball : SKSpriteNode?
    private var blocks : SKNode?
    private var gameStatus : String?
    
    
    override func didMove(to view: SKView) {
        //衝突判定のdelegate
        self.physicsWorld.contactDelegate = self
        
        //ゲームステータス（"START"：ゲームスタート　"PLAY"：プレイ中  "END"：ゲームオーバー・クリア）
        self.gameStatus = "START"
        
        //ブロックを配置しているノードを取得
        self.blocks = self.childNode(withName: "//BLOCKS")
        
        //ラベル
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        
        //プレイヤー
        self.player = self.childNode(withName: "//PLAYER") as? SKSpriteNode
        
        //ボール
        self.ball = self.childNode(withName: "//BALL") as? SKSpriteNode
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    //ボールとブロックの衝突時の処理
    func didBegin(_ contact: SKPhysicsContact) {
        //BLOCKに何かがぶつかったらブロックを消す
        if (contact.bodyA.node?.name == "BLOCK"){
            //ブロックを消す
            contact.bodyA.node?.removeFromParent()
        }else if(contact.bodyB.node?.name == "BLOCK" ){
            //ブロックを消す
            contact.bodyB.node?.removeFromParent()
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //ゲームステータスに応じたタップ動作設定
        if(self.gameStatus == "START"){
            gameStart();
        }else if(self.gameStatus == "END"){
            backToStart()
        }
        
        for t in touches {
            //プレイヤーのxの位置を指の位置にする
            self.player?.position.x = t.location(in: self).x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //プレイヤーのxの位置を指の位置にする
            self.player?.position.x = t.location(in: self).x
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        //ゲームオーバー判定
        if( CGFloat((self.ball?.position.y)!) < -700){
            if(self.gameStatus != "END"){
                self.gameOver()
            }
        }
    }
    
    //ゲームオーバー
    func gameOver(){
        //ゲームステータスをゲームオーバー・クリアにする
        self.gameStatus = "END"
        
        //Label表示
        self.label?.text = "GAME OVER"
        self.label?.run(SKAction(named: "GAMEOVER")!)
        
        //ボールを削除
        self.ball?.removeFromParent()
    }
    //ゲームスタート
    func gameStart(){
        //ゲームステータスをプレイ中にする
        self.gameStatus = "PLAY"
        
        //タイトルラベルを移動
        self.label?.run(SKAction(named: "GAMESTART")!)
        
        //スタート処理（ボールを動かす）
        let vector = CGVector(dx: 15, dy: -15)
        self.ball?.physicsBody?.applyImpulse(vector)
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
