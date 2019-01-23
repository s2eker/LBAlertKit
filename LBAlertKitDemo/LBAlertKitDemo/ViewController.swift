//
//  ViewController.swift
//  LBAlertKitDemo
//
//  Created by 李兵 on 2019/1/23.
//  Copyright © 2019 李兵. All rights reserved.
//

import UIKit
import LBAlertKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        LBAlertView.show("标题", "消息", "取消", "确定", { () -> LBAlertConfigItem? in
            return nil
        }) { (type, code) in
            print(type, code)
        }
    }

}

