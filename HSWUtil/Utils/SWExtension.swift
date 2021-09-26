//
//  SWExtension.swift
//  HSWUtil
//
//  Created by 何树旺 on 2021/9/23.
//

import Foundation
import UIKit

//UIKit  扩展


public enum DirectionType {
    case up
    case left
    case down
    case right
}

/// 像素，每个像素包含红，蓝，绿，透明度
public struct CWPixel {
    // 完整像素值
    var value: UInt32
    
    // 红色值
    var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = UInt32(newValue) | (value & 0xFFFFFF00)
        }
    }
    
    // 绿色
    var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    // 蓝色
    var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    // 透明
    var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
    
    // 是否为白色
    var isWhite: Bool {
        get {
            return value == 0xFFFFFFFF
        }
    }
}




//MARK: - UIView
public extension UIView{
    
    
    
    
}


//MARK: - UIResponder
public extension UIResponder {
    
    @objc func router(eventName: String, userInfo:[String: Any]?) {
        if let next = next {
            next.router(eventName: eventName, userInfo: userInfo)
        }
        
    }
    
}



//MARK: - UIColor
public extension UIColor {
    convenience init(hex: String, _ alpha: CGFloat = 1) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: alpha
        )
    }
}






//MARK:- UIButton
public extension UIButton {
    func layout(ImageSpace space: CGFloat,ImageIs type:DirectionType) {
        let imageWidth = imageView?.image?.size.width as! CGFloat
        let imageHeight = imageView?.image?.size.height as! CGFloat
        var labelWidth:CGFloat = 0.0
        var labelHeight:CGFloat = 0.0
        let versionString: NSString = UIDevice.current.systemVersion as NSString
        if versionString.floatValue >= 8.0{
            labelWidth = titleLabel?.intrinsicContentSize.width as! CGFloat
            labelHeight = titleLabel?.intrinsicContentSize.height as! CGFloat
        }else {
            labelWidth = titleLabel?.frame.size.width as! CGFloat
            labelHeight = titleLabel?.frame.size.height as! CGFloat
        }
        
        var imageEdgeInsets = UIEdgeInsets()
        var titleEdgeInsets = UIEdgeInsets()
        
        switch type {
        case .up:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight-space/2.0, left: 0, bottom: 0, right: -labelWidth)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: -imageHeight-space/2.0, right: 0)
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -space/2.0, bottom: 0, right: space/2.0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: space/2.0, bottom: 0, right: -space/2.0)
        case .down:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight-space/2.0, right: -labelWidth)
            titleEdgeInsets = UIEdgeInsets(top: -imageHeight-space/2.0, left: -imageWidth, bottom: 0, right: 0)
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+space/2.0, bottom: 0, right: -labelWidth-space/2.0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth-space/2.0, bottom: 0, right: imageWidth+space/2.0)
        }
        self.titleEdgeInsets = titleEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
    
}


//MARK: UIImage
public extension UIImage {
    //根据颜色生成图片
    class func imageWithColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    //自定义图片大小
    func imageScaleSize(newSize: CGSize) -> UIImage?{
        let width = Int(newSize.width)
        let height = Int(newSize.height)
        UIGraphicsBeginImageContext(CGSize(width: width, height: height));
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? nil
        UIGraphicsEndImageContext();
        return newImage;
    }
    

