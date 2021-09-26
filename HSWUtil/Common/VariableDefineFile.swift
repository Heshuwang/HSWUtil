//
//  VariableDefineFile.swift
//  HSWUtil
//
//  Created by 何树旺 on 2021/9/23.
//

import UIKit


public let SCREEN_WIDTH = UIScreen.main.bounds.size.width

public let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

public let  ISIPad  = UIDevice.current.model == "iPad"

public let H_multiple = (ISIPad ? 1.5 : (SCREEN_WIDTH / 375.0)) // 水平倍数

public let V_multiple = (ISIPad ? 1.5 :(SCREEN_HEIGHT / 667.0))// 垂直倍数

public var kStatusHeight:CGFloat {
    return UIApplication.shared.statusBarFrame.height
}

public var kSystemVersion:String {
    return UIDevice.current.systemVersion
}

public let TABBAR_TABBAR_HEIGHT = UITabBarController().tabBar.frame.size.height

public var TABBAR_HEIGHT:CGFloat {
    if #available(iOS 11.0, *) {
        return TABBAR_TABBAR_HEIGHT + SWUtil.window.safeAreaInsets.bottom
    } else {
        return TABBAR_TABBAR_HEIGHT
    }
}

public var SAFEAREA_BOTTOM_HEIGHT:CGFloat {
    if #available(iOS 11.0, *) {
        return  SWUtil.window.safeAreaInsets.bottom
    } else {
        return 0.0
    }
}

public let STATUSBAR_HEIGHT:CGFloat = UIApplication.shared.statusBarFrame.size.height

public let NAVBAR_HEIGHT:CGFloat = UINavigationController().navigationBar.frame.size.height

public let STATUS_NAVBAR_HEIGHT:CGFloat = STATUSBAR_HEIGHT + NAVBAR_HEIGHT


//MARK: - 字体字号
public func FONT(_ size:CGFloat, NoMultiple without: Bool = false) -> UIFont {
    if without {
        return UIFont.systemFont(ofSize: size)
    }else {
        return UIFont.systemFont(ofSize: size*H_multiple)
    }
    
}
public func BOLDFONT(_ size:CGFloat, NoMultiple without: Bool = false) -> UIFont {
    if without {
        return UIFont.boldSystemFont(ofSize: size)
    }else {
        return UIFont.boldSystemFont(ofSize: size*H_multiple)
    }
}
public func MEDIUMFONT(_ size:CGFloat, NoMultiple without: Bool = false) -> UIFont {
    if without {
        return UIFont(name: "PingFangSC-Medium", size: size) ?? FONT(size, NoMultiple: true)
    }else {
        return UIFont(name: "PingFangSC-Medium", size: size*H_multiple) ?? FONT(size)
    }
}
public func DINFONT(_ size:CGFloat) -> UIFont {
    return UIFont(name: "DIN Alternate", size: size*H_multiple) ?? FONT(size)
}


//MARK:-其他
//版本号
public let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
