//
//  H5Update.h
//  HiDate
//
//  Created by qidangsong on 16/8/10.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, APPLaunchType) {
    APPLaunchTypeFirstRun = 1,  // 首次安装时启动APP
    APPLaunchTypeStart = 2,     // 启动APP时
    APPLaunchTypeAwake = 3      // 唤醒APP
};

@interface H5Update : NSObject

// 2016年08月15日
// TODO:qids，使用单例，回调的block一直有值，当awake时，不需要回调的block，此时有冗余
// TODO:qids，当下载结束时，进度的KVO要removeObserver

@property (assign, nonatomic) APPLaunchType launchType;

// isDownload是否下载结束，下载成功和失败都是isDownload = YES
@property (nonatomic, copy) void (^loadProgressBlock) (int64_t completedCount, int64_t totalCount, BOOL didDownload);
@property (nonatomic, copy) void (^loadCompleteBlock) (NSString *launchH5Path, NSString *exceptContent);

+ (instancetype)shareUpdate;

// 检查更新
- (void)checkH5AppChange;

+ (void)resetH5UpdateToFirstRunModel;

+ (NSString *)getNewH5AppSanboxPath;

@end
