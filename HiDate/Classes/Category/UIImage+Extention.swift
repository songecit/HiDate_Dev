//
//  UIImage+Extention.swift
//  WeDate
//
//  Created by 靳志远 on 16/6/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

extension UIImage {
    /// 拉伸图片
    class func resizableImage(_ imageName: String) -> UIImage {
        var image = UIImage(named: imageName)
        let capInsets = UIEdgeInsetsMake((image?.size.height)! * 0.5, (image?.size.width)! * 0.5, (image?.size.height)! * 0.5, (image?.size.width)! * 0.5)
        image = image?.resizableImage(withCapInsets: capInsets, resizingMode: UIImageResizingMode.stretch)
        return image!
    }
    
    /// 根据颜色创建UIImage
    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /// 获取当前屏幕截图
    class func screenshot() -> UIImage {
        let window = UIApplication.shared.keyWindow!
        // 开启图形上下文
        UIGraphicsBeginImageContext(window.size)
        // 将window上的内容渲染到当前上下文中，参数1: 开启上下文内容范围大小；参数2: 是否是透明
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭图形上下文
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// 把图片等比例缩放指定的宽度
    func scaleToWidth(_ width: CGFloat) -> UIImage {
        if size.width < width {
            return self
        }
        
        // 比如传入的图片大小 : width: 1200 ,高度是 400
        // 知道缩放之后的宽度 --> 求出其对应的高度
        
        // width : 缩放之后的宽度 比如是600
        let height = width / size.width * size.height
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        // 1. 开启上下文
        UIGraphicsBeginImageContext(rect.size)
        
        // 2. 将图片绘制到上下文中
        draw(in: rect)
        // 3. 从上下文中获取到图片
        let result = UIGraphicsGetImageFromCurrentImageContext()
        // 4. 关闭上下文
        UIGraphicsEndImageContext()
        return result!
    }
}
