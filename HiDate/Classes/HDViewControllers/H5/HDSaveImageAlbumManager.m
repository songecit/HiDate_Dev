//
//  HDSaveImageAlbumManager.m
//  HiDate
//
//  Created by qidangsong on 16/7/29.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDSaveImageAlbumManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HiDate-Swift.h"

@implementation HDSaveImageAlbumManager


- (void)tryWriteAlbumWithImageInfo:(NSDictionary *)imageInfo
{
    // "SAVE_PHOTO"   {"url":""}   {"resultStatus":yes}
    BOOL checkResult = NO;
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusDenied) {
        [HDSendLocalNotificationTool sendSystemAutotizeAlertWithTitle:NSLocalizedString(@"AuthorizeAlertWithPhotosTitle", @"") body:NSLocalizedString(@"AuthorizeAlertWithPhotosBody", @"")];
    } else {
        if (imageInfo) {
            NSString *imageUrlString = [CommonUtils checkString:imageInfo[@"url"]];
            if (imageUrlString.length > 0) {
                checkResult = YES;
                // 下载图片并保存本地
                [self writeAlbumWithUrl:imageUrlString];
            }
        }
    }
    
    if (!checkResult) {
        // 校验不通过，告知结果
        [self resultOperate:NO];
    }
}

- (void)writeAlbumWithUrl:(NSString *)imageUrl
{
    [[ViewControllerManager shareManager] showWaitView:self.targetController.view];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        } else {
          [self resultOperate:NO];
        }
    } else {
        // 下载失败
        [self resultOperate:NO];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        // 失败
        [self resultOperate:NO];
    } else {
        // 成功
        [self resultOperate:YES];
    }
}

- (void)resultOperate:(BOOL)result
{
    [[ViewControllerManager shareManager] hideWaitView];
    self.resultCallBack(@{@"resultStatus": [NSNumber numberWithBool:result]});
}

@end
