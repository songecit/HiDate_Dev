//
//  HDRongCloudTool.swift
//  HiDate
//
//  Created by 靳志远 on 16/7/19.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

class HDRongCloudTool: NSObject {
    
    fileprivate var accessToken: String?
    var msgList = [[String:String]]();
    
    fileprivate override init() {
        super.init()
        // 设置
        setup()
    }
    
    fileprivate func setup() -> () {
        let rcim = RCIM.shared()
        // 自定义本地通知
        rcim?.disableMessageNotificaiton = true
        // 自定义声音提示
        rcim?.disableMessageAlertSound = true
        // 连接状态监听
        rcim?.connectionStatusDelegate = self
        // 用户信息
        // 接收消息的监听
        rcim?.receiveMessageDelegate = self
    }
    
    /// 单例（实例化对象）方法
    static let sharedInstance = {
        return HDRongCloudTool()
    }()
    
    /// 根据手机号、验证码获取融云Token
    func requestToken(_ accessToken: String) -> () {
        self.accessToken = accessToken
        
        var parameter = [String: AnyObject]()
        parameter["accessToken"] = self.accessToken as AnyObject?
        
        
        HDBaseDataController.request(withPath: ApiRongCloudToken, method: .post, arguments: parameter, successBlock: { (dataController) -> Void in
            guard let responseDic = dataController?.responseDic as? [String: AnyObject] else {
                return
            }
            
            guard let token = responseDic["result"] as? String else {
                return
            }
            // 连接融云
            self.connectRongCloudWithToken(token)
            
            }, failureBlock: { (dataController, error) in
                
        });
    }
    
    /// 退出登录
    func logout() -> () {
        RCIM.shared().logout()
    }
    
    /// 连接融云
    fileprivate func connectRongCloudWithToken(_ token: String) -> () {
        RCIM.shared().connect(withToken: token, success: { (userId) in
            // 连接成功
            // print("融云连接成功了，欧耶！")
            
            }, error: { (errorCode) in
                // 连接失败
                // print("连接失败")
                
        }) {
            // token无效
            self.requestToken(self.accessToken!)
        }
    }
    
    func pushMsg()
    {
        if self.msgList.count > 0
        {
            let controller = UIViewController.top();
            if controller != nil
            {
                if (controller?.isKind(of: HDBaseWebViewController.self))!
                {
                    // 最上层的webView调用JS方法
                    let vc: HDBaseWebViewController = (controller as? HDBaseWebViewController)!
                    vc.pushMsg(self.msgList);
                    self.msgList = [];
                }
            }
        }
    }
    
    func localNotificationWithContent(_ contentStr: String, extra: String, isHidden: Bool)
    {
        if !isHidden
        {
            if UIApplication.shared.applicationState == .background
            {
                let localNotification = UILocalNotification.init();
                localNotification.alertBody = contentStr;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.userInfo = ["key": NSLocalizedString("LocalNotificationKeyWithIMChat", comment: ""), "extra": extra]
                UIApplication.shared.presentLocalNotificationNow(localNotification);
                
                UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1;
            }
        }
    }
}

// MARK: RCIMConnectionStatusDelegate(连接状态监听代理方法)
extension HDRongCloudTool: RCIMConnectionStatusDelegate {
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus)
    {
        // 在别的设备上登录，需要重新登录
        if status == RCConnectionStatus.ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT
            || status == RCConnectionStatus.ConnectionStatus_LOGIN_ON_WEB
        {
            // print("您的帐号在别的设备上登录，您被迫下线！")
        }
    }
}