    //生成二维码
    class func cwQRCodeImage(content: String,
                                 logo: UIImage? = nil,
                                 logoFrame: CGRect = CGRect.zero,
                                 size: CGFloat = -1,
                                 highCorrection: Bool = false,
                                 tintColor: UIColor? = nil) -> UIImage? {
            var retImage: UIImage? = nil
            var openHighCorrection = highCorrection
            
            // 如果要添加logo或者绘制颜色，自动开启高容错
            if logo != nil || tintColor != nil {
                openHighCorrection = true
            }
            let correctionLevel = openHighCorrection ? "H" : "M"
            
            // 生成二维码并设置纠错级别
            let outputImage = qrCodeOutputImage(content: content,
                                                correctionLevel: correctionLevel)
            if let output = outputImage {
                // 调整尺寸之后的二维码
                retImage = adjustHDQRCode(outputImage: output,
                                          size:size)
            }
            // 二维码着色
            if let mTintColor = tintColor {
                retImage = retImage?.cwModifyTintColor(tintColor: mTintColor)
            }
            // 二维码添加logo
            if let mLogo = logo {
                retImage = retImage?.cwAddLogoImage(image: mLogo,
                                                    frame: logoFrame)
            }
            return retImage
        }
        
        
        /// 生成原始二维码CIImage
        ///
        /// - Parameters:
        ///   - content: 二维码包含的内容
        ///   - correctionLevel: 二维码纠错级别
        ///   ，调高纠错级别可以往上面加一个头像或者变色，但是识别速度也会降低
        /// - correctionLevel:
        ///   - 二维码纠错级别,通过调高二维码的纠错级别可以往上面加一个头像或者变色，但是识别速度也会降低
        ///   - L（低） 7％的码字可以被恢复。
        ///   - M（中） 15％的码字可以被恢复。
        ///   - Q（四分）25％的码字可以被恢复。
        ///   - H（高） 30％的码字可以被恢复。
        private class func qrCodeOutputImage(content: String,
                                             correctionLevel: String) -> CIImage? {
            // 初始化filter
            let data = content.data(using: .utf8)
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")
            // 设置内容
            qrFilter?.setValue(data, forKey: "inputMessage")
            qrFilter?.setValue(correctionLevel, forKey: "inputCorrectionLevel")
            return qrFilter?.outputImage
        }
        
        /// 调整二维码的尺寸并返回高清图片
        /// - Code:
        ///   - let transform = CGAffineTransform(scaleX: 5, y: 5)
        ///   - outputImage?.transformed(by: transform)
        ///
        /// - Parameters:
        ///   - outputImage: CIFilter生成的二维码
        ///   - size: 放大之后的尺寸
        /// - Returns: 返回调整之后的图片
        private class func adjustHDQRCode(outputImage: CIImage,
                                          size: CGFloat) -> UIImage? {
            
            let integralRect: CGRect = outputImage.extent.integral
            // 设置默认放大5倍
            var scale: CGFloat = 5.0
            if size != -1 {
                // 需要计算出最佳缩放比例
                scale = min(size/integralRect.width, size/integralRect.height)
            }
            
            let width = integralRect.width * scale
            let height = integralRect.height * scale
            
            let colorSpaceRef = CGColorSpaceCreateDeviceGray()
            let bitmapRef = CGContext(data: nil,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpaceRef,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue)
            
            let context = CIContext(options: nil)
            
            //放大重新绘制
            if let bitmapImage = context.createCGImage(outputImage,
                                                       from: integralRect) {
                bitmapRef?.interpolationQuality = .none
                bitmapRef?.scaleBy(x: scale, y: scale)
                bitmapRef?.draw(bitmapImage, in: integralRect)
            }
            
            let scaledImage: CGImage! = bitmapRef?.makeImage()
            return UIImage(cgImage: scaledImage)
        }
        
