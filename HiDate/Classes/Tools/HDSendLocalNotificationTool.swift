//
//  HDSendLocalNotificationTool.swift
//  HiParty
//
//  Created by qidangsong on 16/3/30.
//  Copyright © 2016年 830clock. All rights reserved.
//

import UIKit

class HDSendLocalNotificationTool: NSObject {
    
    class func sendSystemAutotizeAlert(title alertTitle: String, body alertBody: String) {
        
        let notification = UILocalNotification.init()
        if #available(iOS 8.2, *) {
            notification.alertTitle = alertTitle
        } else {
            // Fallback on earlier versions
        }
        notification.alertBody = alertBody
        notification.userInfo = ["key": NSLocalizedString("LocalNotificationKeyWithSysInfo", comment: "")]
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
}
