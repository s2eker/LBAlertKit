//
//  LBCodeTextField.swift
//  SwiftAlertView
//
//  Created by 李兵 on 2018/10/29.
//  Copyright © 2018 李兵. All rights reserved.
//

import UIKit

protocol LBCodeTextFieldDelegate {
    func lb_didClickBackdown()
}
class LBCodeTextField: UITextField {
    var codeDelegate: LBCodeTextFieldDelegate?
    override func deleteBackward() {
        if self.hasText {
            super.deleteBackward()
        }else {
            self.codeDelegate?.lb_didClickBackdown()
        }
    }
}
