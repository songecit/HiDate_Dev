//
//  HDAliyunConfigModel.h
//  HiDate
//
//  Created by qidangsong on 16/6/29.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDAliyunConfigModel : NSObject

@property (nonatomic,assign,readonly) BOOL isExistAliyunValue;

@property (nonatomic, strong) NSString *userAccessToken;

@property (nonatomic, strong) NSString *aliyunAccessKeyId;
@property (nonatomic, strong) NSString *aliyunKeySecret;
@property (nonatomic, strong) NSString *aliyunBucket;

+ (instancetype)shareModel;

- (void)requestSystemConfigWithCompleteBlock:(void(^)(BOOL))completeBlock;

@end
