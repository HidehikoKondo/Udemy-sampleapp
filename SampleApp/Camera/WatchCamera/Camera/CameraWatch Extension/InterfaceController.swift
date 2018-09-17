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
        submit()
    }
    
    @IBAction func voiceButton() {
        print("ボイス")
    }
    
    
    func submit(){
        do {
            try session.updateApplicationContext(["message":"shutter"])
            print("try send")
        } catch {
            print("error")
        }
    }
        
        
        
//        NSDictionary *applicationDict = @{@"message" : message};
//        [[WCSession defaultSession] updateApplicationContext:applicationDict error:nil];
//
//
//        if ([[WCSession defaultSession] isReachable]) {
//            NSLog(@"繋がった");
//            [[WCSession defaultSession] sendMessage:applicationDict
//                replyHandler:^(NSDictionary *replyHandler) {
//                // do something
//                NSLog(@"送った/ %@",message);
//                }
//                errorHandler:^(NSError *error) {
//                // do something
//                NSLog(@"送れなかった・・・orz");
//                }
//            ];
//        }else{
//            NSLog(@"つながってないよ");
//            [_textLabel setText:@"つながってないよ"];
//
//        }

    }

