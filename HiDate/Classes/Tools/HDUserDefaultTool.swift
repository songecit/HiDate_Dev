//
//  HDUserDefaultTool.swift
//  HiDate
//
//  Created by qidangsong on 16/8/10.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import Foundation

class HDUserDefaultTool: NSObject {
    
    // H5App的时间
    class func updateH5AppTime(_ time: String) {
        UserDefaults.standard.set(time, forKey: "H5AppUpdateTime");
    }
    
    class func getH5AppTime() -> String {
        let time = UserDefaults.standard.object(forKey: "H5AppUpdateTime");
        if (time != nil) {
            return time as! String;
        } else {
            return "-1";
        }
    }
    
    // H5App 在沙盒中的路径
    class func updateH5AppSanboxPath(_ path: String) {
        UserDefaults.standard.set(path, forKey: "H5AppSanboxPath");
    }
    
    class func getH5AppSanboxPath() -> String? {
        return (UserDefaults.standard.object(forKey: "H5AppSanboxPath")) as? String;
    }
    
    // h5 app.json的last modify
    class func updateH5AppjsonLastModify(_ gmtTime: String) {
        UserDefaults.standard.set(gmtTime, forKey: "H5AppjsonLastModify");
    }
    
    class func getH5AppjsonLastModify() -> String? {
        return (UserDefaults.standard.object(forKey: "H5AppjsonLastModify")) as? String;
    }
    
    // h5 的版本号
    class func updateH5AppUpdateVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: "H5AppUpdateVersion");
    }
    
    class func getH5AppUpdateVersion() -> String? {
        return (UserDefaults.standard.object(forKey: "H5AppUpdateVersion")) as? String;
    }
    
    // 将受到融云消息时的处理规则保存
    class func updateRCMessageHandleRule(_ rule: [AnyObject]) {
        UserDefaults.standard.set(rule, forKey: "RCMsgHandlers");
    }
    
    class func getRCMessageHandleRule() -> [AnyObject]? {
        return (UserDefaults.standard.object(forKey: "RCMsgHandlers")) as? [AnyObject];
    }
    
    // 保存APP的版本号
    class func updateNativeAppVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: "NativeAppVersion");
    }
    
    class func getNativeAppVersion() -> String? {
        return (UserDefaults.standard.object(forKey: "NativeAppVersion")) as? String;
    }
}
