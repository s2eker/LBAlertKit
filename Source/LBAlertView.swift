//
//  LBAlertView.swift
//  SwiftAlertView
//
//  Created by 李兵 on 2018/10/29.
//  Copyright © 2018 李兵. All rights reserved.
//

import UIKit

public enum LBAlertCompletationType {
    case cancel //点击取消键
    case ok     //点击确认键
    case coded  //验证码输入完成
}
public struct LBAlertConfigItem {
    public var showLine1: Bool = true
    public var showLine2: Bool = true
    public var showLine3: Bool = true
    public var showCancelBounder: Bool = false
    public var showOkBounder: Bool = false
    public var titleFont: UIFont? = .systemFont(ofSize: 18)
    public var messageFont: UIFont? = .systemFont(ofSize: 15)
    public var cancelFont: UIFont? = .systemFont(ofSize: 18)
    public var okFont: UIFont? = .systemFont(ofSize: 18)
    public var titleColor: UIColor? = .black
    public var messageColor: UIColor? = .black
    public var cancelColor: UIColor? = .darkGray
    public var okColor: UIColor? = .blue
    public var cancelBounderColor: UIColor? = .black
    public var okBounderColor: UIColor? = .black
    public static func config(_ showLine1:Bool?, _ showLine2:Bool?, _ showLine3:Bool?, _ showCancelBounder:Bool?, _ showOkBounder:Bool?, _ titleFont:UIFont?, _ messageFont:UIFont?, _ cancelFont:UIFont?, _ okFont:UIFont?, _ titleColor: UIColor?, _ messageColor: UIColor?, _ cancelColor: UIColor?, _ okColor: UIColor?, _ cancelBounderColor: UIColor?, _ okBounderColor: UIColor?) -> LBAlertConfigItem {
        var item = LBAlertConfigItem()
        if let a = showLine1 { item.showLine1 = a }
        if let a = showLine2 { item.showLine2 = a }
        if let a = showLine3 { item.showLine3 = a }
        if let a = showCancelBounder { item.showCancelBounder = a }
        if let a = showOkBounder { item.showOkBounder = a }
        if let a = titleFont { item.titleFont = a }
        if let a = messageFont { item.messageFont = a }
        if let a = cancelFont { item.cancelFont = a }
        if let a = okFont { item.okFont = a }
        if let a = titleColor { item.titleColor = a }
        if let a = messageColor { item.messageColor = a }
        if let a = cancelColor { item.cancelColor = a }
        if let a = okColor { item.okColor = a }
        if let a = cancelBounderColor { item.cancelBounderColor = a }
        if let a = okBounderColor { item.okBounderColor = a }
        return item
    }
}
public typealias LBAlertCompletation = (LBAlertCompletationType, Any?)->Void
public typealias LBAlertConfig = ()->LBAlertConfigItem?
public class LBAlertView: UIView, LBCodeViewDelegate {
    //Contents
    var title: String?
    var message: String?
    var cancelTitle: String?
    var okTitle: String?
    var completation:LBAlertCompletation?
    var keyboardHeight: CGFloat = 0

    //views
    var overlay: UIControl?
    var alertView: UIView?
    var titleLabel: UILabel?
    var messageLabel: UILabel?
    var line1: UIView?
    var line2: UIView?
    var line3: UIView?
    var cancelBtn: UIButton?
    var okBtn: UIButton?
    var customView: UIView?

    //config
    var configItem: LBAlertConfigItem?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(_ customView: UIView?, _ title: String?, _ message: String?, _ cancelTitle: String?, _ okTitle: String?, _ config: @escaping LBAlertConfig, _ completation: @escaping LBAlertCompletation) {
        super.init(frame: UIScreen.main.bounds)
        
        initUI()
        initContents(customView, .zero, title, message, cancelTitle, okTitle, config, completation)
        initNotification()
    }
    
