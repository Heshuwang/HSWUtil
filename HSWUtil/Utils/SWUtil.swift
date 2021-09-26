//
//  SWUtil.swift
//  HSWUtil
//
//  Created by 何树旺 on 2021/9/23.
//

import UIKit
import CommonCrypto

@objcMembers public class SWUtil: NSObject {
    static let share = SWUtil()
    
    // MARK: 打电话
    class func callTelNumber(number: String?) {
        guard let _ = number else { return }
        let string = "tel:\(number!)"
        if let url = URL(string: string) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: 使用‘*’隐藏部分信息
    
    /// prefixLength：前面几位不隐藏  suffixLength：后面几位不隐藏
    class func hiddenInfoWithAsterisk(_ originString: String, _ prefixLength: Int, _ suffixLength: Int) -> String {
        if prefixLength + suffixLength >= originString.count {
            return originString
        }
        let preString = originString.prefix(prefixLength)
        let sufString = originString.suffix(suffixLength)
        var hiddenString = ""
        let starCount = originString.count - prefixLength - suffixLength
        for _ in 0 ..< starCount {
            hiddenString.append("*")
        }
        return preString + hiddenString + sufString
    }
    
    // MARK: 保留几位小数
    
    class func getDigitsNumberAfterDecimalPoint(digitsNumber: Int, sourceString: Any, roundingMode: NSDecimalNumber.RoundingMode) -> String {
        let sourceStrFormat = "\(sourceString)"
        guard sourceStrFormat.contains(".") else { return sourceStrFormat }
        
        guard let decimalPart = sourceStrFormat.components(separatedBy: ".").last else { return sourceStrFormat }
        if decimalPart.count < digitsNumber {
            return sourceStrFormat
        } else {
            let roundingBehavior = NSDecimalNumberHandler(roundingMode: roundingMode, scale: Int16(digitsNumber), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
            let ouncesDecimal = NSDecimalNumber(value: Double(sourceStrFormat) ?? 0)
            let roundedOunces = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
            return "\(roundedOunces)"
        }
    }
    /*
     count：保留0-x位小数，默认2位
     效果：1.069->1.07 1.06->1.06 1.50->1.5 1.000->1
     优先判断numberString是否有值
     numberStyle：数字样式
     */
    //MARK:保留0-x位小数
    class func getNumberString(afterPoint count: Int = 2, number: Double? = nil, numberString: String? = nil, numberStyle: NumberFormatter.Style = .decimal, miniDigits: Int = 0) -> String?{
        let formatter = NumberFormatter()
        formatter.numberStyle = numberStyle
        formatter.minimumFractionDigits = miniDigits
        formatter.maximumFractionDigits = count
        if let numberString = numberString {
            if let result = formatter.string(from: NSNumber(value: Double(numberString) ?? 0.0)) {
                if result.hasPrefix(".") {
                    return "0" + result
                }else {
                    return result
                }
            }else {
                return nil
            }
        }
        if let result = formatter.string(from: NSNumber(value: number ?? 0.0)) {
            if result.hasPrefix(".") {
                return "0" + result
            }else {
                return result
            }
        }else {
            return nil
        }
        
    }
    // MARK: MD5加密
    
