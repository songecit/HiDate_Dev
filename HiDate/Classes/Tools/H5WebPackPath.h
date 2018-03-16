//
//  H5WebPackPath.h
//  HiDate
//
//  Created by qidangsong on 16/10/26.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#if WHETHER_USER_WKWEBVIEW == 1
#define TmpPath NSTemporaryDirectory()
#endif

@interface H5WebPackPath : NSObject

+ (NSString *)baseDirectory;

/** file存放的根目录 */
+ (NSString *)fileBaseDirectory;

@end