    func initUI() {
        func createControl() -> UIControl {
            let v = UIControl(frame: UIScreen.main.bounds)
            v.backgroundColor = UIColor(white: 0, alpha: 0.4)
            v.addTarget(self, action: #selector(overlayAction(sender:)), for: .touchUpInside)
            return v
        }
        func createAlert() -> UIView {
            let v = UIView()
            v.backgroundColor = UIColor.white
            v.layer.cornerRadius = 8
            v.layer.masksToBounds = true
            return v
        }
        func createLine() -> UIView {
            let v = UIView()
            v.backgroundColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1)
            return v
        }
        func createLabel(_ text: String?, _ textColor: UIColor?, _ font: UIFont?, _ alignment: NSTextAlignment?) -> UILabel {
            let l = UILabel()
            l.font = font
            l.text = text
            l.textColor = textColor
            l.textAlignment = alignment ?? .left
            l.numberOfLines = 0
            l.lineBreakMode = NSLineBreakMode.byCharWrapping
            return l
        }
        func createBtn(_ normalTitle: String?, _ highlightedTitle: String?, _ normalTitleColor: UIColor?, _ highlightedColor: UIColor?, _ action: Selector) -> UIButton {
            let btn = UIButton(type: .custom)
            btn.setTitle(normalTitle, for: .normal)
            btn.setTitle(highlightedTitle, for: .highlighted)
            btn.setTitleColor(normalTitleColor, for: .normal)
            btn.setTitleColor(highlightedColor, for: .highlighted)
            btn.addTarget(self, action: action, for: .touchUpInside)
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.black.cgColor
            return btn
        }

        self.overlay = createControl()
        self.addSubview(self.overlay!)

        self.alertView = createAlert()
        self.addSubview(self.alertView!)

        self.line1 = createLine();
        self.alertView?.addSubview(self.line1!)

        self.line2 = createLine()
        self.alertView?.addSubview(self.line2!)

        self.line3 = createLine()
        self.alertView?.addSubview(self.line3!)

        self.titleLabel = createLabel(nil, .black, .systemFont(ofSize: 18), .center)
        self.alertView?.addSubview(self.titleLabel!)

        self.messageLabel = createLabel(nil, .darkGray, .systemFont(ofSize: 15), .left)
        self.alertView?.addSubview(self.messageLabel!)

        self.cancelBtn = createBtn(nil, nil, .black, .black, #selector(cancelAction(sender:)))
        self.alertView?.addSubview(self.cancelBtn!)

        self.okBtn = createBtn(nil, nil, .black, .black, #selector(okAction(sender:)))
        self.alertView?.addSubview(self.okBtn!)
    }
    
    func initContents(_ customView: UIView?,_ frame: CGRect, _ title: String?, _ message: String?, _ cancelTitle: String?, _  okTitle: String?, _ config:LBAlertConfig?, _ completation: @escaping LBAlertCompletation) {
        if customView != nil {
            self.alertView?.addSubview(customView!)
            self.customView = customView
        }
        if let c = config, let item = c() {
            self.configItem = item
        }
        if self.configItem == nil {
            self.configItem = LBAlertConfigItem()
        }
        self.line1?.isHidden = !(self.configItem?.showLine1)!
        self.line2?.isHidden = !(self.configItem?.showLine2)!
        self.line3?.isHidden = !(self.configItem?.showLine3)!
        self.titleLabel?.font = self.configItem?.titleFont
        self.messageLabel?.font = self.configItem?.messageFont
        self.cancelBtn?.titleLabel?.font = self.configItem?.cancelFont
        self.okBtn?.titleLabel?.font = self.configItem?.okFont
        self.titleLabel?.textColor = self.configItem?.titleColor
        self.messageLabel?.textColor = self.configItem?.messageColor
        self.cancelBtn?.setTitleColor(self.configItem?.cancelColor, for: .normal)
        self.okBtn?.setTitleColor(self.configItem?.okColor, for: .normal)
        self.cancelBtn?.layer.borderWidth = self.configItem?.showCancelBounder ?? false ? 1 : 0
        self.okBtn?.layer.borderWidth = self.configItem?.showOkBounder ?? false ? 1 : 0
        self.cancelBtn?.layer.borderColor = self.configItem?.cancelBounderColor?.cgColor
        self.okBtn?.layer.borderColor = self.configItem?.okBounderColor?.cgColor
        
        
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.okTitle = okTitle
        self.completation = completation
        
        self.titleLabel?.text = title
        self.messageLabel?.text = message
        self.cancelBtn?.setTitle(cancelTitle, for: .normal)
        self.okBtn?.setTitle(okTitle, for: .normal)
    }
    func initNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    func show() {
        if self.superview == nil {
            UIApplication.shared.keyWindow?.addSubview(self)
            self.updatePosition()
        }
    }
    public func dismiss() {
        self.removeFromSuperview()
    }
    func updatePosition() {
        enum BtnType {
            case none, cancel, ok, both
        }
        enum LabelType {
            case none, title, message, both
        }
        func getBtnType() -> BtnType {
            if let t0 = self.cancelTitle, !t0.isEmpty, let t1 = self.okTitle, !t1.isEmpty{
                return .both
            }else if let t0 = self.cancelTitle, !t0.isEmpty {
                return .cancel
            }else if let t1 = self.okTitle, !t1.isEmpty {
                return .ok
            }else {
                return .none
            }
        }
        func getLabelType() -> LabelType {
            if let t0 = self.title, !t0.isEmpty, let t1 = self.message, !t1.isEmpty{
                return .both
            }else if let t0 = self.title, !t0.isEmpty {
                return .title
            }else if let t1 = self.message, !t1.isEmpty {
                return .message
            }else {
                return .none
            }
        }
        let W = UIScreen.main.bounds.size.width*0.65
        let margin:CGFloat = 16
        let validW = W-margin*CGFloat(2)
        let titleH: CGFloat = (self.titleLabel?.ajustedHeight(width:validW, space: 5)) ?? 30
        let messageH: CGFloat = (self.messageLabel?.ajustedHeight(width: validW, space: 5)) ?? 20
        let customH: CGFloat = self.customView?.bounds.height ?? 0
        let btnH: CGFloat = 46
        let hasCustom = customH != 0

        let titleRect = CGRect(x: margin, y: margin, width: validW, height: titleH)
        let messageRect = CGRect(x: margin, y: titleRect.lb_maxY(offset: margin), width: validW, height: messageH)
        let customRect = CGRect(x: margin, y: messageRect.lb_maxY(offset: hasCustom ? margin/2 : margin), width: validW, height: customH)
        var cancelRect = CGRect(x: margin, y: customRect.lb_maxY(offset: margin), width: validW, height: btnH)
        var okRect = cancelRect
        var line1Rect = CGRect(x: 0, y: 0, width: W, height: 0.5)
        var line2Rect = CGRect(x: 0, y: 0, width: W, height: 0.5)
        var line3Rect = CGRect(x: W/2, y: cancelRect.minY, width: 0.5, height: cancelRect.height)

        do {
            let type = getLabelType()
            switch type {
            case .none: line1Rect = .zero
            case .title: line1Rect = .zero
            case .message: line1Rect = .zero
            case .both: line1Rect.origin.y = titleRect.lb_maxY(offset: margin/3)
            }
        }

        var btnRect = CGRect()
        do {
            let type = getBtnType()
            switch type {
            case .none:
                cancelRect.size.height = 0
                okRect.size.height = 0
                btnRect = cancelRect
                line2Rect = .zero
                line3Rect = .zero
                btnRect.origin.x += margin
            case .cancel:
                okRect.size.height = 0
                btnRect = cancelRect
                line2Rect.origin.y = btnRect.minY
                line3Rect = .zero
            case .ok:
                cancelRect.size.height = 0
                btnRect = okRect
                line2Rect.origin.y = btnRect.minY
                line3Rect = .zero
            case .both:
                cancelRect.size.width = (W - CGFloat(3)*margin)/2
                okRect.origin.x = cancelRect.maxX + margin
                okRect.size.width = cancelRect.width
                btnRect = cancelRect
                line2Rect.origin.y = btnRect.minY
                line3Rect.size.height = btnRect.height
            }
        }
        let H = btnRect.maxY
        let x = (UIScreen.main.bounds.width-W)/2
        var y = (UIScreen.main.bounds.height-H)/2
        let space: CGFloat = 30
        y = (self.keyboardHeight + space) > y ? 2*y - self.keyboardHeight - space : y
        y -= UIScreen.main.bounds.size.height*0.05
        let alertRect = CGRect(x: x, y: y, width: W, height: H)

        self.line1?.frame = line1Rect
        self.line2?.frame = line2Rect
        self.line3?.frame = line3Rect
        self.titleLabel?.frame = titleRect
        self.messageLabel?.frame = messageRect
        self.customView?.frame = customRect
        self.cancelBtn?.frame = cancelRect
        self.okBtn?.frame = okRect
        self.alertView?.frame = alertRect
        self.customView?.setNeedsLayout()
    }

     @objc func cancelAction(sender: UIButton) {
        self.dismiss()
        self.completation?(.cancel, nil)
    }
    @objc func okAction(sender: UIButton) {
        self.dismiss()
        self.completation?(.ok, nil)
    }
    @objc func overlayAction(sender: UIControl) {
        self.dismiss()
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        self.keyboardHeight = sender.lb_keyboardHeight()
        UIView.animate(withDuration: 0.25) {
            self.updatePosition()
        }
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        self.keyboardHeight = sender.lb_keyboardHeight()
        UIView.animate(withDuration: 0.25) {
            self.updatePosition()
        }
    }

    func didFinishedInputingCode(_ code: String) {
//        self.dismiss()
        self.completation?(.coded, code)
    }
}

public extension LBAlertView {

    static func showCustomView(_ customView: UIView?, _ title: String?, _ message: String?, _ cancelTitle: String?, _ okTitle: String?, _ config: @escaping LBAlertConfig, _ completation: @escaping LBAlertCompletation) -> Void {
        let v = LBAlertView.init(customView, title, message, cancelTitle, okTitle, config, completation)
        if customView is LBCodeView {
            (customView as! LBCodeView).delegate = v
        }
        v.show()
    }
    
    static func showCodeView(_ count:Int, _ title: String?, _ message: String?,  _ config:@escaping LBAlertConfig, _ completation: @escaping LBAlertCompletation) -> Void  {
        let v = LBCodeView(frame: CGRect(x: 0, y: 0, width: 100, height: 40), num: count, margin: 5)
        self.showCustomView(v, title, message, nil, nil, config, completation)
    }
    
    static func show(_ title: String?, _ message: String?, _ cancelTitle: String?, _ okTitle:String?, _ config:@escaping LBAlertConfig, _ completation: @escaping LBAlertCompletation) -> Void  {
        self.showCustomView(nil, title, message, cancelTitle, okTitle, config, completation)
    }
    static func dismiss() {
        if let views = UIApplication.shared.keyWindow?.subviews {
            for v in views.reversed() {
                if let alertV = v as? LBAlertView {
                    alertV.dismiss()
                }
            }
        }
    }
}

extension UILabel {
    func ajustedHeight(width:CGFloat, space:CGFloat) -> CGFloat {
        let font = self.font
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let text:String = self.text ?? ""
        if text.count == 0 {
            return 0
        }
        
        let lineBreakMode: NSLineBreakMode = self.lineBreakMode
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space
        paragraphStyle.lineBreakMode = lineBreakMode
        let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle]
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes as [String : Any], context:nil)
        return ceil(rect.size.height)
    }
    
}

extension CGRect {
    func lb_maxY(offset: CGFloat) -> CGFloat {
        if self.height > 0 {
            return self.maxY + offset
        }
        return self.maxY
    }
}

extension NSNotification {
    func lb_keyboardHeight() -> CGFloat {
        let userInfo: NSDictionary = self.userInfo! as NSDictionary
        let frameValue = (userInfo.object(forKey:UIKeyboardFrameEndUserInfoKey) as AnyObject).cgRectValue
        let height = frameValue?.height
        return height ?? 0
    }
}
