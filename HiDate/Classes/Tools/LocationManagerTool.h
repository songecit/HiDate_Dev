//
//  LocationManagerTool.h
//  HiDate
//
//  Created by qidangsong on 16/10/8.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManagerTool : NSObject


// 增加回调
@property (nonatomic, copy) void(^resultCallBack)(NSDictionary *locationInfo);

- (void)tryLocationWithAccuracy:(BOOL)enableHighAccuracy andTimeout:(NSInteger)timeInterval;


@end
