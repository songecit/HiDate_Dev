//
//  UIColor+Extention.swift
//  WeDate
//
//  Created by 靳志远 on 16/6/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

extension UIColor {
    /// 根据RGB设置颜色
    class func RGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    
    /// 根据十六进制值设置颜色
    class func hexValue(_ value: Int) -> UIColor {
        let r: CGFloat = CGFloat((value & 0xFF0000) >> 16) / 255
        let g: CGFloat = CGFloat((value & 0xFF00) >> 8) / 255
        let b: CGFloat = CGFloat((value & 0xFF)) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    /// 随机色
    class func randomColor() -> UIColor {
        return UIColor.RGB(red: CGFloat(arc4random() % 256), green: CGFloat(arc4random() % 256), blue: CGFloat(arc4random() % 256))
    }
}
