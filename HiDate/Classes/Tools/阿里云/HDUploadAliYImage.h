//
//  HDUploadAliYImage.h
//  AS
//
//  Created by qids on 15/9/6.
//  Copyright (c) 2015年 AngusNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDAliyunConfigModel.h"

@interface HDUploadAliYImage : NSObject

/**
 *  图片异步上传到阿里云
 *
 *  @param list  上传的imageList @[{@"key":string,@"data":data}]
 *  @param partProgressaBlock           指定的图片 上传进度
 *  @param partSuccessBlock             指定的图片 成功
 *  @param partFailureBlock             指定的图片 失败
 *  @param allPartCompleteBlock         所有的图片都上传成功回调
 */

- (void)asyncUploadMultipartWithList:(NSArray *)list
                   partProgressBlock:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend, int partNumber))partProgressBlock
                    partSuccessBlock:(void (^)(int index))partSuccessBlock
                    partFailureBlock:(void (^)(int index))partFailureBlock
                allPartCompleteBlock:(void (^)(NSArray *))allPartCompleteBlock;

//@{@"key":string,@"videoFilePath":string}
- (void)asyncUploadVideoWithVideoInfoDic:(NSDictionary *)videoInfoDic
                      withUploadProgress:(void (^)(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend))uploadProgressBlock
                 withUploadCompleteBlock:(void (^)(BOOL isSuccess, NSString *videoKey))uploadCompleteBlock;

@end
