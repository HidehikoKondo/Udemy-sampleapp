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


class ViewController: UIViewController {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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

    @IBAction func retakePhoto(_ sender: Any) {
    }
    
    @IBAction func saveToLibrary(_ sender: Any) {
    }
    
    @IBAction func changeCameraButton(_ sender: Any) {
    }
    
    @IBAction func takePhotoButton(_ sender: Any) {
    }
    
    
}

