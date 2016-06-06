//
//  ViewController.swift
//  camera
//
//  Created by 原田　礼朗 on 2016/05/24.
//  Copyright © 2016年 reo harada. All rights reserved.
//

import UIKit
// カメラを使うためのimport
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    // カメラやマイクを利用する仲介者を用意（セッション）
    var session: AVCaptureSession!
    // 内側のカメラ
    var frontCamera: AVCaptureDevice!
    // 外側のカメラ
    var backCamera: AVCaptureDevice!
    // マイク（音声入力）
    var audio: AVCaptureDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // セッションの初期化
        self.session = AVCaptureSession()
        
        // いまiPhoneにはどのデバイスが装備されてるか調べる
        let devices = AVCaptureDevice.devices()
        // 上のデバイスから内カメラ、外カメラ、マイクを取り出す
        // devicesは配列になってる。配列を１つずつみていく
        devices.forEach { (value) in
            // valueには配列の１つずつの中身がはいる
            // valueは正体が不明のため、安心させてあげる=as!
            let device = value as! AVCaptureDevice
            // カメラなのかマイクなのか判定
            if device.hasMediaType(AVMediaTypeVideo) {
                // カメラの時の処理
                // 内カメラのなのか外カメラなのか判定
                if device.position == AVCaptureDevicePosition.Front {
                    // 内カメラ
                    self.frontCamera = device
                }
                else {
                    // 外カメラ
                    self.backCamera = device
                }
            }
            else {
                // マイクの時の処理
                self.audio = device
            }
        }
        
        // sessionさんにアプリとカメラとマイクをつないでもらう
        // カメラの入力を作る
        do {
            let cameraInput = try AVCaptureDeviceInput(device: self.backCamera)
            self.session.addInput(cameraInput)
        }
        catch {
            print("エラー")
        }
        // マイクの入力を作る
        do {
            let audioInput = try AVCaptureDeviceInput(device: self.audio)
            self.session.addInput(audioInput)
        }
        catch {
            print("エラー")
        }
        
        // cameraViewにカメラを表示する
        let cameraLayer = AVCaptureVideoPreviewLayer(session: self.session)
        // サイズを変更します
        cameraLayer.frame = self.cameraView.frame
        // グラビティを合わせる
        cameraLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        // cameraViewの上に重ねる
        self.cameraView.layer.addSublayer(cameraLayer)
        
        // セッションに映像と音声を流して
        self.session.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapRecordButton(sender: AnyObject) {
    }
    
    @IBAction func tapRecordStopButton(sender: AnyObject) {
    }
    
    @IBAction func tapChangeCameraButton(sender: AnyObject) {
    }
    
}












