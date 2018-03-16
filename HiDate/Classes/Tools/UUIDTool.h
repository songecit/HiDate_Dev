//
//  UUIDTool.h
//  HiParty
//
//  Created by 林祖涵 on 15/11/6.
//  Copyright © 2015年 830clock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UUIDTool : NSObject

//获取一条32位的字符串(不固定)
+ (NSString *)uuid;

//获取设备的唯一标示(只有当刷过系统，才会变化，系统升级都不会改变)
+ (NSString *)uuidForDevice;

@end
