//
//  FileDownloadTool.m
//  KeepWineHybird
//
//  Created by qidangsong on 16/9/9.
//  Copyright © 2016年 QDS. All rights reserved.
//

#import "FileDownloadTool.h"
#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"

@interface FileDownloadTool ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;

@end


@implementation FileDownloadTool

+ (instancetype)shareTool
{
    static FileDownloadTool *shareTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        shareTool = [[super allocWithZone:NULL] init];
    });
    return shareTool;
}

- (AFURLSessionManager *)sessionManager
{
    if (!_sessionManager) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest =
        config.timeoutIntervalForResource = 600;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    }
    return _sessionManager;
}

// 根据url下载文件并告知结果
- (void)downloadFileWithUrl:(NSString *)fileUrl andLocalPath:(NSString *)localPath andCallBack:(void(^)(BOOL checkResult))callBack
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
    
    // @weakify(self)
    [[self.sessionManager downloadTaskWithRequest:request
                                         progress:nil
                                      destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                          
                                          if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                              // 将下载后的文件保存到本地目录
                                              [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
                                              return [NSURL fileURLWithPath:localPath];
                                              
                                          } else {
                                              return nil;
                                          }
                                      } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                          
                                          // @strongify(self)
                                          if (error) {
                                              callBack(NO);
                                          } else {
                                              NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                                              if (statusCode == 200) {
                                                  callBack(YES);
                                              } else {
                                                  callBack(NO);
                                              }
                                          }
                                      }] resume];
}

@end
