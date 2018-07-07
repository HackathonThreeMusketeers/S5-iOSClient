//
//  SelectBasicViewController.swift
//  S5
//
//  Created by 池田俊輝 on 2018/07/07.
//  Copyright © 2018年 manji. All rights reserved.
//

import UIKit

class SelectBasicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// 画像のファイル名
    let imageNames = ["souce/souce1.png", "souce/souce2.png", "souce/souce3.png", "souce/souce4.png"]
    
    /// 画像のタイトル
    let imageTitles = ["ソース1", "ソース2", "ソース3", "ソース4"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
