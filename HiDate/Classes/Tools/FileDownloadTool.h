//
//  FileDownloadTool.h
//  KeepWineHybird
//
//  Created by qidangsong on 16/9/9.
//  Copyright © 2016年 QDS. All rights reserved.
//  文件下载类

#import <Foundation/Foundation.h>

@interface FileDownloadTool : NSObject

+ (instancetype)shareTool;

- (void)downloadFileWithUrl:(NSString *)fileUrl andLocalPath:(NSString *)localPath andCallBack:(void(^)(BOOL checkResult))callBack;

@end
