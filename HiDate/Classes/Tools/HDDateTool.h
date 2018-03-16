//
//  WDDateTool.h
//  WeDate
//
//  Created by miaozhan on 16/6/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDDateTool : NSObject

//根据日期获取年龄
+ (NSInteger)getAgeFromDate:(NSDate *)date;

//获取星座
+ (NSString *)getConstellationFromDate:(NSDate *)date;

//根据日期返回字符串（返回年月日）
+ (NSString *)getOneStringDateFormatFromDate:(NSDate *)date;

//根据日期返回日期字符串 （年月日  时分秒）
+ (NSString *)getTwoStringDateFormatFromDate:(NSDate *)date;

//自定义时间格式，传入时间戳和时间格式
+ (NSString *)getDateFormat:(long long)timeInterval andFormat:(NSString *)format;

//聊天时间显示，今天：小时-分钟   昨天：昨天 小时-分钟   前天以前：月-日 小时-分钟
+ (NSString *)getChatTimeString:(long long)timeInterval;

@end
