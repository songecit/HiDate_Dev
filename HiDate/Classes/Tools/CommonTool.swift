//
//  CommonTool.swift
//  WeDate
//
//  Created by 靳志远 on 16/6/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

class CommonTool: NSObject {
    /// 获取当前版本号
    class func getCurrentVersion() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    /// 数量处理（大于一万显示：x.万）
    class func handleCount(_ count: NSInteger) -> String {
        var text: String?
        
        if count > 10000 {
            let floatValue = Float(count) / 10000.0
            text = String(format: "%0.1f万", arguments: [floatValue])
            
        }else {
            text = "\(count )"
        }
        return text!
    }
    
    /// 将date(出生日期)转换为年龄
    class func dateToAge(_ date: Date) -> String {
        let component = (Calendar.current as NSCalendar).components([.day, .month, .year], from: date)
        let year = component.year
        
        let componentNow = (Calendar.current as NSCalendar).components([.day, .month, .year], from: Date())
        let currentYear = componentNow.year
        
        let resultAge: Int = currentYear! - year!
        return String(format: "%d", arguments: [resultAge])
    }
}



