//
//  AITalkWebAPI.swift
//  AITalkWebAPISample
//
//  Created by aitalk on 2018/02/16.
//  Copyright © 2018 aitalk. All rights reserved.
//

import Foundation

// AITalk WebAPI を扱う構造体
struct AITalkWebAPI {
    
    static let AITALK_URL: String!     = "https://webapi.aitalk.jp/webapi/v2/ttsget.php"
    private static let AITALK_ID: String!      = "spajam2018";        // ユーザ名(接続ID)
    private static let AITALK_PW: String!      = "Lpnsen58";        // パスワード(接続パスワード)
    
    var username: String!;      // 接続ID
    var password: String!;      // 接続パスワード
    var speaker_name: String!;  // 話者名
    var style: String!;         // 感情パラメータ
    var input_type: String!;    // 合成文字種別
    var text: String;           // 合成文字
    var volume: String!;        // 音量（0.01-2.00）
    var speed: String!;         // 話速（0.50-4.00）
    var pitch: String!;         // ピッチ（0.50-2.00）
    var range: String!;         // 抑揚（0.00-2.00）
    var output_type: String!;   // 出力形式
    var ext: String!;           // 出力音声形式
    
    // 初期化
    init() {
        username = AITalkWebAPI.AITALK_ID ;
        password = AITalkWebAPI.AITALK_PW;
        speaker_name   = "nozomi_emo";
        style          = "{\"j\":\"1.0\"}";
        input_type     = "text";
        text           = "";
        volume         = "1.0";
        speed          = "1.0";
        pitch          = "1.0";
        range          = "1.0";
        output_type    = "sound";
        ext            = "mp3";
    }
    
    // 文字列をURLエンコーディングして返す
    private func urlencode(string: String!) -> String! {
        return string.addingPercentEncoding(
            withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
    }
    
    // パラメータをDataにして返す
    private func getQuery() -> Data!{
        var params: String = ""
        params += "username=" + username
        params += "&password=" + password
        params += "&speaker_name=" + speaker_name
        params += "&style=" + urlencode(string:style)
        params += "&input_type=" + input_type
        params += "&text=" + urlencode(string:text)
        params += "&volume=" + volume
        params += "&speed=" + speed
        params += "&pitch=" + pitch
        params += "&range=" + range
        params += "&output_type=" + output_type
        params += "&ext=" + ext
        return params.data(using: .utf8)
    }
    
    // 音声合成
    // @param handler 合成完了イベントハンドラ
    func synth(handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var req: URLRequest = URLRequest(url: URL(string: AITalkWebAPI.AITALK_URL)!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = getQuery()
        
        let task = URLSession.shared.dataTask(
            with: req,
            completionHandler: handler)
        task.resume();
    }
}