// MARK: RCIMReceiveMessageDelegate(接收消息的监听代理方法)
extension HDRongCloudTool: RCIMReceiveMessageDelegate
{
    func onRCIMReceive(_ message: RCMessage!, left: Int32)
    {
        let msg = message.content;
        if msg != nil
        {
            var extra = "";
            var contentStr = "";
            
            if (msg?.isKind(of: RCTextMessage.self))!
            {
                let m: RCTextMessage = msg as! RCTextMessage;
                extra = m.extra;
                contentStr = m.content;
            }
            else if (msg?.isKind(of: HDTxtMessage.self))!
            {
                 //  新增消息类型
                let m: HDTxtMessage = msg as! HDTxtMessage;
                extra = m.extra;
                contentStr = m.content;
            }
            else
            {
                return;
            }
            
            // 刚启动时，收到融云消息，清空localNSType
            HDSystemConfigModel.share().localNSType = nil;
            
            let type = HDSystemConfigModel.share().apnsType;
            
            // 是否隐藏本地通知（默认false即不隐藏、显示）
            var hiddenLocalNotification = false
            
            if (type != nil && type == extra)
            {
                // 收到APNS消息时，点击它启动APP，融云连接后，会重新收取该消息。需要过滤掉与该消息的extra相同的消息
                if left == 0
                {
                    self.pushMsg();
                    HDSystemConfigModel.share().apnsType = nil ;
                }
            }
            else
            {
                ///////////////////////////////////////////////////////
                // 收到融云消息时的处理规则：页面过滤规则
                var whetherPass = true;
                let rules = HDUserDefaultTool.getRCMessageHandleRule();
                if rules != nil {
                    for index in 0 ..< rules!.count
                    {
                        let rule = rules![index];
                        let messageType = rule["messageType"] as? String;
                        let isHidden = rule["hiddenLocalNotification"] as? Bool;
                        if isHidden != nil
                        {
                            hiddenLocalNotification = isHidden!;
                        }
                        
                        if (messageType == extra)
                        {
                            /************** 根据skipPages的内容来判断是否需要执行action **************/
                            var hasSkip = false;
                            let regexString = rule["regexString"] as? String;
                            if regexString != nil
                            {
                                var webUrl = "";
                                let controller = UIViewController.top();
                                if controller != nil {
                                    if (controller?.isKind(of: HDBaseWebViewController.self))!
                                    {
                                        let vc: HDBaseWebViewController = (controller as? HDBaseWebViewController)!
                                        let tempWebUrl = vc.webUrlString;
                                        if tempWebUrl != nil {
                                            webUrl = tempWebUrl!;
                                        }
                                    }
                                }
                                
                                // 是否匹配正则表达式
                                let matchNum = CommonUtils.numberOfMatches(in: webUrl, andPattern: regexString);
                                // 操作规则
                                let skipRuleNumber = rule["skipRule"] as? NSNumber
                                let skipRule = skipRuleNumber?.int8Value; // rule["skipRule"] as? Int8;
                                if (matchNum == 1 && skipRule == 1)
                                    || (matchNum != 1 && skipRule == 2)
                                {
                                    hasSkip = true;
                                }
                            }
                            /********************************************************************/
                            
                            if !hasSkip
                            {
                                let tmpAction = rule["action"];
                                if tmpAction != nil
                                {
                                    let action = tmpAction as! String;
                                    if (action == "BANNER_TIPS")
                                    {
                                        // extraData TIPS_SUCCESS \TIPS_INFO\TIPS_ERROR(需要先判断，当前action为BANNER_TIPS时，适用这3种)
                                        let tmpExtraData = rule["extraData"];
                                        if tmpExtraData != nil
                                        {
                                            let extraData = tmpExtraData as! String;
                                            if (extraData == "TIPS_INFO")
                                            {
                                                CommonUtils.showBannerTips(withMessage: contentStr, andType: .info);
                                            }
                                            else if (extraData == "TIPS_ERROR")
                                            {
                                                CommonUtils.showBannerTips(withMessage: contentStr, andType: .error);
                                            }
                                            else
                                            {
                                                // (extraData == "TIPS_SUCCESS")
                                                CommonUtils.showBannerTips(withMessage: contentStr, andType: .success);
                                            }
                                        }
                                        else
                                        {
                                            
                                        }
                                    }
                                    else if (action == "NONE")
                                    {
                                        // 啥也不做
                                    }
                                }
                                else
                                {
                                    
                                }
                            }
                            
                            let tmpWhetherPass = rule["whetherPass"];
                            if tmpWhetherPass != nil
                            {
                                whetherPass = tmpWhetherPass as! Bool;
                            }
                            break;
                        }
                    }
                }
                ///////////////////////////////////////////////////////
                
                if whetherPass
                {
                    self.msgList.append(["content": contentStr, "extra":extra])
                }
                if left == 0
                {
                    self.pushMsg();
                }
            }
            
            // 本地通知
            self.localNotificationWithContent(contentStr, extra: extra, isHidden: hiddenLocalNotification);
        }
        else
        {
            return;
        }
    }
}
