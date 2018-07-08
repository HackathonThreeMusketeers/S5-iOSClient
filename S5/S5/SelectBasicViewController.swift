//
//  SelectBasicViewController.swift
//  S5
//
//  Created by 池田俊輝 on 2018/07/07.
//  Copyright © 2018年 manji. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import Alamofire
import SwiftyJSON
import SpeechToTextV1

class SelectBasicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    /// 画像のファイル名
    let imageNames = ["souce/souce1.png", "souce/souce2.png", "souce/souce3.png", "souce/souce4.png", "souce/souce5.png"]
    
    /// 画像のタイトル
    let imageTitles = ["砂糖", "塩", "酢", "醤油", "みそ"]
    
    @IBOutlet weak var tableView: UITableView!
    
    /*smart speaker用変数*/
    let RESOURCE = Bundle.main.path(forResource: "common", ofType: "res")
    let MODEL = Bundle.main.path(forResource: "kingyo", ofType: "pmdl")
    
    var wrapper: SnowboyWrapper! = nil
    var hotwordTimer: Timer!
    var speechRecognitionTimer: Timer!
    
    var soundFileURL: URL!
    var audioRecorder: AVAudioRecorder!

    var m_player: AVAudioPlayer!
    private static let OUTPUT_FILENAME = "sample.mp3"
    
    var state = State.hotword
    var speechText = ""
    var speechToText: SpeechToText!
    var accumulator = SpeechRecognitionResultsAccumulator()
    
    let commands: [Command] = [.shoyu, .salt, .suger]

    override func viewDidLoad() {
        super.viewDidLoad()
        initSnowboy()
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        //Todo 音声ボタンを押したらstartHotwordDetect()を実行？？　
        startHotwordDetect()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        initSnowboy()
    }
    
    /// セルの個数を指定するデリゲートメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    /// セルに値を設定するデータソースメソッド（必須）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! CustomTableViewCell
        
        // セルに値を設定
        cell.myImageView.image = UIImage(named: imageNames[indexPath.row])
        cell.myTitleLabel.text = imageTitles[indexPath.row]
        cell.indexPath = indexPath
        
        return cell
    }
    @IBAction func myButton(_ sender: UIButton) {
        let title = "振動中"
        let message = "OKを押してください"
        let okText = "OK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(okayButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    func speech(text: String){
        // ★AITalkWebAPIを使うためのインスタンスの作成
        var aitalk = AITalkWebAPI()
        // ★インスタンスに設定したいパラメータをセット
        aitalk.text = text
        // aitalk.speaker_name = "nozomi_emo"
        // aitalk.style = "{\"j\":\"1.0\"}"
        // ★ハンドラをセットして合成開始
        aitalk.synth(handler: onCompletedSynth)
    }
    
    // 再生完了イベントハンドラ
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        switch state {
        case .hotword:
            self.startSpeechRecognizer()
            self.state = .speechRecognition
        case .speechRecognition:
            self.startHotwordDetect()
            self.state = .hotword
        }
    }
    
    //　★合成完了イベント
    func onCompletedSynth(data: Data?, res:URLResponse?, err:Error?) -> Void {
        
        
        if( err != nil ) {  //　HTTPリクエスト失敗
            return
        }
        
        let hres = res! as! HTTPURLResponse
        if( hres.statusCode != 200 ) {  //　合成失敗
            return
        }
        
        //　ファイルの出力先URL
        let savedir = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask, true)[0] as String
        let output_file = "file://" + savedir + "/" + SelectBasicViewController.OUTPUT_FILENAME
        let url:URL! = URL(string:output_file)!
        
        //　ファイル保存
        do {
            try data!.write(to:url)
        } catch {
            dump(error)
            return
        }
        
        //　音声再生準備
        do {
            let recordingSession = AVAudioSession.sharedInstance()
            do{
                try recordingSession.setCategory(AVAudioSessionCategoryPlayback)
            }catch{
                
            }
            
            self.m_player = try AVAudioPlayer(contentsOf:url)
            self.m_player!.delegate = self
            self.m_player!.numberOfLoops = 0
            self.m_player!.prepareToPlay()
            self.m_player!.play()
        } catch {
            return
        }
    }
    
    
    func startHotwordDetect(){
        hotwordTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(startRecording), userInfo: nil, repeats: true)
        hotwordTimer.fire()
    }
    
    func stopHotwordDetect(){
        hotwordTimer.invalidate()
        stopRecording()
    }
    
    func startSpeechRecognizer(){

        let failure = { (error: Error) in print(error) }
        var settings = RecognitionSettings(contentType: "audio/ogg;codecs=opus")
        settings.interimResults = false
        speechToText.recognizeMicrophone(settings: settings, model: "ja-JP_BroadbandModel",failure: failure) {
            
            results in
            self.accumulator.add(results: results)
            print(self.accumulator.bestTranscript)
            self.speechText = self.accumulator.bestTranscript
            self.speech(text: self.speechText + "Ready")
            
            //ここにhttp書く
            var id = 0
            if(self.speechText=="佐藤"){
                id = 1
            }else if(self.speechText=="塩"){
                id = 2
            }else if(self.speechText=="酢"){
                id = 3
            }else if(self.speechText=="醤油"){
                id = 4
            }else if(self.speechText=="みそ"){
                id = 5
            }
            if(id != 0){
                var url:String = "http://ec2-18-222-171-227.us-east-2.compute.amazonaws.com:3000/vibration?id="
                url = url + id.description
                print(url)
                Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON{ response in
                    switch response.result {
                    case .success:
                        let json = JSON(response.result.value ?? kill)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
        }
    }
    
    func stopSpeechRecognizer(){
        speechToText.stopRecognizeMicrophone()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
    }
    
    @objc func startRecording() {
        do {
            let fileMgr = FileManager.default
            let dirPaths = fileMgr.urls(for: .documentDirectory,
                                        in: .userDomainMask)
            soundFileURL = dirPaths[0].appendingPathComponent("temp.wav")
            let recordSettings =
                [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                 AVEncoderBitRateKey: 128000,
                 AVNumberOfChannelsKey: 1,
                 AVSampleRateKey: 16000.0] as [String : Any]
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.record(forDuration: 1.5)
            
            print("Started recording...")
        } catch let error {
            print("Audio session error: \(error.localizedDescription)")
        }
    }
    
    func initSnowboy() {
        wrapper = SnowboyWrapper(resources: RESOURCE, modelStr: MODEL)
        wrapper.setSensitivity("0.5")
        wrapper.setAudioGain(1.0)
        print("Sample rate: \(wrapper?.sampleRate()); channels: \(wrapper?.numChannels()); bits: \(wrapper?.bitsPerSample())")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopRecording()
        let result = getResultofHotwordDetect()
        
        if result == 1 {
            stopHotwordDetect()
            speech(text: "なんでしょう？")
        }
    }
    
    func stopRecording() {
        if (audioRecorder != nil && audioRecorder.isRecording) {
            audioRecorder.stop()
        }
    }
    
    func getResultofHotwordDetect() -> Int32 {
        
        let file = try! AVAudioFile(forReading: soundFileURL)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000.0, channels: 1, interleaved: false)
        let buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(file.length))
        try! file.read(into: buffer!)
        let array = Array(UnsafeBufferPointer(start: buffer?.floatChannelData![0], count: Int(buffer!.frameLength)))
        
        let result = wrapper.runDetection(array, length: Int32(buffer!.frameLength))
        print("Result: \(result)")
        
        return result
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print(error)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error)
    }
    
    
    func audioPlayerDidFinishPlaying(successfully: Bool) {
        print(successfully)
    }
    
    func getResponseText(text: String) -> String {
        for command in commands {
            if text.contains(command.rawValue) {
                return command.response(command: command)
            }
        }
        
        return "すみません．よくわかりません．"
    }
}

extension SelectBasicViewController: SFSpeechRecognizerDelegate {
    // 音声認識の可否が変更したときに呼ばれるdelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
        } else {
        }
    }
}

enum State {
    case hotword
    case speechRecognition
}

enum Command: String{
    case shoyu = "醤油"
    case salt = "塩"
    case suger = "砂糖"
    
    func response(command: Command) -> String{

        switch command {
        case .shoyu:
            return "醤油"
        case .salt:
            return "塩"
        case .suger:
            return "砂糖"
        }
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
