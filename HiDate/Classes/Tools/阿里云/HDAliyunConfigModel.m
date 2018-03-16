//
//  HDAliyunConfigModel.m
//  HiDate
//
//  Created by qidangsong on 16/6/29.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDAliyunConfigModel.h"
#import "HDEncryptTool.h"

#define kDes @"1bcakl29023klakl"

#define kAliyunAccessKeyId  @"aliyunAccessKeyId"
#define kAliyunKeySecret    @"aliyunKeySecret"
#define kAliyunBucket       @"aliyunBucket"

@interface HDAliyunConfigModel ()

@property (nonatomic, strong) HDBaseDataController *systemConfigDataController;

@end


@implementation HDAliyunConfigModel

+ (instancetype)shareModel
{
    static HDAliyunConfigModel *shareModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        shareModel = [[super allocWithZone:NULL] init];
    });
    return shareModel;
}

- (BOOL)isExistAliyunValue
{
    BOOL isExist = NO;
    if (self.aliyunAccessKeyId
        && self.aliyunKeySecret
        && self.aliyunBucket
        && self.aliyunAccessKeyId.length > 0
        && self.aliyunKeySecret.length > 0
        && self.aliyunBucket.length > 0) {
        isExist = YES;
    }
    return isExist;
}

- (void)requestSystemConfigWithCompleteBlock:(void(^)(BOOL))completeBlock
{
    NSDictionary *queryDic = @{
                               @"key": kDes,
                               @"accessToken": ((self.userAccessToken && self.userAccessToken.length > 0) ? self.userAccessToken : @"")
                               };
    
    @weakify(self)
    self.systemConfigDataController =
    [HDBaseDataController requestWithPath:ApiGetAliyunConfig
                                   Method:HDBaseRequestMethodPost
                                arguments:queryDic
                             successBlock:^(HDBaseDataController *dataController) {
                                 @strongify(self)
                                 
                                 NSDictionary *configDic = [dataController.responseDic objectForKey:@"result"];
                                 NSString *accessKeyId = [configDic objectForKey:kAliyunAccessKeyId];
                                 NSString *keySecret   = [configDic objectForKey:kAliyunKeySecret];
                                 NSString *bucket      = [configDic objectForKey:kAliyunBucket];
                                 
                                 self.aliyunAccessKeyId = [HDEncryptTool decryptDESString:accessKeyId andKey:kDes];
                                 self.aliyunKeySecret = [HDEncryptTool decryptDESString:keySecret andKey:kDes];
                                 self.aliyunBucket = [HDEncryptTool decryptDESString:bucket andKey:kDes];
                                 
                                 self.aliyunAccessKeyId  = [self.aliyunAccessKeyId stringByReplacingOccurrencesOfString:@"\b" withString:@""];
                                 self.aliyunKeySecret = [self.aliyunKeySecret stringByReplacingOccurrencesOfString:@"\x02" withString:@""];
                                 self.aliyunBucket = [self.aliyunBucket stringByReplacingOccurrencesOfString:@"\x06" withString:@""];
                                 
                                 if (completeBlock) {
                                     completeBlock(YES);
                                 }
                                 
                             } failureBlock:^(HDBaseDataController *dataController, NSError *error) {
                                 @strongify(self)
                                 
                                 if (completeBlock) {
                                     completeBlock(NO);
                                 }
                                 
                                 HDLog(@"dataController failure in class %@",[self class]);
                             }];
}

@end
