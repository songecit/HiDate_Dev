//
//  CommonUtils.m
//  HiDate
//
//  Created by qidangsong on 16/6/29.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "CommonUtils.h"
#import "ASHUDViewNV.h"

#import <sys/utsname.h>

@implementation CommonUtils

// 显示全局的bannerTips(在顶部)
+ (void)showBannerTipsWithMessage:(NSString *)message andType:(BannerTipsType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 在主线程运行
        UIView *view = [UIApplication sharedApplication].keyWindow;
        
        for (UIView *notifyView in view.subviews) {
            
            if ([notifyView isMemberOfClass:[ASHUDViewNV class]]) {
                
                [notifyView removeFromSuperview];
                
                break;
            }
        }
        
        if (message.length < 1) {
            return;
        }
        
        ASHUDViewNV *hudViewNV = [[ASHUDViewNV alloc] initWithFrame:CGRectZero];
        hudViewNV.superView = [UIApplication sharedApplication].keyWindow;//self.view;
        if (type == BannerTipsTypeSuccess) {
            [hudViewNV showSuccess:message];
        } else if (type == BannerTipsTypeInfo) {
            [hudViewNV showInfo:message];
        } else if (type == BannerTipsTypeError) {
            [hudViewNV showError:message];
        }
    });
}


// 生成唯一的字符串uuid
+ (NSString *)getUUIDString
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    
    CFRelease(uuidObj);
    
    return uuidString;
}


// 得到有效的字符串
+ (NSString *)checkString:(id)str {
    
    if (str == nil || [str isEqual:[NSNull null]]) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%@", str];
}

// 得到有效数组
+ (NSArray *)checkArray:(id)ary {
    
    if ([ary isEqual:[NSNull null]]) {
        return nil;
    }
    return ary;
}

// 得到有效字典
+ (NSDictionary *)checkDictionary:(id)dic {
    
    if ([dic isEqual:[NSNull null]]) {
        return nil;
    }
    return dic;
}

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 20, 20);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);// 默认颜色
    // CGContextSetFillColorWithColor(context,[[Service randomColor] CGColor]);//随机色
    CGContextFillRect(context, rect);
    UIImage *imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imge;
}


//获得设备型号
+ (NSString *)getCurrentDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    
//    //#include <sys/types.h>
//    //#include <sys/sysctl.h>
//    int mib[2];
//    size_t len;
//    char *machine;
//    mib[0] = CTL_HW;
//    mib[1] = HW_MACHINE;
//    sysctl(mib, 2, NULL, &len, NULL, 0);
//    machine = malloc(len);
//    sysctl(mib, 2, machine, &len, NULL, 0);
//    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
//    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])  return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])  return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])  return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])  return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])  return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])  return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])  return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])  return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])  return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])  return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])  return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])  return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])  return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad3,1"])  return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])  return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])  return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])  return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])  return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])  return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])  return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])  return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])  return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])  return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])  return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])  return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])     return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])   return @"iPhone Simulator";
    
    return platform;
}

+ (NSUInteger)numberOfMatchesInString:(NSString *)string andPattern:(NSString *)pattern
{
    NSUInteger number = 0;
    if (string && string.length > 0
        && pattern && pattern.length > 0)
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        if (!error) {
            number = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
        }
    }
    return number;
}

@end
