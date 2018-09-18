//
//  ViewController.swift
//  Camera
//
//  Created by UDONKONET on 2018/08/25.
//  Copyright © 2018年 UDONKONET. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation

//追加
import WatchConnectivity


class ViewController: UIViewController, AVSpeechSynthesizerDelegate, WCSessionDelegate {
    @IBOutlet weak var label: UILabel!
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message)
        self.label.text = (message["message"] as! String)
        speak();

    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("---session---")
        self.label.text = "session"
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("---sessionDidBecomeInactive---")
        self.label.text = "sessionDidBecomeInactive"
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("---sessionDidDeactivate---")
        self.label.text = "sessionDidDeactivate"
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("---didReceiveApplicationContext---")
        self.label.text = "didReceiveApplicationContext"
    }

    
    //変数
    var cameraType: Bool = true
    var captureSession: AVCaptureSession!
    var cameraDevices: AVCaptureDevice!
    var imageOutput: AVCaptureStillImageOutput!
    var cameraImage: UIImage!
    
    //Outlet
    @IBOutlet weak var cameraView: UIView!
    
    //おしゃべり機能
    var speech = AVSpeechSynthesizer()
    
    //Watchsession
    var session = WCSession.default;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //1
        self.cameraConnection(type: cameraType)
        
        //おしゃべり機能
        self.speech.delegate = self;
        
        
        // Watch Connectivity サポートチェック
        if (WCSession.isSupported()) {
            self.session.delegate = self
            self.session.activate()
        }
    }

    //おしゃべり機能
    //読み上げ開始時に呼び出し
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)
    {
        print("読み上げ開始")
    }

    //読み上げ終了時に呼び出し
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
        print("読み上げ終了。写真撮影処理へ")
        self.takePhoto()
    }
    
    func cameraConnection(type: Bool){
        //セッションの作成
        captureSession = AVCaptureSession()
        
        //デバイス一覧の取得
        let devices = AVCaptureDevice.devices()
        
        //バックカメラをcameraDevicesに格納
        for device in devices {
            if(type == true){
                if device.position == AVCaptureDevice.Position.front {
                    cameraDevices = device as! AVCaptureDevice
                }
            }else{
                if device.position == AVCaptureDevice.Position.back {
                    cameraDevices = device as! AVCaptureDevice
                }
            }
        }
        
        //バックカメラからVideoInputを取得
        let videoInput: AVCaptureInput!
        do {
            videoInput = try AVCaptureDeviceInput.init(device: cameraDevices)
        } catch {
            videoInput = nil
        }
        
        //セッションに追加
        captureSession.addInput(videoInput)
        
        //出力先を生成
        imageOutput = AVCaptureStillImageOutput()
        
        //セッションに追加
        captureSession.addOutput(imageOutput)
        
        //画像を表示するレイヤーを生成
        let captureVideoLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        captureVideoLayer.frame = self.cameraView.bounds
        captureVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        //Viewに追加
        self.cameraView.layer.addSublayer(captureVideoLayer)
        
        //セッション開始
        captureSession.startRunning()
        
    }

    
    //MARK: - カメラ関連
    @IBAction func changeCamera(_ sender: Any) {
        //いったんセッション切る
        captureSession.stopRunning()
        
        //カメラタイプを反転
        cameraType = !cameraType
        
        //再接続
        self.cameraConnection(type: cameraType)
    }
    
    @IBAction func takePhotoButton(_ sender: Any){
        speak()
    }
    
    func speak(){
        let utterance = AVSpeechUtterance(string:"はい！チーズ")
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        self.speech.speak(utterance)
    }
    
    func takePhoto() {
        //ボタンを無効
        self.disableButton()
        
        //ビデオ出力に接続
        let captureVideoConnection = imageOutput.connection(with: AVMediaType.video)
        
        //接続から画像を取得
        self.imageOutput.captureStillImageAsynchronously(from: captureVideoConnection!) { (imageDataBuffer, error) -> Void in
            //取得したImageのDataBufferをJPEGを変換
            let capturedImageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer!)! as NSData
            //JPEGからUIImageを作成
            self.cameraImage = UIImage(data: capturedImageData as Data)!
            
            //カメラを止める
            self.captureSession.stopRunning()
            
//            //インカメのときだけ写真を反転させる
//            if(self.cameraType){
//                self.photoImage = cameraImage.flipHorizontal()
//            }else{
//                self.photoImage = cameraImage
//            }
            
        }
    }

    @IBAction func reTakePhoto(_ sender: Any) {
        //セッション開始
        captureSession.startRunning()
    }
    
    //保存ボタン
    @IBAction func saveToLibrary(_ sender: Any) {
        // その中の UIImage を取得
        let targetImage = self.cameraImage
        
        // UIImage の画像をカメラロールに画像を保存
        UIImageWriteToSavedPhotosAlbum(targetImage!, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        var title = "カメラロールに保存しました"
        var message = "SNSのアイコンにして、診断結果をみんなにシェアしよう！(≧∀≦*)"
        
        if error != nil {
            title = "ｱﾚﾚ?>(○´∀｀○) "
            message = "診断結果の保存に失敗しました"
        }
        
        alert(title: title, message: message)
    }
    
    //アラート
    func alert(title: String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action:UIAlertAction!) -> Void in
        }))
        
        // UIAlertController を表示
        self.present(alert, animated: true, completion: nil)
    }

    
    func disableButton(){
//        self.shutterButton.isEnabled = false
//        self.changeButton.isEnabled = false
//        self.backButton.isEnabled = false
//        self.indicatorView.isHidden = false
    }
    
}

