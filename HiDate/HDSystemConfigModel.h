//
//  HDSystemConfigModel.h
//  HiParty
//
//  Created by 林祖涵 on 15/11/30.
//  Copyright © 2015年 830clock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDSystemConfigModel : NSObject

+ (instancetype)shareModel;

@property (nonatomic,assign) BOOL isNeedForceUpdate;

//检查版本更新
- (void)requestVersion;

@property (strong, nonatomic) id extraData;

// 手动点击检查更新时增加回调
@property (nonatomic, copy) void(^resultCallBack)(NSDictionary *updateResult);

// 单例存储点击APNS消息的类型
@property (strong, nonatomic) NSString *apnsType;

// 单例存储点击本地消息的类型
@property (strong, nonatomic) NSString *localNSType;

@end
