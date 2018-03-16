//
//  WDEncryptTool.m
//  WeDate
//
//  Created by miaozhan on 16/6/22.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDEncryptTool.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "GGTMBase64.h"

@implementation HDEncryptTool

// 字符串反转处理
+ (NSString *)getSecretStringReverse:(NSString *)string
{
    int length = (int)string.length;
    NSMutableString *reversedString = [[NSMutableString alloc] initWithCapacity: length];
    while (length > 0)
    {
        [reversedString appendString:[NSString stringWithFormat:@"%C", [string characterAtIndex:--length]]];
    }
    return reversedString;
}

// 字符串MD5处理32位
+ (NSString *)getSecretString32MD5:(NSString *)string
{
    const char      *cStr = [string UTF8String];
    unsigned char   result[32];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [[NSString
             stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3], result[4], result[5],
             result[6], result[7], result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]] uppercaseString];
}

// 字符串DES处理
+ (NSString *)getSecretStringDES:(NSString *)string andKey:(NSString*)key
{
    return [self encrypt:string encryptOrDecrypt:kCCEncrypt key:key];
}

// Des
+ (NSString *)encrypt:(NSString *)sText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key
{
    const void *dataIn;
    size_t dataInLength;
    
    if (encryptOperation == kCCDecrypt)//传递过来的是decrypt 解码
    {
        //解码 base64
        NSData *decryptData = [GGTMBase64 decodeData:[sText dataUsingEncoding:NSUTF8StringEncoding]];//转成utf-8并decode
        dataInLength = [decryptData length];
        dataIn = [decryptData bytes];
    }
    else  //encrypt
    {
        NSData* encryptData = [sText dataUsingEncoding:NSUTF8StringEncoding];
        dataInLength = [encryptData length];
        dataIn = (const void *)[encryptData bytes];
    }
    
    /*
     DES加密 ：用CCCrypt函数加密一下，然后用base64编码下，传过去
     DES解密 ：把收到的数据根据base64，decode一下，然后再用CCCrypt函数解密，得到原本的数据
     */
    CCCryptorStatus ccStatus=0;
    unsigned long *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码，比如：一个人用int，一个人用long。最好用typedef来定义）
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(unsigned long));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
    
    NSString *initIv = @"!=830*clock#";
    const void *vkey = (const void *) [key UTF8String];
    const void *iv = (const void *) [initIv UTF8String];
    
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(encryptOperation,//  加密/解密
                       kCCAlgorithm3DES,//  加密根据哪个标准
                       kCCOptionECBMode,//  选项分组密码算法
                       vkey,  //密钥    加密和解密的密钥必须一致
                       kCCKeySize3DES,//   DES 密钥的大小（
                       iv, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);
    NSString *result = nil;
    NSData *data = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
    if (encryptOperation == kCCDecrypt)//encryptOperation==1  解码
    {
        //得到解密出来的data数据，改变为utf-8的字符串
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else //encryptOperation==0  （加密过程中，把加好密的数据转成base64的）
    {
        //编码 base64
        result = [GGTMBase64 stringByEncodingData:data];
    }
    
    return result;
}

+ (NSString *)decryptDESString:(NSString *)string andKey:(NSString *)key
{
    //1 对key套一层MD5
    NSString *md5Value = [[[HDEncryptTool getSecretString32MD5:key] lowercaseString] substringToIndex:24];
    //2 去解密string
    NSString *decryptString = [HDEncryptTool encrypt:string encryptOrDecrypt:kCCDecrypt key:md5Value];
    //3 翻转拿到的值
    NSString *reverseString = [HDEncryptTool getSecretStringReverse:decryptString];
    
    return reverseString;
}

// 字符串SHA256处理
+ (NSString *)getSecretStringSHA256:(NSString *)string
{
    const char  *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData      *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t     digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

// HiParty注册加密
+(NSString*)getSecretStringHiPartyRegister:(NSString *)string andSalt:(NSString*)salt
{
    NSString *str = [HDEncryptTool getSecretStringSHA256:string];
    str = [NSString stringWithFormat:@"%@%@", str, salt];
    str = [HDEncryptTool getSecretStringReverse:str];
    NSString *keystr = [[HDEncryptTool getSecretString32MD5:[NSString stringWithFormat:@"830clock%@", salt]]lowercaseString];
    str = [HDEncryptTool getSecretStringDES:str andKey:keystr];
    return str;
}
// HiParty登录加密
+(NSString*)getSecretStringHiPartyLogin:(NSString *)string andSalt:(NSString*)salt
{
    NSString *str = [HDEncryptTool getSecretStringSHA256:string];
    str = [NSString stringWithFormat:@"%@%@", str, salt];
    str = [HDEncryptTool getSecretStringSHA256:str];
    return str;
}

// HiParty第三方登陆加密  不需要截取24位
+(NSString*)getSecretStringHiPartyThirdLogin:(NSString *)openid andSalt:(NSString*)salt
{
    // 第一步  构建DesCoding 秘钥，构建方式同以前 使用"830clock" + 盐值  md5后的前24位作为秘钥
    NSString *code = [NSString stringWithFormat:@"830clock%@", salt];
    NSString *MD5Code = [[HDEncryptTool getSecretString32MD5:code] lowercaseString];
    
    //  第二步  构建加密串 使OPENID 满足8的整数位条件  用于 des加密
    NSInteger openidLength = openid.length;
    NSMutableString *resultOpenid = [NSMutableString stringWithString:openid];
    int mod = openidLength % 8;
    if (mod != 0) {
        for (int i = 0; i < (8 - mod); i ++) {
            [resultOpenid appendString:@"0"];
        }
    }
    NSInteger cnt = [NSString stringWithFormat:@"%ld", (long)openidLength].length;
    for (NSInteger i = 0 ; i < (8 - cnt); i ++ ) {
        [resultOpenid appendString:@"0"];
    }
    [resultOpenid appendString:[NSString stringWithFormat:@"%ld", (long)openidLength]];
    
    // 第三步 做descoding 然后base64 转成字符串
    NSString *desCoding = [HDEncryptTool getSecretStringDES:resultOpenid andKey:MD5Code];
    
    return desCoding;
}


@end
