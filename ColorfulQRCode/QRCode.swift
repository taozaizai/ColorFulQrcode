//
//  QRCode.swift
//  ColorfulQRCode
//
//  Created by zhaotaoyuan on 2018/6/21.
//  Copyright © 2018年 DoMobile21. All rights reserved.
//

import UIKit

class QRCode: NSObject {
    /// 绘制二维码
    ///
    /// - Parameters:
    ///   - qrString: 二维码内容
    ///   - qrImage: 二维码logo
    /// - Returns: 二维码图片
    static func createQRForString(qrString:String, qrImage:UIImage? = nil, retainWhite: Bool = false) -> UIImage {
        // 将字符串转换为二进制
        let data = qrString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        let qrCIImage = filter.outputImage
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrCIImage, forKey: "inputImage")
        
        colorFilter.setValue(CIColor.init(color: UIColor.black), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        
        var codeImage = UIImage(ciImage: colorFilter.outputImage!.transformed(by: CGAffineTransform(scaleX: 6, y: 6)))
        
        //因为codeimage的cgimage为nil，故先将codeimage画出来，获取到有cgimage的image之后再进行切割
        //去掉5px的白边
        if !retainWhite {
            UIGraphicsBeginImageContext(codeImage.size)
            codeImage.draw(in: CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height))
            let new = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            let inset = CGFloat(3)
            let newRect = CGRect(x: inset+1, y: inset, width: (new?.size.width)! - 2 * (inset+1), height: (new?.size.height)! - 2 * inset)
            let cgimage = new?.cgImage?.cropping(to: newRect)
            codeImage = UIImage.init(cgImage: cgimage!)
        }
        
        //内嵌logo
        if qrImage != nil {
            if let iconImage = qrImage {
                let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
                
                UIGraphicsBeginImageContextWithOptions(rect.size, true, UIScreen.main.scale)
                codeImage.draw(in: rect)
                //logo大小不能大于二维码大小的四分之一，否则会遮挡住数据区域
                let avatarSize = CGSize(width: 20, height: 20)
                let x = (rect.width - avatarSize.width) / 2
                let y = (rect.height - avatarSize.height) / 2
                iconImage.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                return resultImage!
            }
        }
        
        return codeImage
    }
    
    
}
