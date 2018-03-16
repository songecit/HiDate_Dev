//
//  HDUploadVideoManager.m
//  HiDate
//
//  Created by qidangsong on 16/6/30.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDUploadVideoManager.h"

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "UzysAssetsPickerController.h"

#import "HDUploadAliYImage.h"
#import "HDUploadVideoProgressView.h"

#import "HiDate-Swift.h"

typedef NS_ENUM(NSInteger, HDVideoProgressType) {
    HDVideoProgressTypeCompress = 0,    // 压缩进度
    HDVideoProgressTypeUpload = 1       // 上传进度
};

@interface HDUploadVideoManager () <UzysAssetsPickerControllerDelegate>

@property (nonatomic, strong) NSTimer *compressTimer;
@property (nonatomic, assign) NSInteger timerCount;

@property (nonatomic, weak) HDUploadVideoProgressView *progressView;
@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, assign) BOOL isCancelUpload;

@end

@implementation HDUploadVideoManager


- (void)jumpToChooseVideoController
{
    // 上传小视频
    PHAuthorizationStatus phAuthor = [PHPhotoLibrary authorizationStatus];
    if (phAuthor == PHAuthorizationStatusDenied || phAuthor == PHAuthorizationStatusRestricted) {
        [HDSendLocalNotificationTool sendSystemAutotizeAlertWithTitle:NSLocalizedString(@"AuthorizeAlertWithPhotosTitle", @"") body:NSLocalizedString(@"AuthorizeAlertWithPhotosBody", @"")];
    } else {
        AVAuthorizationStatus avAuthor = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (avAuthor == AVAuthorizationStatusDenied || avAuthor == AVAuthorizationStatusRestricted) {
            [HDSendLocalNotificationTool sendSystemAutotizeAlertWithTitle:NSLocalizedString(@"AuthorizeAlertWithCameraTitle", @"") body:NSLocalizedString(@"AuthorizeAlertWithCameraBody", @"")];
        } else {
            UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
            picker.delegate = self;
            
            picker.maximumNumberOfSelectionVideo = 1;
            picker.maximumNumberOfSelectionPhoto = 0;
            picker.videoMaximumDuration = 30.0f;
            
            [self.targetController presentViewController:picker animated:YES completion:nil];
        }
    }
}

- (BOOL)uzysAssetsPickerControllerShouldSelectAsset:(ALAsset *)asset
{
    if([[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypeVideo"]) {
        //video
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        NSURL *movieURL = representation.url;
        
        CGFloat videoTime = [HDCompressVideoTool getDurationWithURL:movieURL];
        
        if (videoTime > 31) {
            [CommonUtils showBannerTipsWithMessage:@"只能传输30秒以内的短视频" andType:BannerTipsTypeError];
            return NO;
        }
    }
    
    return YES;
}

- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSString *firstAssetPropertyType = [assets[0] valueForProperty:ALAssetPropertyType];
    
    if ([firstAssetPropertyType isEqualToString:ALAssetTypeVideo]) {
        
        ALAsset *alAsset = assets[0];
        ALAssetRepresentation *representation = alAsset.defaultRepresentation;
        
        // 去压缩
        [self compressVideo:representation.url];
    }
}

#pragma mark - 压缩视频
- (void)compressVideo:(NSURL *)videoUrl
{
    // 建立下载进度显示页面
    [self createProgressView];
    
    // 增加定时器，模拟压缩进度
    [self createCompressTimer];
    
    [HDCompressVideoTool compress:videoUrl complete:^(BOOL isSuccess, NSURL * _Nullable outputURL, NSURL * _Nonnull inputURL) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!self.isCancelUpload)
            {
                // 压缩结束，使定时器失效
                if (self.compressTimer)
                {
                    [self.compressTimer invalidate];
                    self.compressTimer = nil;
                }
                
                if (isSuccess)
                {
                    // 压缩成功，上传视频到阿里云
                    if (outputURL)
                    {
                        [self uploadVideoWithCompressUrlString:outputURL.relativeString];
                    }
                }
                else
                {
                    // 压缩失败
                    [self removeUploadingProgressView];
                    [CommonUtils showBannerTipsWithMessage:@"压缩失败，请重试" andType:BannerTipsTypeError];
                }
            }
        });
    }];
}