    class func md5(Str str: String) -> String {
        let cStr = str.cString(using: String.Encoding.utf8)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!, (CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString()
        for i in 0 ..< 16 {
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }
    
    // MARK: base64加密
    
    class func encodingBase64(String str: String) -> String {
        let data = str.data(using: String.Encoding.utf8)
        return (data?.base64EncodedString(options: .lineLength64Characters))!
    }
    
    // MARK: 将当前时间转换成毫秒时间
    
    class func changeNowDateToTimeStamp() -> Int {
        return Int(Date().timeIntervalSince1970)
    }
    
    // MARK: 根据给定颜色返回一张纯色图片
    
    class func createImageFrom(Color color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: 根据给定颜色、尺寸、方向渐变的图层，至少两种颜色
    
    class func createGradientLayerWithFrame(frame: CGRect, colors: Array<UIColor>, direction: DirectionType) -> CALayer {
        let gradient = CAGradientLayer()
        switch direction {
            case .up:
                gradient.startPoint = CGPoint(x: 0, y: 0)
                gradient.endPoint = CGPoint(x: 0, y: 1)
            case .left:
                gradient.startPoint = CGPoint(x: 0, y: 0)
                gradient.endPoint = CGPoint(x: 1, y: 0)
            case .down:
                gradient.startPoint = CGPoint(x: 0, y: 1)
                gradient.endPoint = CGPoint(x: 0, y: 0)
            case .right:
                gradient.startPoint = CGPoint(x: 1, y: 0)
                gradient.endPoint = CGPoint(x: 0, y: 0)
        }
        var mColors: Array<CGColor> = []
        for color in colors {
            mColors.append(color.cgColor)
        }
        gradient.colors = mColors
        gradient.frame = frame
        
        return gradient
    }
    
    // MARK: 全屏截图
    
    class func shotScreen() -> UIImage? {
        let window = self.window
        UIGraphicsBeginImageContext(window.bounds.size)
        window.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    // MARK: 富文本
    
    class func changeToAttributeStringWith(String string: String, IndexOfString index: Int, LengthOfString length: Int, StringFont font: UIFont, StringColor color: UIColor) -> NSMutableAttributedString {
        let attriString = NSMutableAttributedString(string: string)
        attriString.addAttribute(.font, value: font, range: NSMakeRange(index, length))
        attriString.addAttribute(.foregroundColor, value: color, range: NSMakeRange(index, length))
        return attriString
    }
    // MARK: 字符串转换成拼音
    class func stringToPinyin(string: String) -> String {
        var mutableString = NSMutableString(string: string)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        
        mutableString = NSMutableString(string: mutableString.folding(options: .diacriticInsensitive, locale: Locale.current))
        mutableString = NSMutableString(string: mutableString.replacingOccurrences(of: " ", with: ""))
        return mutableString.lowercased
    }
    
    // MARK: 字符串转换成首字母拼音
    class func stringToFirstPinyin(string: String) -> String {
        
        var mutableString = NSMutableString(string: string)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        mutableString = NSMutableString(string: mutableString.folding(options: .diacriticInsensitive, locale: Locale.current))
        let pinYinArr  = mutableString.components(separatedBy: " ")
        let  firstPinyinArr = pinYinArr.map { (pinyin) -> String in
            let position = pinyin.index(pinyin.startIndex, offsetBy: 0)
            return String(pinyin[position])
        }
        let firstStr = firstPinyinArr.joined(separator: "")
        //        mutableString = NSMutableString(string: mutableString.replacingOccurrences(of: " ", with: ""))
        return firstStr.lowercased()
    }
    
    
    // MARK: 图片处理
    /*
     压缩图片
     toLength：字节数
     */
    class func compressOriginalImage(image: UIImage, toLength: Int, completion: @escaping (Data) -> Void) {
        DispatchQueue.global().async {
            var scale = 0.9
            var scaleData = image.jpegData(compressionQuality: CGFloat(scale))
            while scaleData!.count > toLength {
                scale -= 0.1
                if scale < 0 {
                    break
                }
                scaleData = image.jpegData(compressionQuality: CGFloat(scale))!
            }
            
            DispatchQueue.main.async {
                completion(scaleData!)
            }
        }
    }
    
    
    // MARK: - Json相关
    
    class func jsonToDictionary(json: String?) -> [String: Any] {
        if let json = json {
            if let jsonData = json.data(using: .utf8) {
                if let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                    return dic
                } else {
                    return [String: Any]()
                }
            } else {
                return [String: Any]()
            }
        } else {
            return [String: Any]()
        }
    }
    
    // MARK: 字典转字符串
    class func jsonDicValueToString(dic:[String:Any]) -> String{
        let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        return str ?? ""
    }
    
    
    
    // MARK: - 其他
    
    class func makeTag(string: String?) -> String {
        if let s = string {
            return " " + s + " "
        }
        return ""
        
    }
    
    // MARK: 当前控制器
    
    class func getCurrentVC() -> UIViewController {
        var window = self.window
        if window.windowLevel != .normal {
            let windows = UIApplication.shared.windows
            for tempwin in windows {
                if tempwin.windowLevel == .normal {
                    window = tempwin
                    break
                }
            }
        }
        if (window.rootViewController?.isKind(of: UITabBarController.self))! {
            let tabbarViewCtrl = window.rootViewController as! UITabBarController as UITabBarController
            if (tabbarViewCtrl.selectedViewController?.isKind(of: UINavigationController.self))! {
                let navigationViewCtrl = tabbarViewCtrl.selectedViewController as! UINavigationController
                return navigationViewCtrl.visibleViewController!
            } else {
                return tabbarViewCtrl.selectedViewController!
            }
        } else if (window.rootViewController?.isKind(of: UINavigationController.self))! {
            let navigationViewCtrl = window.rootViewController as! UINavigationController
            return navigationViewCtrl.visibleViewController!
        } else {
            return (window.rootViewController)!
        }
    }
    
    // MARK: 是否是ipad
    class func isIpad() -> Bool {
        let deviceType = (UIDevice.current.userInterfaceIdiom == .pad)
        return deviceType
       
    }
    
    // MARK: 是不是所有子元素都是空
    class func elementsEmpty(array: Array<Any>) -> Bool {
        if array.count == 0 {
            return true
        }
        for datas in array {
            if datas is Array<Any> {
                if !elementsEmpty(array: datas as! Array<Any>) {
                    return false
                }
            }else {
                return false
            }
        }
        return true
    }
    // MARK: UIApplication.shared.delegate?.window
    static var window : UIWindow {
        if let wind = UIApplication.shared.delegate?.window, let window = wind {
            return window
        }else {
            for window in UIApplication.shared.windows {
                if window.isKind(of: UIWindow.self) {
                    return window
                }
            }
        }
        return UIApplication.shared.keyWindow!
    }

}

extension SWUtil {
    
    class func isValid(Num numString :String?)->Bool {
        guard let _ = numString else{
            return false
        }
        let number = "[0-9]*"
        let regextestNum = NSPredicate(format: "SELF MATCHES %@", number)
        return regextestNum.evaluate(with: numString)
    }
    
    
    
    // MARK: 判断手机号码合法性
    class func isValid(MobilePhone phone: String?) -> Bool {
        guard let _ = phone else {
            return false
        }
        if phone!.count != 11 {
            return false
        }

        let mobile = "^1[3|4|5|6|7|8|9]\\d{9}$"
        let regextestMoblie = NSPredicate(format: "SELF MATCHES %@", mobile)
        return regextestMoblie.evaluate(with: phone)
    }

    // MARK: 判断密码合法性

    class func isValid(Password password: String?) -> Bool {
        guard let _ = password else {
            return false
        }
        let pattern = "^[A-Za-z0-9_]{6,16}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: password)
    }

    // MARK: 判断邮箱格式

    class func isValid(Email email: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }

    // MARK: 判断身份证号

    class func isValid(IdentityNumber number: String) -> Bool {
        // 判断位数
        if number.count != 15 && number.count != 18 {
            return false
        }
        var carid = number
        var lSumQT = 0
        // 加权因子
        let R = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        // 校验码
        let sChecker: [Int8] = [49, 48, 88, 57, 56, 55, 54, 53, 52, 51, 50]
        // 将15位身份证号转换成18位
        let mString = NSMutableString(string: number)

        if number.count == 15 {
            mString.insert("19", at: 6)
            var p = 0
            let pid = mString.utf8String
            for i in 0 ... 16 {
                let t = Int(pid![i])
                p += (t - 48) * R[i]
            }
            let o = p % 11
            let stringContent = NSString(format: "%c", sChecker[o])
            mString.insert(stringContent as String, at: mString.length)
            carid = mString as String
        }

        let cStartIndex = carid.startIndex
        let cEndIndex = carid.endIndex
        let index = carid.index(cStartIndex, offsetBy: 2)
        // 判断地区码
        let sProvince = String(carid[cStartIndex ..< index])
        if !areaCodeAt(sProvince) {
            return false
        }

        // 判断年月日是否有效
        // 年份
        let yStartIndex = carid.index(cStartIndex, offsetBy: 6)
        let yEndIndex = carid.index(yStartIndex, offsetBy: 4)
        let strYear = Int(carid[yStartIndex ..< yEndIndex])

        // 月份
        let mStartIndex = carid.index(yEndIndex, offsetBy: 0)
        let mEndIndex = carid.index(mStartIndex, offsetBy: 2)
        let strMonth = Int(carid[mStartIndex ..< mEndIndex])

        // 日
        let dStartIndex = carid.index(mEndIndex, offsetBy: 0)
        let dEndIndex = carid.index(dStartIndex, offsetBy: 2)
        let strDay = Int(carid[dStartIndex ..< dEndIndex])

        let localZone = NSTimeZone.local

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = localZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let date = dateFormatter.date(from: "\(String(format: "%02d", strYear!))-\(String(format: "%02d", strMonth!))-\(String(format: "%02d", strDay!)) 12:01:01")
        if date == nil {
            return false
        }
        let paperId = carid.utf8CString
        // 检验长度
        if 18 != carid.count {
            return false
        }
        // 校验数字
        func isDigit(c: Int) -> Bool {
            return 0 <= c && c <= 9
        }
        for i in 0 ... 18 {
            let id = Int(paperId[i])
            if isDigit(c: id) && !(88 == id || 120 == id) && 17 == i {
                return false
            }
        }
        // 验证最末的校验码
        for i in 0 ... 16 {
            let v = Int(paperId[i])
            lSumQT += (v - 48) * R[i]
        }
        if sChecker[lSumQT % 11] != paperId[17] {
            return false
        }
        return true
    }

    class func areaCodeAt(_ code: String) -> Bool {
        var dic: [String: String] = [:]
        dic["11"] = "北京"
        dic["12"] = "天津"
        dic["13"] = "河北"
        dic["14"] = "山西"
        dic["15"] = "内蒙古"
        dic["21"] = "辽宁"
        dic["22"] = "吉林"
        dic["23"] = "黑龙江"
        dic["31"] = "上海"
        dic["32"] = "江苏"
        dic["33"] = "浙江"
        dic["34"] = "安徽"
        dic["35"] = "福建"
        dic["36"] = "江西"
        dic["37"] = "山东"
        dic["41"] = "河南"
        dic["42"] = "湖北"
        dic["43"] = "湖南"
        dic["44"] = "广东"
        dic["45"] = "广西"
        dic["46"] = "海南"
        dic["50"] = "重庆"
        dic["51"] = "四川"
        dic["52"] = "贵州"
        dic["53"] = "云南"
        dic["54"] = "西藏"
        dic["61"] = "陕西"
        dic["62"] = "甘肃"
        dic["63"] = "青海"
        dic["64"] = "宁夏"
        dic["65"] = "新疆"
        dic["71"] = "台湾"
        dic["81"] = "香港"
        dic["82"] = "澳门"
        dic["91"] = "国外"
        if dic[code] == nil {
            return false
        }
        return true
    }
    
    
    // MARK: 判断银行卡号
    class func isValid(BankCard cardNumber: String?) -> Bool {
    
        var oddSum: Int = 0 // 奇数和
        var evenSum: Int = 0 // 偶数和
        var allSum: Int = 0 // 总和
        guard let _ = cardNumber else { return false }
        guard !cardNumber!.isEmpty else { return false }
        // 循环加和
        for i in 1 ... (cardNumber!.count) {
            guard let theNumber = (cardNumber as NSString?)?.substring(with: NSRange(location: (cardNumber?.count ?? 0) - i, length: 1)) else { return false }
            guard let theNumberInt = Int(theNumber) else { return false }
            var lastNumber = Int(truncating: NSNumber(value: theNumberInt))
            if i % 2 == 0 {
                // 偶数位
                lastNumber *= 2
                if lastNumber > 9 {
                    lastNumber -= 9
                }
                evenSum += lastNumber
            } else {
                // 奇数位
                oddSum += lastNumber
            }
        }
        allSum = oddSum + evenSum
        // 是否合法
        if allSum % 10 == 0 {
            return true
        } else {
            return false
        }
    }

    // MARK: 判断字符串中是否全是汉字

    class func isAllChineseInString(string: String) -> Bool {
        for (_, value) in string.enumerated() {
            if "\u{4E00}" > value || value > "\u{9FA5}" {
                return false
            }
        }
        return true
    }
    
    // MARK: 判断字符串中是否包含汉字
    class func isThereChineString(string: String) -> Bool {
        for (_, value) in string.enumerated() {
            if "\u{4E00}" < value  && value < "\u{9FA5}" {
                return true
            }
        }
        return false
    }
    

    // MARK: 判断是否为整型
    class func isPureInteger(string: String?) -> Bool {
        guard let str = string else { return false }
        let scanner = Scanner(string: str)
        var val: Int = 0
        return scanner.scanInt(&val) && scanner.isAtEnd
    }

    // MARK: 判断字符串条件 1:数字 2:英文 3:符合的英文+数字

    class func isHaveNumAndLetter(String string: String) -> Int {
        do {
            let tNumRegularExpression = try NSRegularExpression(pattern: "[0-9]", options: .caseInsensitive)
            let tNumMatchCount: Int = tNumRegularExpression.numberOfMatches(in: string, options: .reportProgress, range: NSMakeRange(0, string.count))

            let tLetterRegularExpression = try NSRegularExpression(pattern: "[A-Za-z]", options: .caseInsensitive)
            let tLetterMatchCount: Int = tLetterRegularExpression.numberOfMatches(in: string, options: .reportProgress, range: NSMakeRange(0, string.count))

            if tNumMatchCount == string.count {
                return 1
            } else if tLetterMatchCount == string.count {
                return 2
            } else if tNumMatchCount + tLetterMatchCount == string.count {
                return 3
            } else {
                return 4
            }
        } catch { return 0 }
    }

    // MARK: 判断字符串是否存在

    class func isBlankString(String string: String?) -> String {
        if nil == string {
            return ""
        }

        return string!
    }
}


// MARK: - Date相关
extension SWUtil {
    //MARK: 日期转字符串
    class func dateToString(date: Date, formatter: String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = NSTimeZone.local
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    //MARK:  字符串转日期
    class func stringToDate(string: String, formatter: String? = "yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = formatter
        let date = dateFormatter.date(from: string)
        return date!
    }
    
    //MARK:  字符串转字符串  useMillisecond是否含毫秒
    class func fullDateStringToYMDDateString(fullString: String, fullFormatter: String = "yyyy-MM-dd HH:mm:ss", formatter: String = "yyyy-MM-dd", useMillisecond: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        if useMillisecond {
            dateFormatter.dateFormat = fullFormatter + ".SSS"
        } else {
            dateFormatter.dateFormat = fullFormatter
        }
        if let date = dateFormatter.date(from: fullString) {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = formatter
            
            let dateString = dateFormatter2.string(from: date)
            return dateString
        }
        return "无"
    }
    
    //MARK:  获取当前时间的年月日时分秒组件，默认今天
    ///获取当前时间的年月日时分秒组件，默认今天
    class func dateComponents(date: Date = Date()) -> DateComponents {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = NSTimeZone.local
        var comps = DateComponents()
        comps = calendar.dateComponents(Set(arrayLiteral: .year, .month, .day, .weekday, .hour, .minute, .second), from: date)
        return comps
    }
    
    
    /// 获取日期的之前几个月时间
    /// - Parameters:
    ///   - date: 依据时间
    ///   - month: 之前几个月
    /// - Returns: <#description#>
    class func getPriousorLaterDate(date:Date? = Date(), month:Int) -> NSDate {
        
        var dateFormatter = DateComponents()
        dateFormatter.month = month
        let calender = Calendar.current
        
        //把日期转成当前月1号
        var com = calender.dateComponents([.year, .month ,.day], from: date!)
        com.day = 1
        let newDate = calender.date(from: com)
        
        let adjustTimer = calender.date(byAdding: dateFormatter, to: newDate!)
        return adjustTimer! as NSDate
    }
    
    //时间转换成 --几天几小时几分几秒
    class func secondTransToDate(totalSecond: NSInteger) -> String{
        let second = totalSecond % 60
        let minute = (totalSecond / 60) % 60;
        let  hours = (totalSecond / 3600) % 24;
        let  days = totalSecond / (24*3600);
        
        var secondStr = "\(second)"
        var minuteStr = "\(minute)"
        var hoursStr = "\(hours)"
        var dayStr = "\(days)"

        if second < 10 {
            secondStr = "0\(second)"
        }
        if minute < 10 {
            minuteStr = "0\(minute)"
        }
        if hours < 10 {
            hoursStr = "0\(hours)"
        }
        if days < 10 {
            dayStr = "0\(days)"
        }
        if days <= 0 {
            return "\(hoursStr):\(minuteStr):\(secondStr)"
        }
        return "\(dayStr)天\(hoursStr):\(minuteStr):\(secondStr)"
    }
    
}


// MARK: - 存储相关
extension SWUtil {
    // MARK: 获取缓存目录的大小
    static var cacheSize: String {
        get {
            let basePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
            let fileManager = FileManager.default
            
            var totalCache : CGFloat {
                var total: CGFloat = 0
                if fileManager.fileExists(atPath: basePath!) {
                    let childrenPath = fileManager.subpaths(atPath: basePath!)
                    if let childrenPath = childrenPath {
                        for path in childrenPath {
                            let childPath = basePath!.appending("/").appending(path)
                            do{
                                let attri = try fileManager.attributesOfItem(atPath: childPath)
                                let fileSize = attri[FileAttributeKey.size] as! CGFloat
                                total += fileSize
                            } catch {
                                
                            }
                        }
                    }
                }
                return total
            }
            return String(format: "%.2fM", totalCache / (1024 * 1024))
        }
    }
    // MARK: 删除缓存目录
    class func clearCache(_ block: @escaping (Bool) -> Void) {
        var result = true
        let basePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let fileManager = FileManager.default
        DispatchQueue.global().async {
            if fileManager.fileExists(atPath: basePath!) {
                let childrenPath = fileManager.subpaths(atPath: basePath!)
                for childPath in childrenPath! {
                    let cachePath = basePath!.appending("/").appending(childPath)
                    if fileManager.fileExists(atPath: cachePath) {
                        do {
                            try fileManager.removeItem(atPath: cachePath)
                        } catch {
                            result = false
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                block(result)
            }
        }
    }

    // MARK: 存入偏好设置
    class func SET_USER_DEFAULTS(Key key: String, Value value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: 取偏好设置
    
    class func GET_USER_DEFAULTS(Key key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key) ?? ""
    }
    
}

extension SWUtil{
    //UIScrollView截屏
    class func screenScorllViewShot(view:UIScrollView? = UIScrollView()) -> UIImage? {
        
        var image: UIImage? = nil
        let savedContentOffset = view!.contentOffset
        let savedFrame = view!.frame
        
        view?.contentOffset = .zero
        view?.frame =  CGRect(x: 0, y: 0,
                              width: view!.contentSize.width,
                              height: view!.contentSize.height)
        
        let view1 = UIView.init(frame: view!.bounds);
        view1.backgroundColor = UIColor(patternImage:UIImage(named: "watermark_icon")!)
        view?.addSubview(view1);
        
        UIGraphicsBeginImageContext(view!.frame.size)
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: view!.frame.size.width,
                   height: view!.frame.size.height),
            false,
            UIScreen.main.scale)
        view?.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view?.contentOffset = savedContentOffset
        view?.frame = savedFrame
        view1.removeFromSuperview()
        return image
    }

    //uiview截屏
    class func screenViewShot(view:UIView?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view!.frame.size,false,UIScreen.main.scale)
        view?.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


extension SWUtil {
    /// 获取视图在window位置
    /// - Parameter view: 获取位置的视图
    class func getViewToScreenPosition(onView view:UIView) -> CGRect {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let senderFrame : CGRect = view.convert(view.bounds, to: window)
        return senderFrame
    }
    
}
