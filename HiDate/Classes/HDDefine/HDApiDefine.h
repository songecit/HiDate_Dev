//
//  HDApiDefine.h
//  HiParty
//
//  Created by lzh on 15/10/23.
//  Copyright © 2015年 lzh. All rights reserved.
//

#ifndef                          HDApiDefine_h
#define                          HDApiDefine_h

// 是否使用WKWebView，1是，0否（使用UIWebView）
#define WHETHER_USER_WKWEBVIEW 0

#define PATH_ENVIRONMENT_DEV            0
#define PATH_ENVIRONMENT_TEST           1
#define PATH_ENVIRONMENT_ONLINE         2

#if API_PATH_ENVIRONMENT==0     // debug build环境可配置为开发、测试、生产
#define PATH_ENVIRONMENT PATH_ENVIRONMENT_ONLINE
#elif API_PATH_ENVIRONMENT==1   // Release Archive测试环境打包
#define PATH_ENVIRONMENT PATH_ENVIRONMENT_TEST
#elif API_PATH_ENVIRONMENT==2   // Release Archive生产环境打包
#define PATH_ENVIRONMENT PATH_ENVIRONMENT_ONLINE
#endif

#define OUTSIDE_NET_ONLINE_PATH           @"http://hidate.830clock.com.cn/hidateapi" // 上线
#define OUTSIDE_NET_DEV_PATH              @"http://dt.9hou.me/hidateapidev"  // 开发 @"http://192.168.90.255:8121"
#define OUTSIDE_NET_TEST_PATH             @"http://dt.9hou.me/hidateapitest" // 测试 @"http://192.168.90.255:8122"

#define OUTSIDE_NET_PATH  PATH_ENVIRONMENT == 0 ? OUTSIDE_NET_DEV_PATH : (PATH_ENVIRONMENT == 1 ? OUTSIDE_NET_TEST_PATH : OUTSIDE_NET_ONLINE_PATH)

#define BASE_PATH  OUTSIDE_NET_PATH

#define AliyunOssBasePath   PATH_ENVIRONMENT == 2 ? @"http://hipartypic.9hou.me/" : @"http://testjiuhou.9hou.me/"

// Hi约 - 获取阿里云的加密appid和secret
#define ApiGetAliyunConfig @"/common/getAliyunConfig"
#define ApiCheckAppUpdate  @"/common/checkAppUpdate"

// 第三方平台的key
// 生产环境用生产的融云key，开发环境用开发的key
#define RONGCLOUD_IM_APPKEY PATH_ENVIRONMENT == 2 ? @"pkfcgjstftpz8" : @"bmdehs6pdpbgs"

// UMeng分享
#define UMENG_KEY           @"57b2af67e0f55aebd3000e07"         //友盟appKey
#define QQ_APPID            @"1105546581"                       //QQ APPID
#define QQ_APPKEY           @"Sc59bnUc9ZVdKTal"                 //QQ_APPKEY
#define WEIXIN_APPID        @"wx8ff0922c4fa67c72"               //微信 APPID
#define WEIXIN_APPSECRET    @"00d49c69dbafb23a8dd0f970e06465ae" //微信
// TODO:qids 待配置
#define WEIBO_APPKey         @"173442220"                       //微博 APPID
#define WEIBO_APPSECRET     @"569c5d740f30db8477136dfc2eae63b1" //微博
#define redirectUrl         @"http://www.830clock.com"

/** 获取融云Token */
#define ApiRongCloudToken @"/common/refreshRongToken"

#endif /* HDApiDefine_h */
