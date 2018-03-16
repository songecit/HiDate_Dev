//
//  HDUploadVideoManager.h
//  HiDate
//
//  Created by qidangsong on 16/6/30.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDUploadVideoManager : NSObject

@property (nonatomic, strong) UIViewController *targetController;

@property (nonatomic, copy) NSDictionary *extra;

// 增加回调
@property (nonatomic, copy) void(^resultCallBack)(NSDictionary *videoInfo);

- (void)jumpToChooseVideoController;

@end
