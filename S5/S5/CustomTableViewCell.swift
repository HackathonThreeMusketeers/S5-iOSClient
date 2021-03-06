//
//  CustomTableViewCell.swift
//  S5
//
//  Created by 池田俊輝 on 2018/07/07.
//  Copyright © 2018年 manji. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myTitleLabel: UILabel!
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(imageName: String, titleText: String, descriptionText: String) {
        myImageView.image = UIImage(named: imageName)
        myTitleLabel.text = titleText
    }
    
    @IBAction func pushCellButton(_ sender: Any) {
        //print(indexPath.row)
        let id = indexPath.row+1
        var url:String = "http://ec2-18-222-171-227.us-east-2.compute.amazonaws.com:3000/vibration?id="
        url = url + id.description
        print(url)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON{ response in
            switch response.result {
            case .success:
                let json:JSON = JSON(response.result.value ?? kill)
                print(json["title"])
            case .failure(let error):
                print(error)
            }
        }
    }
}
