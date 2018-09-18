//
//  ViewController.swift
//  Camera
//
//  Created by UDONKONET on 2018/08/25.
//  Copyright © 2018年 UDONKONET. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: 追加でimportするもの
import ImageIO
import WatchConnectivity


class ViewController: UIViewController, AVSpeechSynthesizerDelegate, WCSessionDelegate, AVCapturePhotoCaptureDelegate {
    // MARK: -変数宣言
    //Outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var label: UILabel!

    //カメラ
    var cameraType: Bool = true

//    var cameraDevices: AVCaptureDevice!
//    var imageOutput: AVCaptureStillImageOutput!
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    
    var cameraImage: UIImage!

    //おしゃべり機能
    var speech = AVSpeechSynthesizer()

    //Apple Watch
    var session = WCSession.default;

    //MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
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


    // MARK: - カメラ関連
    func cameraConnection(type: Bool){
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        photoOutput = AVCapturePhotoOutput()

        let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        
        var device:AVCaptureDevice?
        if(type == true){
            device = frontCamera
        }else{
            device = backCamera
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(photoOutput)) {
                    captureSession.addOutput(photoOutput)
                    captureSession.startRunning()
                    let captureVideoLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
                    captureVideoLayer.frame = self.cameraView.bounds
                    captureVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.cameraView.layer.addSublayer(captureVideoLayer)
                }
            }
        }
        catch {
            print(error)
        }
    }

    //フロントカメラ・バックカメラの切り替え
    func changeCamera(){
        //いったんセッション切る
        captureSession.stopRunning()

        //カメラタイプを反転
        cameraType = !cameraType

        //再接続
        self.cameraConnection(type: cameraType)
    }

    func takePhoto() {
        //ボタンを無効
        self.disableButton()
        
        
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        photoOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
        
        
        //ビデオ出力に接続
//        let captureVideoConnection = photoOutput.connection(with: AVMediaType.video)
//
//        //接続から画像を取得
//        self.imageOutput.captureStillImageAsynchronously(from: captureVideoConnection!) { (imageDataBuffer, error) -> Void in
//            //取得したImageのDataBufferをJPEGを変換
//            let capturedImageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer!)! as NSData
//            //JPEGからUIImageを作成
//            self.cameraImage = UIImage(data: capturedImageData as Data)!
//
//            //カメラを止める
//            self.captureSession.stopRunning()
        
//            //インカメのときだけ写真を反転させる
//            if(self.cameraType){
//                self.photoImage = cameraImage.flipHorizontal()
//            }else{
//                self.photoImage = cameraImage
//            }
            
//        }
    }

    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        //カメラを止める
        self.captureSession.stopRunning()

        
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            //let image = UIImage(data: photoData!)
            
            //JPEGからUIImageを作成
            self.cameraImage = UIImage(data: photoData!)
            
            
    //        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
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
        
        // UIImage の画像をカメラロールに写真を保存
        UIImageWriteToSavedPhotosAlbum(targetImage!, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        var title = "保存完了"
        var message = "カメラロールに写真を保存しました"
        
        if error != nil {
            title = "エラー"
            message = "写真の保存に失敗しました"
        }
        
        alert(title: title, message: message)
    }

    //MARK: - おしゃべり機能
    func speak(){
        let utterance = AVSpeechUtterance(string:"はい、チーズ")
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        self.speech.speak(utterance)
    }

    //読み上げ開始時に呼び出し
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)
    {
        print("読み上げ開始")
    }

    //読み上げ終了時に呼び出し
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
        print("読み上げ終了")
        self.takePhoto()
    }


    //MARK: - UI制御
    @IBAction func changeCameraButton(_ sender: Any) {
        changeCamera();
    }

    @IBAction func takePhotoButton(_ sender: Any){
        speak()
    }

    //アラート表示
    func alert(title: String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action:UIAlertAction!) -> Void in }))
        
        // UIAlertController を表示
        self.present(alert, animated: true, completion: nil)
    }

    //ボタンの有効・無効の制御
    func disableButton(){
//        self.shutterButton.isEnabled = false
//        self.changeButton.isEnabled = false
//        self.backButton.isEnabled = false
//        self.indicatorView.isHidden = false
    }

    // MARK: - Apple Watch関連
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
}

