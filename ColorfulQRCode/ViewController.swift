//
//  ViewController.swift
//  ColorfulQRCode
//
//  Created by zhaotaoyuan on 2018/6/21.
//  Copyright © 2018年 DoMobile21. All rights reserved.
//

import UIKit

//实现渐变色qrcode
//1.最底层先放一个CAGradientLayer，实现彩色
//2.在CAGradientLayer制定一个masklayer，masklayer的content为 “qrcode”
//3.qrcode经过特殊处理，白色部分透明，黑色部分不透明。(mask遮罩的部分，原始的layer在不透明的地方才会被显示，即黑色部分被显示，白色部分被隐藏)


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let qrview = UIImageView()
        let testStr = "https://www.baidu.com"
        let qrimg = QRCode.createQRForString(qrString: testStr)
        let maskImage = processImageToMask(qrimg)

        let testv = UIView()
        testv.backgroundColor = UIColor.white
        testv.layer.addSublayer(colorLayer)
        testv.center = view.center
        testv.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
        colorLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

        let maskLayer = CALayer()
        maskLayer.contents = maskImage.cgImage
        maskLayer.frame = colorLayer.bounds
        colorLayer.mask = maskLayer
        
        view.addSubview(testv)
        
    }
    
    //图片处理，白色的变透明
    func processImageToMask(_ image: UIImage) -> UIImage {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let pixBuffer = UnsafeMutableRawPointer.allocate(byteCount: width * height * 4, alignment: 8)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext.init(data: pixBuffer, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        UIGraphicsPushContext(ctx!)
        image.draw(at: CGPoint.zero)
        UIGraphicsPopContext()
        //argb
        for row in 0..<height {
            for col in 0..<width {
                let offset = row * width * 4 + col * 4
                let red = pixBuffer.load(fromByteOffset: offset + 1, as: UInt8.self)
                //>100为白色，alpha变透明，
                if red > 100 {
                    pixBuffer.storeBytes(of: 0, toByteOffset: offset, as: UInt8.self)
                } else {
                    pixBuffer.storeBytes(of: 255, toByteOffset: offset, as: UInt8.self)
                }
            }
        }
        
        let image = ctx?.makeImage()
        
        
        return UIImage.init(cgImage: image!)
    }
    
    
    var colorLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.red.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

