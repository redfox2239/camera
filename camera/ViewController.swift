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
// PhotoLibraryを使うためのimport
import Photos

// AVFileOutputと相談する準備
class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var cameraView: UIView!
    // カメラやマイクを利用する仲介者を用意（セッション）
    var session: AVCaptureSession!
    // 内側のカメラ
    var frontCamera: AVCaptureDevice!
    // 外側のカメラ
    var backCamera: AVCaptureDevice!
    // マイク（音声入力）
    var audio: AVCaptureDevice!
    // 動画を録画してくれる人＝動画画面キャプチャを撮ってくれる人
    var capture: AVCaptureMovieFileOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // セッションの初期化
        self.session = AVCaptureSession()
        // キャプチャーを撮ってくれる人の初期化
        self.capture = AVCaptureMovieFileOutput()
        
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
        
        self.session.addOutput(self.capture)
        
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
        // 録画してね=self.captureさん録画してね
        // キャプチャをどこに保存しておくか？
        // 保存するキャプチャをどこに保存するか？
        // tmpを見つける
        let temp = NSTemporaryDirectory()
        let filePath = "\(temp)/record.mp4"
        // NSURLの形にfilePathを変換する
        let url = NSURL(fileURLWithPath: filePath)
        self.capture.startRecordingToOutputFileURL(url, recordingDelegate: self)
    }
    
    // 録画開始したらどうする？（AVCaptureMovieFileOutputさんとの相談）
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("録画開始")
    }
    
    // 録画終了した時どうする？（AVCaptureMovieFileOutputさんとの相談）
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("録画終了")
        // record.mp4をphotoLibraryに保存する
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
            // 写真アプリに対して、どんな変更したいの？（追加、削除、参照）
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputFileURL)
            }, completionHandler: nil)
    }
    
    @IBAction func tapRecordStopButton(sender: AnyObject) {
        // 録画を停止する
        self.capture.stopRecording()
    }
    
    @IBAction func tapChangeCameraButton(sender: AnyObject) {
        // 前後のカメラを切り替える
        // どのデバイスがInputとしてsessionに登録されているか調べる
        self.session.inputs.forEach { (value) in
            // as!は正体を保証してあげる。なぜ、これをやるかというと、いまから、カメラなのかマイクなのかを判定する
            let deviceInput = value as! AVCaptureDeviceInput
            // もし、カメラの時は切り替える。それ以外（マイクなど）のときは、何もしない。
            if deviceInput.device.hasMediaType(AVMediaTypeVideo) {
                // 内外でカメラを切り替える
                // 今のカメラをInputから削除する
                // 新しいカメラを追加する
                self.session.removeInput(deviceInput)
                // 外側カメラだったら、内カメラを追加する
                // 内側カメラだったら、外カメラを追加する
                if deviceInput.device.position == AVCaptureDevicePosition.Back {
                    do {
                        let input = try AVCaptureDeviceInput(device: self.frontCamera)
                        self.session.addInput(input)
                    }
                    catch {
                        print("エラー")
                    }
                }
                else {
                    do {
                        let input = try AVCaptureDeviceInput(device: self.backCamera)
                        self.session.addInput(input)
                    }
                    catch {
                        print("エラー")
                    }
                }
            }
        }
    }
    
}












