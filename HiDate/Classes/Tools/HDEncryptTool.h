//
//  WDEncryptTool.h
//  WeDate
//
//  Created by miaozhan on 16/6/22.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDEncryptTool : NSObject

// 字符串反转处理
+ (NSString *)getSecretStringReverse:(NSString *)string;

// 字符串MD5处理32位
+ (NSString *)getSecretString32MD5:(NSString *)string;

// 字符串DES处理
+ (NSString *)getSecretStringDES:(NSString *)string andKey:(NSString*)key;

/****注册登录加密****/
// HiParty注册加密
+(NSString*)getSecretStringHiPartyRegister:(NSString *)string andSalt:(NSString*)salt;

// HiParty登录加密
+(NSString*)getSecretStringHiPartyLogin:(NSString *)string andSalt:(NSString*)salt;

// HiParty第三方登陆加密 不需要截取24位
+(NSString*)getSecretStringHiPartyThirdLogin:(NSString *)openid andSalt:(NSString*)salt;

// aliyun key值解密
+ (NSString *)decryptDESString:(NSString *)string andKey:(NSString *)key;
@end
