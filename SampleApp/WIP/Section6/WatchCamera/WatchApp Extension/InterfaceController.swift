//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by iOS12カリキュラム on 2018/11/23.
//  Copyright © 2018 UDONKONET. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidComplete")
    }
    
    var session = WCSession.default

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //sessionを有効にする
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    //シャッターボタン
    @IBAction func shutterButton() {
        submit(message: "はい、チーズ")
    }
    
    //iPhoneにメッセージを送信
    func submit(message:String){
        if  self.session.isReachable {
            self.session.sendMessage(["message":message],replyHandler: {(replyMessage) -> Void in
                print ("receive from apple watch","test");
            }){(error) -> Void in
                print(error)
            }
        }else{
            print("not reachable")
        }
    }
    
    //音声入力
    @IBAction func voiceButton() {
        print("ボイス")
        
        let suggestions: Array<String>! = ["はい、笑ってくださーい","はい、チーズ","3、2、1"]
        presentTextInputController(withSuggestions: suggestions,
                                   allowedInputMode: WKTextInputMode.plain,
                                   completion: {(results) -> Void in
                                    if results != nil && results!.count > 0 { //selection made
                                        let message = results?[0] as? String
                                        self.submit(message: message!)
                                    }
                                    
        })
    }
    
}
