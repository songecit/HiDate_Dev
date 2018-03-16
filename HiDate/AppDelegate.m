//
//  AppDelegate.m
//  HiDate
//
//  Created by HiDate on 16/6/23.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "AppDelegate.h"
#import "HDBaseWebViewController.h"
#import "HDBaseNavigationController.h"
#import "HDBaseDataControllerUserCodeAction.h"
#import "HDSystemConfigModel.h"
#import "ZipArchiveTool.h"
#import "H5Update.h"
#import "HDLikeLaunchViewController.h"

#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"

#import <RongIMKit/RongIMKit.h>
#import "HDTxtMessage.h"
#import "HiDate-Swift.h"

@interface AppDelegate () <UIAlertViewDelegate, HDBaseDataControllerUserCodeAction>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    //初始化融云SDK。
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    [[RCIMClient sharedRCIMClient] registerMessageType:[HDTxtMessage class]];
    
    // 初始化UMeng分享
    [UMSocialData setAppKey:UMENG_KEY];
    [UMSocialWechatHandler setWXAppId:WEIXIN_APPID
                            appSecret:WEIXIN_APPSECRET
                                  url:redirectUrl];
    [UMSocialQQHandler setQQWithAppId:QQ_APPID
                               appKey:QQ_APPKEY
                                  url:redirectUrl];
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:WEIBO_APPKey
                                              secret:WEIBO_APPSECRET
                                         RedirectURL:redirectUrl];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
//    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"hidate_web" ofType:@"bundle"];
//    NSString* path = [bundlePath stringByAppendingString:@"/hidate/entry/app.html"]; // @"/hidate/test.html"
//#if WHETHER_USER_WKWEBVIEW == 1
//    HDBaseWebViewController *controller = [[HDBaseWebViewController alloc] initLocalUrlWithFilePathUrl:path  andBaseDirc:[bundlePath stringByAppendingString:@"/hidate"]];
//#else
//    HDBaseWebViewController *controller = [[HDBaseWebViewController alloc] initLocalUrlWithFilePathUrl:path];
//#endif
    
    // 启动时，先跳转类似启动页，待WebApp更新结束后load web app
    HDLikeLaunchViewController *controller = [[HDLikeLaunchViewController alloc] initWithNibName:@"HDLikeLaunchViewController" bundle:nil];
    HDBaseNavigationController *mainViewController = [[HDBaseNavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    
    // 注册通知
    [self registerNotificationWithApplication:application];
    [self receiveApnsJump:launchOptions];
    
    return YES;
}

void UncaughtExceptionHandler(NSException *exception) {

    /**
      *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
    
    // 将崩溃信息反馈
    
    /**
      *  把异常崩溃信息发送至开发者邮件
     */
    
#if PATH_ENVIRONMENT != PATH_ENVIRONMENT_ONLINE
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"mailto:qidangsong@830clock.com"];
    [mailUrl appendString:@"?subject=程序异常崩溃，请配合发送异常报告，谢谢合作！"];
    [mailUrl appendFormat:@"&body=%@", content];
    // 打开地址
    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
#endif
}


- (void)receiveApnsJump:(NSDictionary *)infoData
{
    if (infoData) {
        if (infoData[UIApplicationLaunchOptionsRemoteNotificationKey]) {
            NSString *type = [NSString stringWithFormat:@"%@", infoData[UIApplicationLaunchOptionsRemoteNotificationKey][@"appData"]];
            
            if (type && type.length > 0) {
                // APNS消息
                [HDSystemConfigModel shareModel].apnsType = type;
            }
        } else if (infoData[UIApplicationLaunchOptionsLocalNotificationKey]) {
            // 本地消息
            UILocalNotification *localNotification = infoData[UIApplicationLaunchOptionsLocalNotificationKey];
            NSDictionary *userInfo = localNotification.userInfo;
            NSString *value = [userInfo objectForKey:@"key"];
            if ([value isEqualToString:NSLocalizedString(@"LocalNotificationKeyWithIMChat", nil)]) {
                NSString *extra = [userInfo objectForKey:@"extra"];
                if (extra && extra.length > 0) {
                    [HDSystemConfigModel shareModel].localNSType = extra;
                }
            }
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // APP启动时，不调用该方法
    // 从后台到前台时尝试更新Web App
    [self attemptUpdateWebAppWhenAwake];
}

- (void)attemptUpdateWebAppWhenAwake
{
    // APP从后台到前台时，检查是否需要更新
    H5Update *update = [H5Update shareUpdate];
    update.launchType = APPLaunchTypeAwake;
    [update checkH5AppChange];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // 清除通知栏上的通知
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

/**
 *  注册用户通知设置
 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    [application registerForRemoteNotifications];
}

/**
 *  将得到的devicetoken 传给融云用于离线状态接收push ，您的app后台要上传推送证书
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

/**
 *  注册通知
 */
- (void)registerNotificationWithApplication:(UIApplication *)application {
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
        
    }
}

#pragma mark - HDBaseDataControllerUserCodeAction
- (void)baseDataControllerVersionUpdate
{
    // 增加nil，单例模式，为H5手动检查更新而设置
    [HDSystemConfigModel shareModel].resultCallBack = nil;
    [[HDSystemConfigModel shareModel] requestVersion];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 收到推送通知
    // 收到融云推送消息
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString *value = [notification.userInfo objectForKey:@"key"];
    if ([value isEqualToString:NSLocalizedString(@"LocalNotificationKeyWithSysInfo", nil)]) {
        // 收到本地通知
        NSString *titleStr = notification.alertTitle;
        NSString *bodyStr = notification.alertBody;
        
        /**
         *  麦克风不可用
         *  相机不可用
         *  照片不可用
         *  位置不可用
         *  蓝牙不可用（X）
         */
        if ([bodyStr isEqualToString:NSLocalizedString(@"AuthorizeAlertWithCameraBody", @"")]
            || [bodyStr isEqualToString:NSLocalizedString(@"AuthorizeAlertWithPhotosBody", @"")]
            || [bodyStr isEqualToString:NSLocalizedString(@"AuthorizeAlertWithLocationBody", @"")])
        {
            if (titleStr.length < 1) {
                titleStr = @"未获得授权";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr message:bodyStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 12;
            [alert show];
        }
    } else if ([value isEqualToString:NSLocalizedString(@"LocalNotificationKeyWithIMChat", nil)]) {
        NSString *extra = [notification.userInfo objectForKey:@"extra"];
        if (extra && extra.length > 0) {
            // 打开相应的页面
            UIViewController *controller = [UIViewController topViewController];
            if ([controller isKindOfClass:[HDBaseWebViewController class]]) {
                [(HDBaseWebViewController *)controller jumpHandler:extra];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        // 调用其他SDK，例如支付宝SDK等
    }
    return result;
}

@end
