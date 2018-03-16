//
//  WDDateTool.m
//  WeDate
//
//  Created by miaozhan on 16/6/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDDateTool.h"

@implementation HDDateTool

//根据日期获取年龄
+ (NSInteger)getAgeFromDate:(NSDate *)date
{
    //获取到当前日期的年数
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSInteger birthYear = [components year];
    
    //获取当前系统的年限
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    NSInteger currentYear = [currentComponents year];
    
    NSInteger iAge = currentYear - birthYear ;
    
    return iAge;
    
}

//获取星座
+ (NSString *)getConstellationFromDate:(NSDate *)date
{
    //计算星座
    NSString *retStr=@"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    int i_month=0;
    NSString *theMonth = [dateFormat stringFromDate:date];
    if([[theMonth substringToIndex:0] isEqualToString:@"0"]){
        i_month = [[theMonth substringFromIndex:1] intValue];
    }else{
        i_month = [theMonth intValue];
    }
    
    [dateFormat setDateFormat:@"dd"];
    int i_day=0;
    NSString *theDay = [dateFormat stringFromDate:date];
    if([[theDay substringToIndex:0] isEqualToString:@"0"]){
        i_day = [[theDay substringFromIndex:1] intValue];
    }else{
        i_day = [theDay intValue];
    }
    /*
     摩羯座 12月22日------1月19日
     水瓶座 1月20日-------2月18日
     双鱼座 2月19日-------3月20日
     白羊座 3月21日-------4月19日
     金牛座 4月20日-------5月20日
     双子座 5月21日-------6月21日
     巨蟹座 6月22日-------7月22日
     狮子座 7月23日-------8月22日
     处女座 8月23日-------9月22日
     天秤座 9月23日------10月23日
     天蝎座 10月24日-----11月21日
     射手座 11月22日-----12月21日
     */
    switch (i_month) {
        case 1:
            if(i_day>=20 && i_day<=31){
                retStr=@"水瓶";
            }
            if(i_day>=1 && i_day<=19){
                retStr=@"摩羯";
            }
            break;
        case 2:
            if(i_day>=1 && i_day<=18){
                retStr=@"水瓶";
            }
            if(i_day>=19 && i_day<=31){
                retStr=@"双鱼";
            }
            break;
        case 3:
            if(i_day>=1 && i_day<=20){
                retStr=@"双鱼";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"白羊";
            }
            break;
        case 4:
            if(i_day>=1 && i_day<=19){
                retStr=@"白羊";
            }
            if(i_day>=20 && i_day<=31){
                retStr=@"金牛";
            }
            break;
        case 5:
            if(i_day>=1 && i_day<=20){
                retStr=@"金牛";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"双子";
            }
            break;
        case 6:
            if(i_day>=1 && i_day<=21){
                retStr=@"双子";
            }
            if(i_day>=22 && i_day<=31){
                retStr=@"巨蟹";
            }
            break;
        case 7:
            if(i_day>=1 && i_day<=22){
                retStr=@"巨蟹";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"狮子";
            }
            break;
        case 8:
            if(i_day>=1 && i_day<=22){
                retStr=@"狮子";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"处女";
            }
            break;
        case 9:
            if(i_day>=1 && i_day<=22){
                retStr=@"处女";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"天秤";
            }
            break;
        case 10:
            if(i_day>=1 && i_day<=23){
                retStr=@"天秤";
            }
            if(i_day>=24 && i_day<=31){
                retStr=@"天蝎";
            }
            break;
        case 11:
            if(i_day>=1 && i_day<=22){
                retStr=@"天蝎";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"射手";
            }
            break;
        case 12:
            if(i_day>=1 && i_day<=21){
                retStr=@"射手";
            }
            if(i_day>=22 && i_day<=31){
                retStr=@"摩羯";
            }
            break;
    }
    return retStr;
}

//根据日期返回字符串（返回年月日）
+ (NSString *)getOneStringDateFormatFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    
    if (!formatter) {
        @synchronized(self) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
        }
    }
    return [formatter stringFromDate:date];
}


//根据日期返回日期字符串 （年月日  时分秒）
+ (NSString *)getTwoStringDateFormatFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    
    if (!formatter) {
        @synchronized(self) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
    }
    
    return [formatter stringFromDate:date];
}

/*
 传时间戳，以及时间格式 返回一个时间字符串 常用的时间格式：
 @"yyyy-MM-dd HH:mm:ss"
 @"yyyy-MM-dd"
 @"MM:dd"
 @"yyyy-MM-dd HH:mm"
 @"hh:mm"
 @"yyyy-MM-dd a HH:mm:ss EEEE" 2012-10-29 下午 16:25:27 星期一
 */
+ (NSString *)getDateFormat:(long long)timeInterval andFormat:(NSString *)format
{
    //入参为毫秒值
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval / 1000.0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}


//聊天时间显示，今天：小时-分钟   昨天：昨天 小时-分钟   前天以前：月-日 小时-分钟
+ (NSString *)getChatTimeString:(long long)timeInterval
{
    NSString *resultString = @"";
    if (timeInterval > 0) {
        double secondTimeInterval = timeInterval / 1000.0;//秒数
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondTimeInterval];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        //只显示 月 日
        dateFormatter.dateFormat = @"MM-dd";
        NSString *mmddString = [dateFormatter stringFromDate:date];
        
        //只显示 时 分
        dateFormatter.dateFormat = @"HH:mm";
        NSString *hhmmString = [dateFormatter stringFromDate:date];
        
        //显示完整的 年 月 日
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *yyyymmmddString = [dateFormatter stringFromDate:date];
        
        //昨天的时间
        NSDate *yesterday = [NSDate dateWithTimeIntervalSince1970:(secondTimeInterval + (24 * 60 * 60))];
        NSString *yesterdayString = [dateFormatter stringFromDate:yesterday];
        
        //当前的时间
        NSString *nowString = [dateFormatter stringFromDate:[NSDate date]];
        
        if (yyyymmmddString == nowString) {
            resultString = hhmmString;
        } else if (yesterdayString == nowString) {
            resultString = @"昨天";
        } else {
            resultString = mmddString;
        }
        
    }
    return resultString;
}




@end
