//
//  ViewController.swift
//  S5
//
//  Created by 池田俊輝 on 2018/07/07.
//  Copyright © 2018年 manji. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage.gif(name: "sasisuseso")
        imageView.image = image
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

