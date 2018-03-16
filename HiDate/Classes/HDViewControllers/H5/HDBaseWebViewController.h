//
//  HDBaseWebViewController.h
//  HiParty
//
//  Created by HiDate on 16/1/18.
//  Copyright © 2016年 830clock. All rights reserved.
//

#import "HDBaseViewController.h"

@interface HDBaseWebViewController : HDBaseViewController

@property (nonatomic, copy) void (^popBackBlock)(NSString *pageFrom, id extra);


@property (nonatomic, copy) NSString *webUrlString;

- (instancetype)initRequestUrlWithUrl:(NSString *)url;

- (void)pushMsg:(NSArray *)msgList;
- (void)jumpHandler:(NSString *)type;

#if WHETHER_USER_WKWEBVIEW == 1
- (instancetype)initLocalUrlWithFilePathUrl:(NSString *)fileUrl andBaseDirc:(NSString *)fileBasePath;
#else
- (instancetype)initLocalUrlWithFilePathUrl:(NSString *)fileUrl;
#endif

+ (void)openNewWebViewWithPage:(NSString *)pageTo isCloseBefore:(BOOL)isCloseBefore andController:(UIViewController *)controller;

@end
