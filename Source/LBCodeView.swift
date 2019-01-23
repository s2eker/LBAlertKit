//
//  LBCodeView.swift
//  SwiftAlertView
//
//  Created by 李兵 on 2018/10/29.
//  Copyright © 2018 李兵. All rights reserved.
//

import UIKit


protocol LBCodeViewDelegate {
    func didFinishedInputingCode(_ code:String)
}

class LBCodeView: UIView, UITextFieldDelegate, LBCodeTextFieldDelegate {
    var tfs = [UITextField]()
    
    var delegate: LBCodeViewDelegate?
    var num: Int?
    var margin: CGFloat?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let space : CGFloat = self.margin ?? 5
        let num : Int = self.num ?? 6
        let l : CGFloat = 15
        let w : CGFloat = (self.frame.size.width -  CGFloat(2)*l - CGFloat(num-1)*space)/CGFloat(num)
        for i in 0..<num {
            let tf: UITextField = self.tfs[i]
            tf.frame = CGRect(x: l + CGFloat(i)*(w+space), y: 0, width: w, height: self.frame.size.height)
            let line = tf.viewWithTag(1000)
            line?.frame = CGRect(x: 0, y: tf.bounds.size.height-1, width: tf.bounds.size.width, height: 1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(frame: CGRect, num: Int, margin: CGFloat) {
        super.init(frame: frame)
        self.num = num
        self.margin = margin
        initUI()
    }
    
    func initUI() {
        let space : CGFloat = self.margin ?? 5
        let num : Int = self.num ?? 6
        let l : CGFloat = 15
        let w : CGFloat = (self.frame.size.width -  CGFloat(2)*l - CGFloat(num-1)*space)/CGFloat(num)
        for i in 0..<num  {
            let rect = CGRect(x: l + CGFloat(i)*(w+space), y: 0, width: w, height: self.frame.size.height)
            let tf = LBCodeTextField(frame: rect)
            tf.borderStyle = .none
            tf.textAlignment = .center
            tf.font = UIFont.boldSystemFont(ofSize: 18)
            tf.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
            tf.delegate = self
            tf.codeDelegate = self
            tf.keyboardType = .numberPad
            tf.tag = i
            let line = UIView(frame: CGRect(x: 0, y: tf.bounds.size.height-1, width: tf.bounds.size.width, height: 1))
            line.backgroundColor = UIColor.darkGray
            line.tag = 1000
            tf.addSubview(line)
            self.addSubview(tf)
            self.tfs.append(tf)
        }
        self.tfs.first?.becomeFirstResponder()
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch string.count {
        case 0://Delete
            return true
        case 1 ... 6://Input
            var index = textField.tag
            for i in string {
                if index < self.tfs.count {
                    self.tfs[index].text = String(i)
                    index += 1
                    if index < self.tfs.count {
                        self.tfs[index].becomeFirstResponder()
                    }
                }
            }
            var hasTextCount = 0
            for i in self.tfs {
                if i.hasText {
                    hasTextCount += 1
                }
            }
            if hasTextCount == self.tfs.count {
                var code = ""
                for i in  0..<self.tfs.count {
                    code += self.tfs[i].text ?? ""
                }
                textField.resignFirstResponder()
                self.delegate?.didFinishedInputingCode(code)
            }
            return false
            
        default:return false
        }
    }
    func lb_didClickBackdown() {
        for i in 0..<self.tfs.count {
            if self.tfs[i].isFirstResponder {
                self.tfs[i].resignFirstResponder()
                if i > 0 {
                    self.tfs[i - 1].becomeFirstResponder()
                    self.tfs[i - 1].text = ""
                }
            }
        }
    }
}
