//
//  CommonUtils.h
//  HiDate
//
//  Created by qidangsong on 16/6/29.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BannerTipsType) {
    BannerTipsTypeError = 0,
    BannerTipsTypeSuccess = 1,
    BannerTipsTypeInfo = 2
};

@interface CommonUtils : NSObject

+ (void)showBannerTipsWithMessage:(NSString *)message andType:(BannerTipsType)type;

// 生成唯一的字符串uuid
+ (NSString *)getUUIDString;

// 得到有效的字符串
+ (NSString *)checkString:(id)str;
// 得到有效数组
+ (NSArray *)checkArray:(id)ary;
// 得到有效字典
+ (NSDictionary *)checkDictionary:(id)dic;

+ (UIImage *)createImageWithColor:(UIColor *)color;

+ (NSString *)getCurrentDeviceModel;


+ (NSUInteger)numberOfMatchesInString:(NSString *)string andPattern:(NSString *)pattern;


@end
