//
//  HDVersionTool.swift
//  HiDate
//
//  Created by qidangsong on 16/6/28.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

class HDVersionTool: NSObject {
    // 应用版本
    class func getCurrentBundleShortVersion() -> String {
        
        return (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
    }
    
    // 应用Build版本
    class func getCurrentBundleVersion() -> String {
        
        return (Bundle.main.infoDictionary!["CFBundleVersion"] as? String)!
    }
}
