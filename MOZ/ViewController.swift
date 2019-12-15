//
//  ViewController.swift
//  MOZ
//
//  Created by 二宮啓 on 2019/12/14.
//  Copyright © 2019 二宮啓. All rights reserved.
//
import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController , AVAudioRecorderDelegate, AVAudioPlayerDelegate ,UITextFieldDelegate{
    
    var isRecording = false
    var w: CGFloat = 0
    var h: CGFloat = 0
    let d: CGFloat = 50
    let l: CGFloat = 28
    
    let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    let stopImage = UIImage(named: "stop.png")
    let playImage = UIImage(named: "play.png")
    let micImage = UIImage(named: "mic.png")
    let squareImage = UIImage(named: "square.png")
    
    
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    
    
    @IBOutlet var firstHanteiLabel: UILabel!
    @IBOutlet var firstHanteiRecordButton: UIButton!
    @IBOutlet var firstHanteiPlayButton: UIButton!
    @IBOutlet var firstHanteiTextField: UITextField!
    @IBOutlet var secondHanteiLabel: UILabel!
    @IBOutlet var secondHanteiRecordButton: UIButton!
    @IBOutlet var secondHanteiPlayButton: UIButton!
    @IBOutlet var secondHanteiTextField: UITextField!
    @IBOutlet var thirdHanteiLabel: UILabel!
    @IBOutlet var thirdHanteiRecordButton: UIButton!
    @IBOutlet var thirdHanteiPlayButton: UIButton!
    @IBOutlet var thirdHanteiTextField: UITextField!
    @IBOutlet var fourthHanteiLabel: UILabel!
    @IBOutlet var fourthHanteiRecordButton: UIButton!
    @IBOutlet var fourthHanteiPlayButton: UIButton!
    @IBOutlet var fourthHanteiTextField: UITextField!
    
    var prevText = ""//判定用に用意したテキスト
    var hanteiUrls = ["firstHantei.m4a","secondHantei.m4a","thirdHantei.m4a","fourthHantei.m4a"]
    
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var isHanteiRecording = false
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        textView.text = ""
        
        self.firstHanteiTextField.delegate = self
        self.secondHanteiTextField.delegate = self
        self.thirdHanteiTextField.delegate = self
        self.fourthHanteiTextField.delegate = self
        
        self.textView.isEditable = false
        self.textView.isSelectable = false
        
        
        firstHanteiRecordButton.setBackgroundImage(micImage, for: .normal)
        secondHanteiRecordButton.setBackgroundImage(micImage, for: .normal)
        thirdHanteiRecordButton.setBackgroundImage(micImage, for: .normal)
        fourthHanteiRecordButton.setBackgroundImage(micImage, for: .normal)
        firstHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
        secondHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
        thirdHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
        fourthHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus != SFSpeechRecognizerAuthorizationStatus.authorized {
                    self.recordButton.isEnabled = false
                    self.recordButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                }
            }
        }
    }
    
    func stopLiveTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    func startLiveTranscription() throws {
        
        // もし前回の音声認識タスクが実行中ならキャンセル
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        textView.text = ""
        
        // 音声認識リクエストの作成
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else {
            return
        }
        recognitionReq.shouldReportPartialResults = true
        
        // オーディオセッションの設定
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        //ここで録音時のモードを設定しているので録画も再生もおこなえるように設定する。
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // マイク入力の設定
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, time) in
            recognitionReq.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = recognizer.recognitionTask(with: recognitionReq, resultHandler: { (result, error) in
            if let error = error {
                print("\(error)")
            } else {
                DispatchQueue.main.async {
                    self.textView.text = result?.bestTranscription.formattedString
                }
            }
        })
        
        startCheck()
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        prevText = ""
        if isRecording {
            recordButton.setTitle("START", for: .normal)
            recordButton.backgroundColor = UIColor(red:153/255, green:85/255, blue:187/255, alpha:1.0)
            recordButton.setTitleColor(UIColor.white, for: .normal)
            stopLiveTranscription()
        } else {
            recordButton.setTitle("STOP", for: .normal)
            recordButton.backgroundColor = UIColor.white
            recordButton.setTitleColor(UIColor(red:153/255, green:85/255, blue:187/255, alpha:1.0), for: .normal)
            try! startLiveTranscription()
        }
        isRecording = !isRecording
    }
    
    
    @IBAction func record(sender:UIButton){
        if !isHanteiRecording {
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSession.Category.playAndRecord)
            try! session.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try! AVAudioRecorder(url: getURL(index: sender.tag), settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            isHanteiRecording = true
            
            switch sender.tag {
            case 1:
                firstHanteiLabel.text = "録音中"
                firstHanteiRecordButton.setBackgroundImage(squareImage, for: .normal)
                firstHanteiPlayButton.isEnabled = false
            case 2:
                secondHanteiLabel.text = "録音中"
                secondHanteiRecordButton.setBackgroundImage(squareImage, for: .normal)
                secondHanteiPlayButton.isEnabled = false
            case 3:
                thirdHanteiLabel.text = "録音中"
                thirdHanteiRecordButton.setBackgroundImage(squareImage, for: .normal)
                thirdHanteiPlayButton.isEnabled = false
            case 4:
                fourthHanteiLabel.text = "録音中"
                fourthHanteiRecordButton.setBackgroundImage(squareImage, for: .normal)
                fourthHanteiPlayButton.isEnabled = false
            default:
                break
                
            }
            
            
        }else{
            
            audioRecorder.stop()
            isHanteiRecording = false
            switch sender.tag {
            case 1:
                firstHanteiLabel.text = "待機中"
                firstHanteiRecordButton.setBackgroundImage(micImage, for: .normal)
                firstHanteiPlayButton.isEnabled = true
            case 2:
                secondHanteiLabel.text = "待機中"
                secondHanteiRecordButton.setBackgroundImage(micImage, for: .normal)
                secondHanteiPlayButton.isEnabled = true
            case 3:
                thirdHanteiLabel.text = "待機中"
                thirdHanteiRecordButton.setBackgroundImage(micImage, for: .normal)
                thirdHanteiPlayButton.isEnabled = true
            case 4:
                fourthHanteiLabel.text = "待機中"
                fourthHanteiRecordButton.setBackgroundImage(micImage, for: .normal)
                fourthHanteiPlayButton.isEnabled = true
            default:
                break
            }
        }
    }
    
    func getURL(index:Int) -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let url = docsDirect.appendingPathComponent(hanteiUrls[index - 1])
        print(url)
        return url
    }
    
    @IBAction func play(sender:UIButton){
        if !isPlaying {
            
            audioPlayer = try! AVAudioPlayer(contentsOf: getURL(index: sender.tag))
            audioPlayer.delegate = self
            audioPlayer.volume = 10.0
            audioPlayer.play()
            
            isPlaying = true
            
            switch sender.tag {
            case 1:
                firstHanteiLabel.text = "再生中"
                firstHanteiPlayButton.setBackgroundImage(stopImage, for: .normal)
                firstHanteiRecordButton.isEnabled = false
            case 2:
                secondHanteiLabel.text = "再生中"
                secondHanteiPlayButton.setBackgroundImage(stopImage, for: .normal)
                secondHanteiRecordButton.isEnabled = false
            case 3:
                thirdHanteiLabel.text = "再生中"
                thirdHanteiPlayButton.setBackgroundImage(stopImage, for: .normal)
                thirdHanteiRecordButton.isEnabled = false
            case 4:
                fourthHanteiLabel.text = "再生中"
                fourthHanteiPlayButton.setBackgroundImage(stopImage, for: .normal)
                fourthHanteiRecordButton.isEnabled = false
            default:
                break
            }
            
        }else{
            
            audioPlayer.stop()
            isPlaying = false
            switch sender.tag {
            case 1:
                firstHanteiLabel.text = "待機中"
                firstHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
                firstHanteiRecordButton.isEnabled = true
            case 2:
                secondHanteiLabel.text = "待機中"
                secondHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
                secondHanteiRecordButton.isEnabled = true
            case 3:
                thirdHanteiLabel.text = "待機中"
                thirdHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
                thirdHanteiRecordButton.isEnabled = true
            case 4:
                fourthHanteiLabel.text = "待機中"
                fourthHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
                fourthHanteiRecordButton.isEnabled = true
            default:
                break
            }
        }
    }
    
    func autoPlay(index:Int){
        if !isPlaying {
            
            audioPlayer = try! AVAudioPlayer(contentsOf: getURL(index: index))
            audioPlayer.delegate = self
            audioPlayer.volume = 3.0
            audioPlayer.play()
            
            isPlaying = true
            
            switch  index{
            case 1:
                firstHanteiLabel.text = "再生中"
                firstHanteiPlayButton.setBackgroundImage(stopImage, for: .normal)
                firstHanteiRecordButton.isEnabled = false
            case 2:
                secondHanteiLabel.text = "再生中"
                secondHanteiPlayButton.setBackgroundImage(stopImage, for: .normal)
                secondHanteiRecordButton.isEnabled = false
            case 3:
                thirdHanteiLabel.text = "再生中"
                thirdHanteiPlayButton.setBackgroundImage(stopImage, for: .normal)
                thirdHanteiRecordButton.isEnabled = false
            case 4:
                fourthHanteiLabel.text = "再生中"
                fourthHanteiPlayButton.setBackgroundImage(stopImage, for: .normal)
                fourthHanteiRecordButton.isEnabled = false
            default:
                break
            }
            
        }else{
            
            audioPlayer.stop()
            isPlaying = false
            
            switch  index{
            case 1:
                firstHanteiLabel.text = "待機中"
                firstHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
                firstHanteiRecordButton.isEnabled = true
            case 2:
                secondHanteiLabel.text = "待機中"
                secondHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
                secondHanteiRecordButton.isEnabled = true
            case 3:
                thirdHanteiLabel.text = "待機中"
                thirdHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
                thirdHanteiRecordButton.isEnabled = true
            case 4:
                fourthHanteiLabel.text = "待機中"
                fourthHanteiPlayButton.setBackgroundImage(playImage, for: .normal)
                fourthHanteiRecordButton.isEnabled = true
            default:
                break
            }
        }
    }
    
    
    func startCheck(){
        Timer.scheduledTimer(timeInterval: 1,        //ループなら間隔 1度きりなら発動までの秒数
            target: self,                                         //メソッドを持つオブジェクト
            selector: #selector(checkVoice),  //実行するメソッド
            userInfo: nil,                                        //オブジェクトに付けて送信する値
            repeats: true)                                        //繰り返し実行するかどうか
    }
    
    @objc func checkVoice(){
        
        let currentText:String = self.textView.text
        let checkText:String = String(currentText.suffix(currentText.count - prevText.count))
        
        let hanteiFirstText: String = firstHanteiTextField.text!
        let hanteiSecondText: String = secondHanteiTextField.text!
        let hanteiThirdText: String = thirdHanteiTextField.text!
        let hanteiFourthText: String = fourthHanteiTextField.text!
        
        
        if checkText.contains(hanteiFirstText){
            print("判定1あり")
            if !isPlaying {
                autoPlay(index:1)
                isPlaying = true
                prevText = currentText
            }else{
                isPlaying = false
            }
        }else  if checkText.contains(hanteiSecondText){
            print("判定2あり")
            if !isPlaying {
                autoPlay(index:2)
                isPlaying = true
                prevText = currentText
            }else{
                isPlaying = false
            }
        }else  if checkText.contains(hanteiThirdText){
            print("判定3あり")
            if !isPlaying {
                autoPlay(index:3)
                isPlaying = true
                prevText = currentText
            }else{
                isPlaying = false
            }
        }else  if checkText.contains(hanteiFourthText){
            print("判定4あり")
            if !isPlaying {
                autoPlay(index:4)
                isPlaying = true
                prevText = currentText
            }else{
                isPlaying = false
            }
        }
    }
    
    //    private func playAll() -> Bool {
    //        if ()
    //
    //        return false
    //    }
    
    //    @objc func checkVoice(){
    //
    //        let currentText:String = self.textView.text
    //        let checkText:String = String(currentText.suffix(10))
    //
    //        let hanteiText: String = hanteiTextField.text!
    //        if checkText.contains(hanteiText){
    //            print("判定あり")
    //            if !isPlaying {
    //                play()
    //                isPlaying = true
    //            }else{
    //                isPlaying = false
    //            }
    //        }
    //    }
    
    //キーボード閉じるやつ
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        firstHanteiTextField.resignFirstResponder()
        secondHanteiTextField.resignFirstResponder()
        thirdHanteiTextField.resignFirstResponder()
        fourthHanteiTextField.resignFirstResponder()
        return true
    }
    
}
