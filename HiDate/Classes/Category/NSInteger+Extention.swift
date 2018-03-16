//
//  NSInteger+Extention.swift
//  HiDate
//
//  Created by 靳志远 on 16/6/24.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

extension NSInteger {
    /// 数量处理（大于一万显示：x.万）
    func formatCount() -> String {
        var text: String?
        
        if self > 10000 {
            let floatValue = Float(self) / 10000.0
            text = String(format: "%0.1f万", arguments: [floatValue])
            
        }else {
            text = "\(self ?? 0)"
        }
        return text!
    }
}



