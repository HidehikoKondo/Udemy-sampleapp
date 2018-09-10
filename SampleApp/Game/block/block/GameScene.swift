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
    private var player : SKSpriteNode?
    private var ball : SKSpriteNode?
    private var blocks : SKNode?
    private var gameStatus : String?

    override func didMove(to view: SKView) {
        //ゲームステータス（"START"：ゲームスタート　"PLAY"：プレイ中  "END"：ゲームオーバー・クリア）
        self.gameStatus = "START"

        //衝突判定のdelegate
        self.physicsWorld.contactDelegate = self

        //ブロックを配置しているノードを取得
        self.blocks = self.childNode(withName: "//BLOCKS")
        

        //ラベル
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode

        //プレイヤー
        self.player = self.childNode(withName: "//PLAYER") as? SKSpriteNode
        self.player!.physicsBody?.usesPreciseCollisionDetection = true
        //ボール
        self.ball = self.childNode(withName: "//BALL") as? SKSpriteNode
        self.ball!.physicsBody?.usesPreciseCollisionDetection = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //ゲームステータスに応じたタップ動作設定
        if(self.gameStatus == "START"){
            gameStart();
        }else if(self.gameStatus == "END"){
            backToStart()
        }

        for t in touches {
            //タップ位置をログに出す
            print( t.location(in: self).x)

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
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
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

    //ボールとブロックの衝突時の処理
    func didBegin(_ contact: SKPhysicsContact) {
        //BLOCKに何かがぶつかったらブロックを消す
        if (contact.bodyA.node?.name == "BLOCK"){
            //ブロックを消す
            contact.bodyA.node?.removeFromParent()
            //パーティクル
            starParticle(node: contact.bodyA.node!)
        }else if(contact.bodyB.node?.name == "BLOCK" ){
            //ブロックを消す
            contact.bodyB.node?.removeFromParent()
            //パーティクル
            starParticle(node: contact.bodyB.node!)
        }

        //ブロックの数が0ならゲームクリア
        if(self.blocks!.children.count <= 0){
            self.gameClear()
        }
    }
    
    //星のパーティクル
    func starParticle(node:SKNode){
        //プレイヤー爆発 & 削除
        let star = SKEmitterNode(fileNamed: "star")
        star?.position.x = node.position.x
        star?.position.y = node.position.y
        addChild(star!)

        //効果音再生Action
        let seAction:SKAction = SKAction(named: "HIT")!
        //待ちAction
        let waitAction:SKAction = SKAction.wait(forDuration: 1)
        //オブジェクトの削除Action
        let removeAction:SKAction = SKAction.removeFromParent()
        //シーケンス
        let sequence:SKAction = SKAction.sequence([seAction, waitAction, removeAction])
        //Action実行
        star?.run(sequence)
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
    
    //ゲームクリア
    func gameClear(){
        //ボールを削除
        self.ball?.removeFromParent()
        
        //ゲームステータスをゲームオーバー・クリアにする
        self.gameStatus = "END"
        
        //Label表示
        self.label?.text = "GAME CLEAR"
        self.label?.run(SKAction(named: "GAMEOVER")!)
        
        //ステージクリアのパーティクル
        let clear = SKEmitterNode(fileNamed: "clear")
        clear?.position.x = 0
        clear?.position.y = 700
        addChild(clear!)
    }

    //ゲームオーバー
    func gameOver(){
        //プレイヤー爆発 & 削除
        let fire = SKEmitterNode(fileNamed: "explosion")
        fire?.position.x = (player?.position.x)!
        fire?.position.y = (player?.position.y)!
        addChild(fire!)

        //ボールを削除
        self.ball?.removeFromParent()

        //プレイヤー爆発
        self.player?.removeFromParent()
        
        //ゲームステータスをゲームオーバー・クリアにする
        self.gameStatus = "END"

        //Label表示
        self.label?.text = "GAME OVER"
        self.label?.run(SKAction(named: "GAMEOVER")!)
        
        //効果音再生Action
        let seAction:SKAction = SKAction(named: "EXPLOSION")!
        self.run(seAction)
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
