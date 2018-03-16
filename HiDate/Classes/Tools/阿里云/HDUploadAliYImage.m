//
//  HDUploadAliYImage.m
//  AS
//
//  Created by qids on 15/9/6.
//  Copyright (c) 2015年 AngusNi. All rights reserved.
//

#import "HDUploadAliYImage.h"
#import <AliyunOSSiOS/OSSService.h>

NSString * const EndPoint = @"http://oss-cn-hangzhou.aliyuncs.com";

@interface HDUploadAliYImage ()

@property (nonatomic, strong) OSSClient *client;

@end

@implementation HDUploadAliYImage

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([HDAliyunConfigModel shareModel].isExistAliyunValue) {
            [self initOSSCredential];
        }
    }
    return self;
}

- (void)initOSSCredential
{
    id<OSSCredentialProvider> credential =
    [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:[HDAliyunConfigModel shareModel].aliyunAccessKeyId
                                                                     secretKey:[HDAliyunConfigModel shareModel].aliyunKeySecret];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 3;
    //        conf.enableBackgroundTransmitService = YES; // 是否开启后台传输服务，目前，开启后，只对上传任务有效
    conf.timeoutIntervalForRequest = 15;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    self.client = [[OSSClient alloc] initWithEndpoint:EndPoint
                                   credentialProvider:credential
                                  clientConfiguration:conf];
}

- (void)asyncUploadTheVideoWithVideoInfoDic:(NSDictionary *)videoInfoDic
                         withUploadProgress:(void (^)(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend))uploadProgressBlock
                    withUploadCompleteBlock:(void (^)(BOOL isSuccess, NSString *videoKey))uploadCompleteBlock;
{
    OSSPutObjectRequest *videoPut = [[OSSPutObjectRequest alloc] init];
    
    videoPut.bucketName = [HDAliyunConfigModel shareModel].aliyunBucket;
    videoPut.objectKey = [videoInfoDic objectForKey:@"key"];
    videoPut.uploadingFileURL = [NSURL URLWithString:[videoInfoDic objectForKey:@"videoFilePath"]];
    videoPut.uploadProgress =  ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        
        if (uploadProgressBlock)
        {
            uploadProgressBlock(bytesSent,totalByteSent,totalBytesExpectedToSend);
        }
    };
    
    OSSTask *putTask = [self.client putObject:videoPut];
    [putTask continueWithBlock:^id(OSSTask *task) {
        NSLog(@"objectKey: %@", videoPut.objectKey);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!task.error)
            {
                if (uploadCompleteBlock)
                {
                    uploadCompleteBlock(YES, videoPut.objectKey);
                }
                NSLog(@"upload object success!");
            }
            else
            {
                if (uploadCompleteBlock)
                {
                    uploadCompleteBlock(NO, videoPut.objectKey);
                }
                NSLog(@"upload object failed, error: %@" , task.error);
            }

        });
        
        return nil;
    }];
}

- (void)syncUploadMultipartWithList:(NSArray *)list
                   partProgressBlock:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend, int partNumber))partProgressBlock
                    partSuccessBlock:(void (^)(int index))partSuccessBlock
                    partFailureBlock:(void (^)(int index))partFailureBlock
                allPartCompleteBlock:(void (^)(NSArray *))allPartCompleteBlock
{
    int partNum = 0;
    
    NSMutableArray *resultsArray = [NSMutableArray array];
    
    for (NSDictionary *dataDic in list) {
        OSSPutObjectRequest *put = [[OSSPutObjectRequest alloc] init];
        
        put.bucketName = [HDAliyunConfigModel shareModel].aliyunBucket;
        put.contentType = @"image/jpeg";
        put.objectKey = [dataDic objectForKey:@"key"];
        put.uploadingData = [dataDic objectForKey:@"data"];
        
        put.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                partProgressBlock(bytesSent,totalBytesSent, totalBytesExpectedToSend, partNum);
            });
            
            
            HDLog(@"\n part%zd \n bytesSent %lld \n totalBytesSent %lld \n totalBytesExpectedToSend %lld ",partNum,bytesSent,totalBytesSent,totalBytesExpectedToSend);
            
        };
        
        OSSTask *putTask = [self.client putObject:put];
        
        [putTask waitUntilFinished];
        
        if (!putTask.error) {

            
            [resultsArray addObject:[dataDic objectForKey:@"key"]];
    
            dispatch_async(dispatch_get_main_queue(), ^{
                if (partSuccessBlock) {
                    partSuccessBlock(partNum);
                }
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (partFailureBlock) {
                    partFailureBlock(partNum);
                }
            });
        }
        partNum ++;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (allPartCompleteBlock) {
            allPartCompleteBlock(resultsArray);
        }
    });
}

- (void)asyncUploadMultipartWithList:(NSArray *)list
                   partProgressBlock:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend, int partNumber))partProgressBlock
                    partSuccessBlock:(void (^)(int index))partSuccessBlock
                    partFailureBlock:(void (^)(int index))partFailureBlock
                allPartCompleteBlock:(void (^)(NSArray *))allPartCompleteBlock
{
    void (^tmpActionBlock) (void) = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self syncUploadMultipartWithList:list
                            partProgressBlock:partProgressBlock
                             partSuccessBlock:partSuccessBlock
                             partFailureBlock:partFailureBlock
                         allPartCompleteBlock:allPartCompleteBlock];
        });
    };
    
    if ([HDAliyunConfigModel shareModel].isExistAliyunValue) {
        tmpActionBlock();
    } else {
        [[HDAliyunConfigModel shareModel] requestSystemConfigWithCompleteBlock:^(BOOL isSuccess){
            if (isSuccess) {
                [self initOSSCredential];
                tmpActionBlock();
            } else {
                if (allPartCompleteBlock) {
                    allPartCompleteBlock(nil);
                }
            }
        }];
    }
}

- (void)asyncUploadVideoWithVideoInfoDic:(NSDictionary *)videoInfoDic
                      withUploadProgress:(void (^)(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend))uploadProgressBlock
                 withUploadCompleteBlock:(void (^)(BOOL isSuccess, NSString *videoKey))uploadCompleteBlock;
{
    // 默认进度为0.1
    uploadProgressBlock(1,1,10);
    void (^tmpActionBlock) (void) = ^{
        [self asyncUploadTheVideoWithVideoInfoDic:videoInfoDic
                               withUploadProgress:uploadProgressBlock
                          withUploadCompleteBlock:uploadCompleteBlock];
    };
    
    if ([HDAliyunConfigModel shareModel].isExistAliyunValue)
    {
        tmpActionBlock();
    }
    else
    {
        [[HDAliyunConfigModel shareModel] requestSystemConfigWithCompleteBlock:^(BOOL isSuccess){
            if (isSuccess)
            {
                // 配置成功后，进度为0.2
                uploadProgressBlock(1,2,10);
                [self initOSSCredential];
                tmpActionBlock();
            }
            else
            {
                if (uploadCompleteBlock)
                {
                    uploadCompleteBlock(NO,nil);
                }
            }
        }];
    }
}

@end
