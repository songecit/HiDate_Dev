//
//  UUIDTool.m
//  HiParty
//
//  Created by 林祖涵 on 15/11/6.
//  Copyright © 2015年 830clock. All rights reserved.
//

#import "UUIDTool.h"
#import "FCUUID.h"

@implementation UUIDTool

//获取一条32位的字符串(不固定)
+ (NSString *)uuid
{
    return [FCUUID uuid];
}

//获取设备的唯一标示(只有当刷过系统，才会变化，系统升级都不会改变)
+ (NSString *)uuidForDevice
{
    return [FCUUID uuidForDevice];
}

@end
