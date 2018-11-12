//
//  ViewController.swift
//  WatchCamera
//
//  Created by iOS12カリキュラム on 2018/11/11.
//  Copyright © 2018 UDONKONET. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO


class ViewController: UIViewController, AVCapturePhotoCaptureDelegate,AVSpeechSynthesizerDelegate {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var changeViewButton: UIButton!
    @IBOutlet weak var savePhotoButton: UIButton!
    @IBOutlet weak var retakePhotoButton: UIButton!
    
    
    //変数宣言
    var cameraType: Bool = true
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var cameraImage: UIImage!
    //おしゃべり機能
    var speech = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //おしゃべり機能
        self.speech.delegate = self;
        
        //ボタンの設定
        self.buttonSetting(takePhoto: true, change: true, save: false, retake: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //カメラ接続
        self.cameraConnection(type: cameraType)
    }
            
    //カメラ接続〜映像表示
    func cameraConnection(type: Bool){
        //カメラの接続設定
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        photoOutput = AVCapturePhotoOutput()
        
        //フロントカメラ or バックカメラ
        let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        var device:AVCaptureDevice?
        if(type == true){
            device = frontCamera
        }else{
            device = backCamera
        }
        //映像表示
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
    
    //写真を撮る
    func takePhoto() {
        //ボタンの設定
        self.buttonSetting(takePhoto: false, change: false, save: true, retake: true)
        
        //撮影設定
        let photoSetting = AVCapturePhotoSettings()
        photoSetting.flashMode = .auto
        photoSetting.isAutoStillImageStabilizationEnabled = true
        photoSetting.isHighResolutionPhotoEnabled = false
        photoOutput?.capturePhoto(with: photoSetting, delegate: self)
    }
    
    //写真出力
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //キャプチャを止める
        self.captureSession.stopRunning()
        
        let photoData = photo.fileDataRepresentation()
        
        //JPEGからUIImageを作成
        self.cameraImage = UIImage(data: photoData!)
    }

    @IBAction func retakePhoto(_ sender: Any) {
        //セッション再開
        captureSession.startRunning()
        
        //ボタンの設定
        self.buttonSetting(takePhoto: true, change: true, save: false, retake: false)
    }
    
    @IBAction func saveToLibrary(_ sender: Any) {
        // その中の UIImage を取得
        let targetImage = self.cameraImage
        
        // UIImage の画像をカメラロールに写真を保存
        UIImageWriteToSavedPhotosAlbum(targetImage!, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //カメラロールへの保存後の処理
    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        //ダイアログに結果を表示
        var title = "保存完了"
        var message = "カメラロールに写真を保存しました"
        
        //エラー発生時のメッセージ
        if (error != nil) {
            title = "エラー"
            message = "写真の保存に失敗しました"
        }
        
        //ダイアログ表示
        alert(title: title, message: message)
        //セッション再開
        captureSession.startRunning()
        //ボタンの設定
        self.buttonSetting(takePhoto: true, change: true, save: false, retake: false)
    }
    
    //アラート表示
    func alert(title: String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action:UIAlertAction!) -> Void in }))
        
        // UIAlertController を表示
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func changeCameraButton(_ sender: Any) {
        changeCamera();
    }
    
    @IBAction func takePhotoButton(_ sender: Any) {
        //ボタンの設定
        self.buttonSetting(takePhoto: false, change: false, save: true, retake: true)

        //読み上げ機能の呼び出し
        speak(message: "はい、チーズ")
    }
    
    //読み上げ機能
    func speak(message:String){
        let utterance = AVSpeechUtterance(string:message as String)
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

    
    //ボタンの有効・無効の制御
    func buttonSetting(takePhoto:Bool, change:Bool, save:Bool, retake:Bool){
        self.takePhotoButton.isEnabled = takePhoto
        self.changeViewButton.isEnabled = change
        self.savePhotoButton.isEnabled = save
        self.retakePhotoButton.isEnabled = retake
    }
}

