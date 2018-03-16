//
//  H5WebPackPath.m
//  HiDate
//
//  Created by qidangsong on 16/10/26.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "H5WebPackPath.h"

@implementation H5WebPackPath

+ (NSString *)baseDirectory
{
    NSString *sanbox = nil;
#if WHETHER_USER_WKWEBVIEW == 1
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.49) {
        sanbox = DocumentPath;
    } else {
        sanbox = TmpPath;
    }
#else
    sanbox = DocumentPath;
#endif
    return sanbox;
}

/** file存放的根目录 */
+ (NSString *)fileBaseDirectory
{
    NSString *baseDirctory = [[self baseDirectory] stringByAppendingPathComponent:@"HiDate_Version_Update"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:baseDirctory]) {
        [fileManager createDirectoryAtPath:baseDirctory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return baseDirctory;
}


@end