        /// 改变二维码图片的像素的颜色
        private func cwModifyTintColor(tintColor: UIColor) -> UIImage {
            
            // 必须可以转换为CGImage
            guard let mCgImage = self.cgImage else {
                return self
            }
            
            // 将Float类型保存为Int进行地址操作
            let width = Int(self.size.width)
            let height = Int(self.size.height)
            
            // 创建一个大小为 4 * width * height 的缓存区
            let bytesPerRow = width * 4
            let byteSize = width * height
        
            // 初始化一个指针类型并分配空间
            let rgbImageBuf = UnsafeMutablePointer<CWPixel>.allocate(capacity: byteSize)
            
            
            // 初始化绘制，颜色空间跟随设备
            let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
            // 用BGRA创建一个位图
            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
            bitmapInfo = bitmapInfo | CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            
            // 创建位图
            guard let context = CGContext(data: rgbImageBuf,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: 8,
                                          bytesPerRow: bytesPerRow,
                                          space: colorSpaceRef,
                                          bitmapInfo: bitmapInfo)  else {
                return self
            }
            
            // 使用rgbImageBuf 填充 mCgImage
            context.draw(mCgImage, in: CGRect(origin: .zero, size: self.size))
            
            
           // 连续存储的内存集合
            var bufferPointer = UnsafeMutableBufferPointer<CWPixel>(start: rgbImageBuf,
                                                                    count: byteSize)

            // 释放分配的空间
    //        rgbImageBuf.deallocate()
            
            //获取红绿蓝色值
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // 遍历像素，改变像素点颜色
            for currentPixel in 0..<byteSize {
                var pixel = bufferPointer[currentPixel]
                if !pixel.isWhite {
                    //当不是白色的时候才使用
                    pixel.red = UInt8(red * 255)
                    pixel.green = UInt8(green * 255)
                    pixel.blue = UInt8(blue * 255)
    //                pixel.alpha = UInt8(alpha * 255)
                    let retPixel = pixel
                    bufferPointer[currentPixel] = retPixel
                }
            }
            
            let inputColorSpace = CGColorSpaceCreateDeviceRGB()
            var inputBitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
            let inputBytesPerRow = width * 4
            
            inputBitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            
            guard let imageContext = CGContext(data: bufferPointer.baseAddress,
                                               width: width,
                                               height: height,
                                               bitsPerComponent: 8,
                                               bytesPerRow: inputBytesPerRow,
                                               space: inputColorSpace,
                                               bitmapInfo: inputBitmapInfo,
                                               releaseCallback: nil,
                                               releaseInfo: nil) else {
                return self
            }
            
            guard let cgImage = imageContext.makeImage() else {
                return self
            }
            
            let image = UIImage(cgImage: cgImage)
            return image
        }
        
        /// 给二维码图片添加logo
        private func cwAddLogoImage(image: UIImage,
                                    frame: CGRect) -> UIImage? {
            var resultImage: UIImage? = nil
            if frame != CGRect.zero {
                // 开始绘制
                UIGraphicsBeginImageContext(self.size)
                //绘制二维码图片
                self.draw(in: CGRect.init(origin: CGPoint.zero,
                                          size:self.size))
                //绘制Logo
                image.draw(in: frame)
                //获取绘制之后的image
                resultImage = UIGraphicsGetImageFromCurrentImageContext();
                //结束绘制
                UIGraphicsEndImageContext();
            }
            return resultImage
        }
    
}




//MARK: String
public extension String {
    //计算文本宽度
    func size(font: UIFont, in size:CGSize) -> CGSize {
        let strSize = (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:font], context: nil).size
        return strSize
    }
    
    //计算文本高度
    func height(font: UIFont, in width:CGFloat) -> CGFloat {
        let stringSize = self.size(font: font, in: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return stringSize.height
    }
    
    //移除空格
    func removeWhiteSpace() -> String {
        return components(separatedBy: NSCharacterSet.whitespaces).joined(separator: "")
    }
    
    
    ///货币转化  numberStyle 类型   digits 保留小数点位数
    func currencyWithNumberFormatter(numberStyle: NumberFormatter.Style = .decimal, digits:Int? = 2) -> String {
      //        decimal //1,234,567.89
      //        currency //￥1,234,567.89
      //        currencyAccounting//￥1,234,567.89
        let format  = NumberFormatter()
        format.numberStyle = numberStyle
        format.maximumFractionDigits = digits! //设置小数点
        format.minimumFractionDigits = digits!
        let  string = format.string(from: NSNumber(value:Float(self) ?? 0.0))
        return string!
    }
    
    
    //  从0索引出开始查找是否包含着指定字符 返回Int类型索引
     ///    返回第一个出现的指定字段
     /// - Parameters:
     ///   - sub: 包含字段
     /// - Returns: 返回索引
     func findFirst(sub:String) -> Int {
         var  pos = -1
         if let range = range(of: sub, options: .literal) {
             if !range.isEmpty {
                pos =  self.distance(from: startIndex, to: range.lowerBound)
             }
         }
        return pos
     }
}





//MARK: - Array
public extension Array {
    
    subscript (safe index: Int) -> Element? {
        return (0 ..< count).contains(index) ? self[index] : nil
    }
    

    // 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}




