//
//  ZipArchiveTool.h
//  WeDate
//
//  Created by HiDate on 16/6/22.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZipArchiveTool : NSObject

/**
 *  解压文件
 *
 *  @param path         待解压的文件路径
 *  @param aimDirection 解压之后的文件路径
 *
 *  @return YES 解压成功  NO 解压失败
 */
+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)aimDirection;

@end
