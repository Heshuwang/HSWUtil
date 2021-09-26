//
//  NSLayoutConstraint+extension.swift
//  HSWUtil
//
//  Created by 何树旺 on 2021/9/23.
//

import UIKit


public extension NSLayoutConstraint{
    //约束等比
    @IBInspectable var adapterScreen: Bool {
        get {
            return true
        }
        
        set {
            if newValue {
                self.constant = self.constant * H_multiple
            }
        }
    }
}


public extension UIButton {
    @IBInspectable var FontIB : CGFloat {
        set{
            if newValue > 0 {
                if titleLabel!.font.fontName.hasSuffix("Medium") {
                    titleLabel!.font = MEDIUMFONT(newValue)
//                        UIFont(name: titleLabel!.font.fontName, size: newValue * H_multiple)
                }else if titleLabel!.font.fontName.hasSuffix("Body"){
                    titleLabel!.font = BOLDFONT(newValue)
                }
                else{
                    titleLabel!.font = FONT(newValue)
                }
            }
        }
        get{
            return titleLabel!.font.pointSize
        }
    }
}

public extension UITextView {
    @IBInspectable  var FontIB : CGFloat {
        set{
            if newValue > 0 {
                if font!.fontName.hasSuffix("Medium") {
                    font = MEDIUMFONT(newValue)
                }else if font!.fontName.hasSuffix("Body"){
                    font = BOLDFONT(newValue)
                }else{
                    font = FONT(newValue)
                }
            }
        }
        
        get{
            return font!.pointSize
        }
    }
}

public extension UITextField {
    @IBInspectable  var FontIB : CGFloat {
        set{
            if newValue > 0 {
                if font!.fontName.hasSuffix("Medium") {
                    font = MEDIUMFONT(newValue)
                }else if font!.fontName.hasSuffix("Body"){
                    font = BOLDFONT(newValue)
                }else{
                    font = FONT(newValue)
                }
//                font = UIFont(name: font!.fontName, size: font!.pointSize * H_multiple)
            }
        }
        get{
            return font!.pointSize
        }
    }
}


