//
//  HDSaveImageAlbumManager.h
//  HiDate
//
//  Created by qidangsong on 16/7/29.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDSaveImageAlbumManager : NSObject

@property (nonatomic, strong) UIViewController *targetController;

// 增加回调
@property (nonatomic, copy) void(^resultCallBack)(NSDictionary *saveResultInfo);

- (void)tryWriteAlbumWithImageInfo:(NSDictionary *)imageInfo;

@end
