//
//  HDBaseDataController.h
//  HiParty
//
//  Created by lzh on 15/10/19.
//  Copyright © 2015年 lzh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HDBaseDataControllerIndicator;

typedef NS_ENUM(NSUInteger, HDBaseRequestErrorCode) {
    HDBaseRequestErrorCodeEmptyData = 100,
    HDBaseRequestErrorCodeParseFail = 101,
    HDBaseRequestErrorCodeNetLinkFail = 102
};

typedef NS_ENUM(NSUInteger, HDBaseRequestMethod) {
    HDBaseRequestMethodPost,
    HDBaseRequestMethodGet
};

@interface HDBaseDataController : NSObject

@property (nonatomic, strong) NSString *aURLString;
@property (nonatomic, strong, readonly) NSDictionary *requestArgs;
@property (nonatomic, strong, readonly) NSString *responseString;
@property (nonatomic, strong, readonly) NSDictionary *responseDic;

+ (instancetype)sharedDataController;

+ (HDBaseDataController *)requestWithPath:(NSString *)path
                                   Method:(HDBaseRequestMethod)requestMethod
                                arguments:(NSDictionary *)args
                             successBlock:(void (^)(HDBaseDataController *dataController))successBlock
                             failureBlock:(void (^)(HDBaseDataController *dataController, NSError *error)) failureBlock;

+ (HDBaseDataController *)requestWithPath:(NSString *)path
                                   Method:(HDBaseRequestMethod)requestMethod
                   tipsHostViewController:(id<HDBaseDataControllerIndicator>)hostViewController
               isShowLoadingIndicatorView:(BOOL)isShow
                                arguments:(NSDictionary *)args
                             successBlock:(void (^)(HDBaseDataController *dataController))successBlock
                             failureBlock:(void (^)(HDBaseDataController *dataController, NSError *error)) failureBlock;

- (void)willStartRequest:(NSURLRequest *)request;
- (void)requestCancel;

- (NSString *)basePath;
- (NSInteger)requestTimeout;
- (NSDictionary *)requestHTTPHeaderField;

+ (NSMutableDictionary *)createCommonArgument;

@end


