//
//  HDSystemConfigModel.m
//  HiParty
//
//  Created by 林祖涵 on 15/11/30.
//  Copyright © 2015年 830clock. All rights reserved.
//

#import "HDSystemConfigModel.h"
#import "AppDelegate.h"
#import "RMUniversalAlert.h"
#import "HDForceUpdateView.h"
#import "UUIDTool.h"


#define kAppStoreDownloadUrl @"https://itunes.apple.com/us/app/hiparty/id1035241154?l=zh&ls=1&mt=8"

typedef NS_ENUM(NSUInteger, AppUpdateType) {
    AppUpdateTypeForceUpdate = 1,    //强制更新
    AppUpdateTypeNonForceUpdate, //非强制更新
    AppUpdateTypeNonUpdate       //不更新
};

@interface HDSystemConfigModel ()

@property (nonatomic, strong) HDBaseDataController *systemConfigDataController;

@end

@implementation HDSystemConfigModel

+ (instancetype)shareModel
{
    static HDSystemConfigModel *shareModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        shareModel = [[super allocWithZone:NULL] init];
    });
    return shareModel;
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [HDSystemConfigModel shareModel];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [HDSystemConfigModel shareModel];
}

- (void)requestVersion
{
    if (self.isNeedForceUpdate) {
        return;
    }
    
    if (self.resultCallBack) {
        [[ViewControllerManager shareManager] showWaitView:[UIViewController topViewController].view];
    }
    
    // mobileType	true	String	手机型号
    // mobileVersion	true	String	手机版本号
    // machineCode	true	String	机器码
    

//    NSString *mobileVersion = [UIDevice currentDevice].systemVersion;
//    NSString *machineCode = [UUIDTool uuid];
//    NSString *mobileType = [CommonUtils getCurrentDeviceModel];
//    
//    NSDictionary *params = @{   @"mobileType": mobileType,
//                             @"mobileVersion": mobileVersion,
//                             @"machineCode": machineCode    };
    
    [HDBaseDataController requestWithPath:ApiCheckAppUpdate
                                   Method:HDBaseRequestMethodPost
                                arguments:nil
                             successBlock:^(HDBaseDataController *dataController) {
                                 
                                 [[ViewControllerManager shareManager] hideWaitView];
                                 NSDictionary *resultDic = [CommonUtils checkDictionary:[dataController.responseDic objectForKey:@"result"]];
                                 NSInteger updateCode = [[CommonUtils checkString:[resultDic objectForKey:@"update"]] integerValue];
                                 
                                 if (updateCode == AppUpdateTypeNonUpdate) {
                                     if (self.resultCallBack) {
                                         self.resultCallBack(@{@"result":@"no-change"});
                                     }
                                     return;
                                 }
                                 
                                 NSString *updateContentString = [CommonUtils checkString:[resultDic objectForKey:@"content"]];
                                 NSString *updateDownloadUrl = [CommonUtils checkString:[resultDic objectForKey:@"downloadUrl"]];
                                 NSString *updateVersionString = [CommonUtils checkString:[resultDic objectForKey:@"version"]];
                                 // TODO:qids
                                 // updateDownloadUrl = @"itms-services://?action=download-manifest&url=https://www.830clock.cn/crm/hidate_ipa_1.0.0.plist";
                                 
                                 if (updateDownloadUrl.length < 1) {
                                     return;
                                 }
                                 
                                 self.isNeedForceUpdate = (updateCode == AppUpdateTypeForceUpdate) ? YES : NO;
                                 
                                 if (updateContentString.length < 1) {
                                     updateContentString = @"性能优化和修复Bug";
                                 }
                                 
                                 if (self.isNeedForceUpdate) {
                                     [self showForceUpdateViewWithVersion:updateVersionString andContent:updateContentString andDownloadUrl:updateDownloadUrl];
                                     
                                 } else {
                                     [self showUpdateAlertWithUpdateString:updateContentString
                                                         updateDownloadUrl:updateDownloadUrl];
                                 }
                             } failureBlock:^(HDBaseDataController *dataController, NSError *error) {
                                 [[ViewControllerManager shareManager] hideWaitView];
                                 if (self.resultCallBack) {
                                     self.resultCallBack(@{@"result":@"failed"});
                                 }
                             }];
}

- (void)showForceUpdateViewWithVersion:(NSString *)version andContent:(NSString *)content andDownloadUrl:(NSString *)downloadUrl
{
    UIView *windowView = [UIApplication sharedApplication].keyWindow;
    for (UIView *uView in windowView.subviews) {
        if ([uView isMemberOfClass:[HDForceUpdateView class]]) {
            return;
        }
    }
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HDForceUpdateView" owner:self options:nil];
    HDForceUpdateView *updateView = (HDForceUpdateView *)[nib firstObject];
    [updateView Initialization];
    [windowView addSubview:updateView];
    [updateView setUpdateVersion:version andContent:content andDownloadUrl:downloadUrl];
}


- (void)showUpdateAlertWithUpdateString:(NSString *)updateString
                    updateDownloadUrl:(NSString *)updateUrl
{
    
    NSArray *otherTitles = @[@"下次再说"];
    [RMUniversalAlert showAlertInViewController:[UIViewController topViewController]
                                      withTitle:@"版本更新"
                                        message:updateString
                              cancelButtonTitle:@"去更新"
                         destructiveButtonTitle:nil
                              otherButtonTitles:otherTitles
                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                                           if (buttonIndex == alert.cancelButtonIndex) {
                                               // 去升级
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
                                               
                                               // 升级时退出APP
                                               abort();
                                           }
                                       }
     ];
}

@end