#pragma mark - 视频上传
- (void)uploadVideoWithCompressUrlString:(NSString *)videoUrlString
{
    // extra = {type:type,accessToken:accessToken,userId:4}
    [HDAliyunConfigModel shareModel].userAccessToken = self.extra[@"accessToken"];
    NSString *userId = [NSString stringWithFormat:@"%@", self.extra[@"userId"]];
    HDUploadAliYImage *uploadVideoAndFirstFrame = [[HDUploadAliYImage alloc] init];
    
    NSString *aliyunFilePath = [NSString stringWithFormat:@"hiyue/video/%@", ((userId && userId.length > 0) ? userId : @"unknown")];
    NSString *videoKey = [NSString stringWithFormat:@"%@/%@.mp4",aliyunFilePath,[CommonUtils getUUIDString]];
    NSDictionary *videoInfoDic = @{
                                   @"key":videoKey,
                                   @"videoFilePath":videoUrlString
                                   };
    [uploadVideoAndFirstFrame asyncUploadVideoWithVideoInfoDic:videoInfoDic
                                            withUploadProgress:^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
                                                
                                                [self setProgressValue:((CGFloat)totalByteSent / (CGFloat)totalBytesExpectedToSend) andType:HDVideoProgressTypeUpload];
                                                
                                            } withUploadCompleteBlock:^(BOOL isSuccess, NSString *videoKey) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                   
                                                    // 若取消上传，则无操作
                                                    if (!self.isCancelUpload)
                                                    {
                                                        [self removeUploadingProgressView];
                                                       
                                                        // 发送视频
                                                        if (isSuccess)
                                                        {
                                                            // 传值到H5
                                                            NSString *aliyunUrlString = [AliyunOssBasePath stringByAppendingString:videoKey];
                                                            HDLog(@"%@", aliyunUrlString);
                                                            self.resultCallBack(@{@"remoteUrl": aliyunUrlString,
                                                                                  @"localeUrl": videoUrlString});
                                                        }
                                                        else
                                                        {
                                                            [CommonUtils showBannerTipsWithMessage:@"网络连接中断，请重新上传" andType:BannerTipsTypeError];
                                                        }
                                                    }
                                                });
                                            }];
}

#pragma mark - 创建视频压缩时的定时器（模拟压缩进度）
- (void)createCompressTimer
{
    self.timerCount = 0;
    NSTimer *tmpTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(addCompressProgress) userInfo:nil repeats:YES];
    _compressTimer = tmpTimer;
}

- (void)addCompressProgress
{
    // 0.2ms的进度为0.02，相当于10S压缩完
    self.timerCount += 2;
    [self setProgressValue:(self.timerCount / 100.0f) andType:HDVideoProgressTypeCompress];
}

#pragma mark - 创建显示进度条的页面
- (void)createProgressView
{
    self.isCancelUpload = NO;
    NSArray *nib1 = [[NSBundle mainBundle] loadNibNamed:@"HDUploadVideoProgressView" owner:self options:nil];
    HDUploadVideoProgressView *view = (HDUploadVideoProgressView *)[nib1 firstObject];

    view.cancelUploadOprete = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cancelUploadOperation];
        });
    };
    [self.targetController.navigationController.view addSubview:view];
    _progressView = view;
}

- (void)setProgressValue:(CGFloat)progressValue andType:(HDVideoProgressType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        /**
         *  原则：
         *  1、视频压缩的进度最多为45%，小于45%已现有进度计；
         *  2、视频上传时的显示的进度为：视频压缩后的进度 + 视频上传的进度 * 视频上传占总进度的比例；
         *  3、进度只增不减，最大为1，最小为0；
         */
        
        CGFloat value1 = MAX(0.0, progressValue);
        CGFloat value2 = 0;
        if (type == HDVideoProgressTypeCompress)
        {
           value2 = MIN(value1, 0.45);
        }
        else if (type == HDVideoProgressTypeUpload)
        {
            CGFloat compressProgressValue = MIN(0.45, self.timerCount / 100.0);
            value2 = MIN(1, (compressProgressValue + (1 - compressProgressValue) * value1));
        }
        else
        {
            value2 = 1.0f;
        }
        _progressValue = MAX(_progressValue, value2);
        self.progressView.uploadProgressValue = self.progressValue;
    });
}

#pragma mark - 取消上传的操作
- (void)cancelUploadOperation
{
    self.isCancelUpload = YES;
    [self removeUploadingProgressView];
    
    if (self.compressTimer)
    {
        [self.compressTimer invalidate];
        self.compressTimer = nil;
    }
}

#pragma mark - 移除显示进度条的页面
- (void)removeUploadingProgressView
{
    [self.progressView removeFromSuperview];
    self.progressView = nil;
}

@end
