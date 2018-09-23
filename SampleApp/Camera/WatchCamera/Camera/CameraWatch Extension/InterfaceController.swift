//
//  InterfaceController.swift
//  CameraWatch Extension
//
//  Created by UDONKONET on 2018/09/17.
//  Copyright © 2018年 UDONKONET. All rights reserved.
//

import WatchKit
import Foundation

//追加
import WatchConnectivity


class InterfaceController: WKInterfaceController,WCSessionDelegate {
    
    //セッション
    var session = WCSession.default
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("---WCSession-----")
    }
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //Watchのsessionを有効にする
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func shutterButton() {
        submit(message: "はい、チーズ")
    }
    
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
        }
        )
    }
    
    
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
}

