//
//  HDShareContentHandle.m
//  HiParty
//
//  Created by HiDate on 16/3/11.
//  Copyright © 2016年 830clock. All rights reserved.
//

#import "HDShareContentHandle.h"

#import "UMSocialDataService.h"
#import "UMSocialSnsPlatformManager.h"

@implementation HDShareContentHandle

+ (void)shareContentWithData:(NSDictionary *)shareData
               withShareType:(HDShareContentHandleType)shareType
           withCompleteBlock:(void(^)(BOOL))completeBlock
{
    NSString *content = [shareData objectForKey:@"content"];
    NSString *title = [shareData objectForKey:@"title"];
    NSString *url = [shareData objectForKey:@"url"];
    NSString *imageUrl = [shareData objectForKey:@"imageUrl"];
    
    NSString *shareTypes = nil;
    NSString *shareContent = nil;
    UMSocialUrlResource *source = nil;
    
    switch (shareType) {
        case HDShareContentHandleTypeSinaWeiBo:
        {
            shareTypes = UMShareToSina;
            shareContent = [NSString stringWithFormat:@"%@%@%@",title,content,url];
            source = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
        }
            break;
        case HDShareContentHandleTypeWeChat:
        {
            {
                [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
                [UMSocialData defaultData].extConfig.wechatSessionData.title = title;
            }
            
            shareTypes = UMShareToWechatSession;
            shareContent = content;
            source = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
        }
            break;
        case HDShareContentHandleTypePengYouQuan:
        {
            {
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
                [UMSocialData defaultData].extConfig.wechatTimelineData.title = title;
            }
            
            shareTypes = UMShareToWechatTimeline;
            shareContent = content;
            source = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
        }
            break;
        case HDShareContentHandleTypeQQ:
        {
            {
                [UMSocialData defaultData].extConfig.qqData.url = url;
                [UMSocialData defaultData].extConfig.qqData.title = title;
            }
            
            shareTypes = UMShareToQQ;
            shareContent = content;
            source = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
        }
            break;
            
        default:
            break;
    }
    
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[shareTypes]
                                                       content:shareContent
                                                         image:nil
                                                      location:nil
                                                   urlResource:source
                                           presentedController:[self rootViewController]
                                                    completion:^(UMSocialResponseEntity *response) {
                                                        
                                                        BOOL isSuccess = YES;
                                                        if (response.responseCode == UMSResponseCodeSuccess) {
                                                            HDLog(@"分享成功");
                                                            
                                                        } else {
                                                            HDLog(@"分享失败");
                                                            isSuccess = NO;
                                                        }
                                                        
                                                        if (completeBlock) {
                                                            completeBlock(isSuccess);
                                                        }
                                                    }];
}

+ (UIViewController *)rootViewController
{
    UIWindow *window = [[UIApplication sharedApplication] valueForKeyPath:@"delegate.window"];
    return window.rootViewController;
}

@end
